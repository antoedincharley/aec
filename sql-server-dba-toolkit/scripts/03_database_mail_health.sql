/* Database Mail health */

-- Is Database Mail running?
EXEC msdb.dbo.sysmail_help_status_sp;

-- Queue state
EXEC msdb.dbo.sysmail_help_queue_sp @queue_type = 'mail';

-- Failed items in the last 7 days
SELECT  f.mailitem_id,
        f.recipients,
        f.subject,
        f.send_request_date,
        l.description AS ErrorDetail
FROM    msdb.dbo.sysmail_faileditems AS f
LEFT JOIN msdb.dbo.sysmail_event_log AS l ON l.mailitem_id = f.mailitem_id
WHERE   f.send_request_date >= DATEADD(DAY, -7, GETDATE())
ORDER BY f.send_request_date DESC;

-- Recent errors in the mail log
SELECT TOP (50) log_date, event_type, description
FROM   msdb.dbo.sysmail_event_log
WHERE  event_type = 'error'
ORDER BY log_date DESC;
