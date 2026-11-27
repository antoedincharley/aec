/* Data and log file sizes, free space and growth settings (all databases) */

SELECT  DB_NAME(mf.database_id)                         AS DatabaseName,
        mf.name                                         AS LogicalName,
        mf.type_desc,
        CAST(mf.size * 8.0 / 1024 AS decimal(12,1))     AS SizeMB,
        CASE WHEN mf.is_percent_growth = 1
             THEN CAST(mf.growth AS varchar(10)) + ' %'
             ELSE CAST(CAST(mf.growth * 8.0 / 1024 AS decimal(12,0)) AS varchar(20)) + ' MB'
        END                                             AS Growth,
        mf.physical_name
FROM    sys.master_files AS mf
ORDER BY SizeMB DESC;

-- Log reuse wait per database (why the log can't truncate)
SELECT  name AS DatabaseName,
        recovery_model_desc,
        log_reuse_wait_desc
FROM    sys.databases
ORDER BY name;

-- Log space used, all databases
DBCC SQLPERF(LOGSPACE);
