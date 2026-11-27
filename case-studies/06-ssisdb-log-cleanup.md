# 06 · Fixing SSISDB log growth

**Area:** SQL Server 2016 · SSIS · SSISDB · SQL Agent

## Context
On a SQL Server 2016 instance, the SSIS catalog database (`SSISDB`) had built up a very large volume of execution logs, putting pressure on disk space and backups.

## Challenge
- Shrink the backlog without breaking the SSIS catalog
- Avoid a huge transaction log spike from one large delete
- Stop the problem from coming back

## Approach
1. **Measured** catalog settings, operation history volume and the largest internal tables
2. **Used the supported cleanup path** (`catalog.configure_catalog` + `internal.cleanup_server_retention_window`) instead of deleting rows by hand
3. **Lowered the retention window in steps** so each cleanup run stayed small and log growth stayed under control
4. **Lowered the server logging level** for routine executions
5. **Confirmed** the SSIS Server Maintenance Job is enabled and scheduled

## Outcome
- Backlog removed using the supported method
- Retention and logging set so growth stays under control
- The checks became part of the [DBA toolkit](../sql-server-dba-toolkit)
