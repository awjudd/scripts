/**
 * @author: Andrew Judd
 * @reference: http://blog.andrewjudd.ca/2012/10/sql-server-wait-stats-mean/
 * @link: https://github.com/awjudd/scripts/blob/master/sql/t-sql/wait-stat.sql
 * @version: 1
 * @description: Lists the frequency and information about your database's wait stats ordered by the wait time in milliseconds
 */
SELECT * FROM sys.dm_os_wait_stats ORDER BY wait_time_ms DESC