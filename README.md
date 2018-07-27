# zbx-symantec-be
Zabbix template and PowerShell script for monitoring Symantec Backup Exec

# Based on
https://share.zabbix.com/cat-app/backup/symantec-backup-exec-jobs (https://github.com/romainsi/zabbix-BackupExec-jobs)
and forums (sorry cant find url) for cyrillic symbols (in jobs name) compatibility 

# Notice
In script line (kind of fasthack) for timezone correction change for yours if needed: $job_Result1 = (New-TimeSpan -Start $date -end $job_Result).TotalSeconds - 10800
