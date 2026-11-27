/* Change Tracking status (run in the tracked database) */

-- Databases with Change Tracking enabled
SELECT  DB_NAME(database_id) AS DatabaseName,
        is_auto_cleanup_on,
        retention_period,
        retention_period_units_desc
FROM    sys.change_tracking_databases;

-- Tracked tables and their minimum valid version
SELECT  SCHEMA_NAME(t.schema_id) + '.' + t.name              AS TableName,
        ct.is_track_columns_updated_on,
        ct.min_valid_version,
        CHANGE_TRACKING_MIN_VALID_VERSION(ct.object_id)     AS MinValidVersionNow,
        ct.begin_version,
        ct.cleanup_version
FROM    sys.change_tracking_tables AS ct
JOIN    sys.tables                 AS t ON t.object_id = ct.object_id
ORDER BY TableName;

-- Current database version
SELECT CHANGE_TRACKING_CURRENT_VERSION() AS CurrentVersion;

/* Before an incremental pull, check that your stored last-sync version
   is still valid. If it is lower than the minimum valid version,
   changes have been cleaned up and a full reload is required:

   IF @LastSyncVersion < CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID('dbo.YourTable'))
       -- full reload
*/
