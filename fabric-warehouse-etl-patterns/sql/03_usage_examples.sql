-- Daily / hourly incremental run
EXEC etl.sp_Load_Fact_Sales @LoadMode = 'UPSERT';

-- Full reload (data repair)
EXEC etl.sp_Load_Fact_Sales @LoadMode = 'FULL';

-- Rebuild after a schema change
EXEC etl.sp_Load_Fact_Sales @LoadMode = 'RECREATE';

-- Last 20 runs
SELECT TOP (20)
       TableName, LoadMode, StartTime,
       DATEDIFF(SECOND, StartTime, EndTime) AS DurationSec,
       RowsDeleted, RowsInserted, Status, ErrorMessage
FROM   etl.LoadLog
ORDER  BY StartTime DESC;

-- Current watermarks
SELECT TableName, LastWatermark, UpdatedAt
FROM   etl.Watermark
ORDER  BY TableName;
