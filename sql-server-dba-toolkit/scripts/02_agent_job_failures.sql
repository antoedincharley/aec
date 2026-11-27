/* SQL Agent job failures in the last @Days days */

DECLARE @Days int = 7;

SELECT  j.name                                        AS JobName,
        h.step_id,
        h.step_name,
        msdb.dbo.agent_datetime(h.run_date, h.run_time) AS RunTime,
        STUFF(STUFF(RIGHT('000000' + CAST(h.run_duration AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
                                                      AS Duration_hhmmss,
        h.message
FROM    msdb.dbo.sysjobhistory AS h
JOIN    msdb.dbo.sysjobs       AS j ON j.job_id = h.job_id
WHERE   h.run_status = 0                      -- 0 = Failed
  AND   msdb.dbo.agent_datetime(h.run_date, h.run_time) >= DATEADD(DAY, -@Days, GETDATE())
ORDER BY RunTime DESC;

-- Jobs that are enabled but have no schedule
SELECT  j.name
FROM    msdb.dbo.sysjobs j
WHERE   j.enabled = 1
  AND   NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobschedules s WHERE s.job_id = j.job_id);
