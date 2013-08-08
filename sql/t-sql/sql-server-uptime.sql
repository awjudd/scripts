/**
 * @author: Andrew Judd
 * @reference: http://blog.andrewjudd.ca/2012/11/programmatically-determining-space-transaction-log/
 * @link: https://github.com/awjudd/scripts/blob/master/sql/t-sql/sql-server-uptime.sql
 * @version: 1
 * @description: Programmatic way of determining how long both the SQL Server Agent, and the SQL Server instance have been up.
 * @source: http://social.msdn.microsoft.com/Forums/sqlserver/en-US/3d7aa13d-61a7-48d2-ada6-2398b31feb39/how-to-check-sql-server-uptime-through-tsql
 */
USE master

SET NOCOUNT ON 

DECLARE @CreateDate DATETIME
        , @Hours VARCHAR(50)
        , @Minutes VARCHAR(5) 

SELECT @CreateDate = d.create_date
FROM sys.databases AS d
WHERE d.name='tempdb' 

SELECT @Hours = (DATEDIFF(MINUTE, @CreateDate,GETDATE())) / 60 

IF ((DATEDIFF(MINUTE, @CreateDate,GETDATE()))/60)=0 
BEGIN
    SELECT @Minutes = (DATEDIFF(MINUTE, @CreateDate,GETDATE())) 
END
ELSE 
BEGIN
    SELECT @Minutes=(DATEDIFF(MINUTE, @CreateDate,GETDATE()))-((DATEDIFF(MINUTE,@CreateDate,GETDATE()))/60)*60 
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

