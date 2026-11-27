# Power BI DAX Patterns

DAX patterns I use in Power BI semantic models.

## Contents

| File | Pattern |
|---|---|
| `dax/01_virtual_relationships.dax` | `TREATAS`: filter across tables with no physical relationship |
| `dax/02_role_playing_dates.dax` | `USERELATIONSHIP`: order date vs ship date on one date table |
| `dax/03_crossfilter.dax` | `CROSSFILTER`: change filter direction inside one measure |
| `dax/04_dynamic_rls.dax` | Dynamic row-level security with a user-to-store mapping table |
| `dax/05_conditional_formatting.dax` | Measures that drive colours and icons in matrix visuals |
| `dax/06_time_intelligence.dax` | YTD, prior year and YoY % with a proper date table |

## Model assumptions

```
Fact_Sales[DateKey]      → Dim_Date[DateKey]        (active)
Fact_Sales[ShipDateKey]  → Dim_Date[DateKey]        (inactive)
Fact_Sales[StoreKey]     → Dim_Store[StoreKey]
Fact_Sales[ProductKey]   → Dim_Product[ProductKey]
Fact_Target              (no relationship, budget at Store × Month grain)
Security_UserStore       (UserEmail, StoreKey)
```

Dim_Date is marked as a date table.

## Guidance

- Use **physical relationships** first and `TREATAS` only when grains differ.
- Keep **bi-directional filters off** in the model and turn them on per measure with `CROSSFILTER`.
- Use **one base measure per number**, and build time intelligence on top of it.

## License

MIT, see [LICENSE](../LICENSE)
