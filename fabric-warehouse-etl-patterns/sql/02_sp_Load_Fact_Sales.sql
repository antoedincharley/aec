/* =====================================================================
   etl.sp_Load_Fact_Sales
   Template load procedure for Microsoft Fabric Warehouse

   @LoadMode
     FULL     - truncate target, reload all source rows
     RECREATE - drop and recreate target, reload all source rows
     UPSERT   - load rows changed since the last watermark
                (DELETE changed keys + INSERT; no MERGE)

   Change detection : SHA2-256 hash over business columns
   Watermark        : max(ModifiedDate) of the loaded source rows
   ===================================================================== */

CREATE OR ALTER PROCEDURE etl.sp_Load_Fact_Sales
    @LoadMode varchar(10) = 'UPSERT'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName     varchar(128) = 'dbo.Fact_Sales',
            @RunId         varchar(36)  = CONVERT(varchar(36), NEWID()),
            @Start         datetime2(6) = SYSUTCDATETIME(),
            @Watermark     datetime2(6),
            @NewWatermark  datetime2(6),
            @RowsDeleted   int = 0,
            @RowsInserted  int = 0;

    SET @LoadMode = UPPER(@LoadMode);
    IF @LoadMode NOT IN ('FULL', 'RECREATE', 'UPSERT')
        THROW 50001, 'Invalid @LoadMode. Use FULL, RECREATE or UPSERT.', 1;

    INSERT INTO etl.LoadLog (RunId, TableName, LoadMode, StartTime, Status)
    VALUES (@RunId, @TableName, @LoadMode, @Start, 'Running');

    BEGIN TRY
        /* ---------- 1. Watermark ---------- */
        SELECT @Watermark = LastWatermark
        FROM   etl.Watermark
        WHERE  TableName = @TableName;

        IF @Watermark IS NULL OR @LoadMode <> 'UPSERT'
            SET @Watermark = '1900-01-01';

        /* ---------- 2. Recreate target (RECREATE mode) ---------- */
        IF @LoadMode = 'RECREATE' OR OBJECT_ID(@TableName) IS NULL
        BEGIN
            DROP TABLE IF EXISTS dbo.Fact_Sales;

            CREATE TABLE dbo.Fact_Sales
            (
                SalesLineKey    varchar(50)    NOT NULL,
                DateKey         int            NOT NULL,
                StoreKey        int            NOT NULL,
                ProductKey      int            NOT NULL,
                Quantity        decimal(18,4)  NOT NULL,
                NetAmount       decimal(18,4)  NOT NULL,
                DiscountAmount  decimal(18,4)  NOT NULL,
                RowHash         varbinary(32)  NOT NULL,
                SourceModified  datetime2(6)   NOT NULL,
                LoadedAt        datetime2(6)   NOT NULL
            );
        END;

        /* ---------- 3. Stage source rows with hash ---------- */
        DROP TABLE IF EXISTS #src;

        CREATE TABLE #src
        (
            SalesLineKey    varchar(50)    NOT NULL,
            DateKey         int            NOT NULL,
            StoreKey        int            NOT NULL,
            ProductKey      int            NOT NULL,
            Quantity        decimal(18,4)  NOT NULL,
            NetAmount       decimal(18,4)  NOT NULL,
            DiscountAmount  decimal(18,4)  NOT NULL,
            RowHash         varbinary(32)  NOT NULL,
            SourceModified  datetime2(6)   NOT NULL
        );

        INSERT INTO #src
        SELECT  s.SalesLineKey,
                s.DateKey,
                s.StoreKey,
                s.ProductKey,
                s.Quantity,
                s.NetAmount,
                s.DiscountAmount,
                HASHBYTES('SHA2_256',
                    CONCAT_WS('|',
                        s.DateKey, s.StoreKey, s.ProductKey,
                        s.Quantity, s.NetAmount, s.DiscountAmount)),
                s.ModifiedDate
        FROM    stg.Sales AS s
        WHERE   s.ModifiedDate > @Watermark;

        SELECT @NewWatermark = MAX(SourceModified) FROM #src;

        /* ---------- 4. Apply ---------- */
        BEGIN TRANSACTION;

        IF @LoadMode = 'FULL'
        BEGIN
            SELECT @RowsDeleted = COUNT_BIG(*) FROM dbo.Fact_Sales;
            TRUNCATE TABLE dbo.Fact_Sales;
        END
        ELSE IF @LoadMode = 'UPSERT'
        BEGIN
            -- drop unchanged rows from the batch
            DELETE s
            FROM   #src AS s
            WHERE  EXISTS (SELECT 1
                           FROM   dbo.Fact_Sales AS t
                           WHERE  t.SalesLineKey = s.SalesLineKey
                             AND  t.RowHash      = s.RowHash);

            -- remove old versions of changed rows
            DELETE t
            FROM   dbo.Fact_Sales AS t
            WHERE  EXISTS (SELECT 1
                           FROM   #src AS s
                           WHERE  s.SalesLineKey = t.SalesLineKey);

            SET @RowsDeleted = @@ROWCOUNT;
        END;

        INSERT INTO dbo.Fact_Sales
        (
            SalesLineKey, DateKey, StoreKey, ProductKey,
            Quantity, NetAmount, DiscountAmount,
            RowHash, SourceModified, LoadedAt
        )
        SELECT  SalesLineKey, DateKey, StoreKey, ProductKey,
                Quantity, NetAmount, DiscountAmount,
                RowHash, SourceModified, SYSUTCDATETIME()
        FROM    #src;

        SET @RowsInserted = @@ROWCOUNT;

        /* ---------- 5. Advance watermark ---------- */
        IF @NewWatermark IS NOT NULL
        BEGIN
            DELETE FROM etl.Watermark WHERE TableName = @TableName;

            INSERT INTO etl.Watermark (TableName, LastWatermark, UpdatedAt)
            VALUES (@TableName, @NewWatermark, SYSUTCDATETIME());
        END;

        COMMIT TRANSACTION;

        UPDATE etl.LoadLog
        SET    EndTime      = SYSUTCDATETIME(),
               RowsDeleted  = @RowsDeleted,
               RowsInserted = @RowsInserted,
               Status       = 'Succeeded'
        WHERE  RunId = @RunId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        UPDATE etl.LoadLog
        SET    EndTime      = SYSUTCDATETIME(),
               Status       = 'Failed',
               ErrorMessage = LEFT(ERROR_MESSAGE(), 4000)
        WHERE  RunId = @RunId;

        THROW;
    END CATCH;
END;
GO
