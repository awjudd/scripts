USE master

-- Reference: http://social.msdn.microsoft.com/Forums/sqlserver/en-US/3d7aa13d-61a7-48d2-ada6-2398b31feb39/how-to-check-sql-server-uptime-through-tsql

SET NOCOUNT ON 

DECLARE @CreateDate DATETIME
        , @Hours VARCHAR(50)
        , @Minutes VARCHAR(5) 

SELECT @CreateDate = d.create_date
FROM sys.databases AS d
WHERE d.name='tempdb' 

SELECT @Hours = (DATEDIFF(MINUTE, @CreateDate,GETDATE())) / 60 

IF ((DATEDIFF ( MINUTE, @CreateDate,GETDATE()))/60)=0 
BEGIN
    SELECT @Minutes = (DATEDIFF ( mi, @CreateDate,GETDATE())) 
END
ELSE 
BEGIN
    SELECT @Minutes=(DATEDIFF ( mi, @CreateDate,GETDATE()))-((DATEDIFF( mi, @CreateDate,GETDATE()))/60)*60 
END

PRINT 'SQL Server "' + CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME'))+'" is Online for the past ' + @Hours + ' hours & ' + @Minutes + ' minutes' 

IF NOT EXISTS (SELECT 1 FROM master.dbo.sysprocesses WHERE program_name = N'SQLAgent - Generic Refresher') 
BEGIN 
    PRINT 'SQL Server is running but SQL Server Agent <<NOT>> running' 
END 
ELSE
BEGIN 
    PRINT 'SQL Server and SQL Server Agent both are running' 
END 

