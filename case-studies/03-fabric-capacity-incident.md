# 03 · Recovering from a Fabric capacity failure

**Area:** Microsoft Fabric operations · Incident management · Executive reporting

## Context
A production Microsoft Fabric capacity (F64) suffered a backend node failure. Scheduled loads stopped completing, leaving a **multi-day gap** in reporting data.

## Challenge
- Find the cause while the platform reported no clear error
- Restore service without losing data
- Backfill the missing days
- Explain the impact clearly to leadership

## Approach
1. **Triaged** failed and stalled pipeline and warehouse activity to isolate the problem to the capacity, not the ETL code
2. **Restored service** by pausing and resuming the capacity, which moved workloads off the failed node
3. **Backfilled** the gap by re-running loads for the affected window. The idempotent load design ([case study 01](01-fabric-etl-framework.md)) made this safe.
4. **Validated** row counts and totals against the source
5. **Wrote an executive incident report** covering timeline, root cause, business impact, resolution and prevention

## Outcome
- Service restored and the data gap closed
- Leadership received a clear, non-technical account of what happened
- Monitoring and prevention steps defined for future incidents

## Lessons
- Re-runnable loads turn an outage into a backfill, not a data repair project
- Capacity-level actions (pause/resume) are a valid recovery step and worth documenting in the runbook
