# SQL Server DBA Toolkit

Read-only health-check and maintenance scripts for SQL Server 2016+.

## Scripts

| File | Purpose |
|---|---|
| `scripts/01_ssisdb_health_and_cleanup.sql` | SSISDB size, retention settings and safe cleanup |
| `scripts/02_agent_job_failures.sql` | SQL Agent job failures in the last N days |
| `scripts/03_database_mail_health.sql` | Failed mail items and Database Mail errors |
| `scripts/04_change_tracking_status.sql` | Change Tracking databases, tables and version safety |
| `scripts/05_columnstore_health.sql` | Columnstore rowgroup state, deleted rows and rebuild candidates |
| `scripts/06_database_sizes.sql` | Data and log file sizes, free space and growth settings |

## Usage

- Run in SSMS or Azure Data Studio as a member of `sysadmin`, or with `VIEW SERVER STATE`.
- Everything is read-only **except** the clearly marked cleanup section in `01`.
- Test on non-production first.

## License

MIT, see [LICENSE](../LICENSE)
