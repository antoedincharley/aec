# Fabric Warehouse ETL Patterns

Reusable T-SQL patterns for loading fact and dimension tables in **Microsoft Fabric Warehouse**.

## Features

| Pattern | Why |
|---|---|
| **Three load modes** — `FULL`, `RECREATE`, `UPSERT` | One procedure covers initial loads, schema rebuilds and daily increments |
| **SHA2-256 row hash** | Detects changed rows without comparing every column |
| **Watermark table** | Incremental loads pick up only rows changed since the last run |
| **DELETE + INSERT instead of MERGE** | Predictable behaviour and performance in Fabric Warehouse |
| **Load logging** | Every run records mode, row counts, duration and errors |

## Structure

```
sql/
  01_etl_schema.sql          -- etl schema, watermark and log tables
  02_sp_Load_Fact_Sales.sql  -- template load procedure (3 modes)
  03_usage_examples.sql      -- how to run each mode
```

## Load modes

| Mode | What it does | Use when |
|---|---|---|
| `FULL` | Truncates the target and reloads all rows | Data repair, first load |
| `RECREATE` | Drops and rebuilds the table, then reloads | Schema changes |
| `UPSERT` | Replaces changed rows and inserts new ones since the watermark | Scheduled daily or hourly runs |

## How UPSERT works

1. Read source rows where `ModifiedDate > last watermark`
2. Compute `RowHash = SHA2_256(column1 | column2 | ...)`
3. Delete target rows whose key matches and whose hash differs
4. Insert new and changed rows
5. Advance the watermark only if the load succeeds

## Notes

- Fabric Warehouse doesn't support `nvarchar`, so use `varchar` with a UTF-8 collation.
- Primary keys are `NOT ENFORCED` in Fabric Warehouse, so the procedure handles uniqueness itself.
- Table and column names are examples. Rename them to match your model.

## License

MIT — see [LICENSE](../LICENSE)
