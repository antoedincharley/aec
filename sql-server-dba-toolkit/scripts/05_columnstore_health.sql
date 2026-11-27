/* Columnstore rowgroup health (run in the target database) */

SELECT  OBJECT_SCHEMA_NAME(rg.object_id) + '.' + OBJECT_NAME(rg.object_id) AS TableName,
        i.name                                    AS IndexName,
        rg.state_desc,
        COUNT(*)                                  AS RowGroups,
        SUM(rg.total_rows)                        AS TotalRows,
        SUM(rg.deleted_rows)                      AS DeletedRows,
        CAST(100.0 * SUM(rg.deleted_rows)
             / NULLIF(SUM(rg.total_rows), 0) AS decimal(5,1)) AS DeletedPct,
        AVG(rg.total_rows)                        AS AvgRowsPerGroup
FROM    sys.dm_db_column_store_row_group_physical_stats AS rg
JOIN    sys.indexes AS i
        ON i.object_id = rg.object_id AND i.index_id = rg.index_id
GROUP BY rg.object_id, i.name, rg.state_desc
ORDER BY TableName, rg.state_desc;

/* Rebuild / reorganize candidates
   - DeletedPct > 10 %             -> ALTER INDEX ... REORGANIZE (or REBUILD)
   - Many OPEN / CLOSED rowgroups  -> ALTER INDEX ... REORGANIZE
                                      WITH (COMPRESS_ALL_ROW_GROUPS = ON)
   - AvgRowsPerGroup far below 1,048,576 -> check trim reasons below */

SELECT  OBJECT_NAME(object_id) AS TableName,
        trim_reason_desc,
        COUNT(*)               AS RowGroups
FROM    sys.dm_db_column_store_row_group_physical_stats
WHERE   state_desc = 'COMPRESSED'
GROUP BY object_id, trim_reason_desc
ORDER BY TableName, RowGroups DESC;
