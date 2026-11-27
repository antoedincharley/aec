# Anto Edin Charley

Data and BI Engineer working on Microsoft Fabric, Power BI and SQL Server in retail analytics.

I design and run the data platform end to end: ingestion from ERP and on-premises SQL Server, warehouse ETL in Fabric, semantic models in Power BI, and the SQL Server estate behind them.

## Experience

**Microsoft Fabric**
Warehouse and Lakehouse ETL, Dataflow Gen2, pipelines, PySpark notebooks, capacity operations and incident recovery.

**Power BI**
Semantic model design, composite models (Direct Lake with on-premises DirectQuery), DAX, row-level security, gateway configuration.

**SQL Server**
Administration of production instances: SSIS and SSISDB, SQL Agent, Change Tracking, columnstore indexes, Database Mail.

**Data warehousing and migration**
Incremental loading with hash-based change detection and watermarks. Moving reporting off SAP to a central analytics platform with Dynamics NAV / Business Central sources.

## Live report

[Retail sales report](powerbi-retail-showcase): interactive Power BI report on sample data, built as a Power BI Project (TMDL + PBIR).

## Case studies

| | |
|---|---|
| [Incremental ETL framework for Fabric Warehouse](case-studies/01-fabric-etl-framework.md) | Fabric, T-SQL |
| [Composite semantic model: Direct Lake + on-prem DirectQuery](case-studies/02-composite-semantic-model.md) | Power BI, DAX, RLS |
| [Recovering from a Fabric capacity failure](case-studies/03-fabric-capacity-incident.md) | Operations |
| [Diagnosing Fabric Warehouse storage bloat](case-studies/04-fabric-storage-bloat.md) | Fabric, PySpark, PowerShell |
| [Release notes app on Fabric](case-studies/05-release-notes-app.md) | Dataflow Gen2, Power BI |
| [Fixing SSISDB log growth](case-studies/06-ssisdb-log-cleanup.md) | SQL Server |
| [Moving reporting off SAP to an analytics hub](case-studies/07-sap-decommissioning.md) | Migration |
| [Retail sales report in Power BI](case-studies/08-retail-sales-report.md) | Power BI, TMDL, PBIR |

## Code samples

- [powerbi-retail-showcase](powerbi-retail-showcase) – full Power BI project: semantic model, report, data and generator
- [fabric-warehouse-etl-patterns](fabric-warehouse-etl-patterns) – load procedure template with Full, Recreate and Upsert modes, SHA2-256 row hashing and watermarking
- [powerbi-dax-patterns](powerbi-dax-patterns) – virtual relationships, role-playing dates, dynamic RLS, conditional formatting, time intelligence
- [sql-server-dba-toolkit](sql-server-dba-toolkit) – health checks for SSISDB, SQL Agent, Database Mail, Change Tracking and columnstore

## Tools

Microsoft Fabric, Power BI, SQL Server, T-SQL, DAX, Power Query, PySpark, PowerShell, SSIS, Azure Logic Apps

## Contact

[LinkedIn](https://www.linkedin.com/in/antoedincharley/)
