/* SSISDB health and cleanup
   Uses the built-in catalog retention mechanism (supported approach). */

USE SSISDB;
GO

-- 1. Current catalog settings
SELECT name, value_set, value_ref
FROM   catalog.catalog_properties
WHERE  name IN ('RETENTION_WINDOW', 'OPERATION_CLEANUP_ENABLED',
                'MAX_PROJECT_VERSIONS', 'VERSION_CLEANUP_ENABLED',
                'SERVER_LOGGING_LEVEL');

-- 2. Database size
SELECT  name AS FileName,
        type_desc,
        CAST(size * 8.0 / 1024 AS decimal(12,1)) AS SizeMB
FROM    sys.database_files;

-- 3. Operation history volume
SELECT  COUNT(*)            AS Operations,
        MIN(created_time)   AS Oldest,
        MAX(created_time)   AS Newest
FROM    catalog.operations;

-- 4. Largest internal tables
SELECT TOP (10)
        t.name AS TableName,
        SUM(p.rows) AS RowCnt,
        CAST(SUM(a.total_pages) * 8.0 / 1024 AS decimal(12,1)) AS SizeMB
FROM    sys.tables t
JOIN    sys.partitions p        ON p.object_id = t.object_id AND p.index_id IN (0,1)
JOIN    sys.allocation_units a  ON a.container_id = p.partition_id
GROUP BY t.name
ORDER BY SizeMB DESC;
GO

/* ------------------------------------------------------------------
   CLEANUP — changes data. Review before running.
   ------------------------------------------------------------------ */

-- Set retention (days) and enable cleanup
-- EXEC catalog.configure_catalog @property_name = N'RETENTION_WINDOW',          @property_value = 30;
-- EXEC catalog.configure_catalog @property_name = N'OPERATION_CLEANUP_ENABLED', @property_value = 1;

-- Reduce logging for routine runs (1 = Basic)
-- EXEC catalog.configure_catalog @property_name = N'SERVER_LOGGING_LEVEL',      @property_value = 1;

-- Run the cleanup now (normally run by the SQL Agent job
-- "SSIS Server Maintenance Job"). For very large backlogs, lower
-- RETENTION_WINDOW in steps (e.g. 365 -> 180 -> 90 -> 30) to keep
-- each run and the log growth manageable.
-- EXEC internal.cleanup_server_retention_window;
