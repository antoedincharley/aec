/* =====================================================================
   ETL control objects for Microsoft Fabric Warehouse
   - etl.Watermark : last successful high-water mark per target table
   - etl.LoadLog   : one row per procedure run
   ===================================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'etl')
    EXEC ('CREATE SCHEMA etl');
GO

IF OBJECT_ID('etl.Watermark') IS NULL
CREATE TABLE etl.Watermark
(
    TableName       varchar(128)  NOT NULL,
    LastWatermark   datetime2(6)  NOT NULL,
    UpdatedAt       datetime2(6)  NOT NULL
);
GO

IF OBJECT_ID('etl.LoadLog') IS NULL
CREATE TABLE etl.LoadLog
(
    RunId           varchar(36)    NOT NULL,
    TableName       varchar(128)   NOT NULL,
    LoadMode        varchar(10)    NOT NULL,
    StartTime       datetime2(6)   NOT NULL,
    EndTime         datetime2(6)   NULL,
    RowsDeleted     int            NULL,
    RowsInserted    int            NULL,
    Status          varchar(20)    NOT NULL,   -- Running / Succeeded / Failed
    ErrorMessage    varchar(4000)  NULL
);
GO
