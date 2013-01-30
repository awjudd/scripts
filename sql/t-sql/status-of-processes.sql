/**
 * @author: Andrew Judd
 * @reference: http://blog.andrewjudd.ca/2011/05/sql-server-view-status-of-long-running-task/
 * @link: https://github.com/awjudd/scripts/blob/master/sql/t-sql/status-of-processes.sql
 * @version: 1
 * @description: Programmatic way of viewing the status of some long running (and deterministic) queries
 *  Provides Information for:
 *   - Backing up databases
 *   - Restoring databases
 */
SELECT session_id, command, percent_complete
FROM sys.dm_exec_requests AS dmr
-- WHERE command = 'RESTORE DATABASE' /* the percentage complete of any database restores happening on the server */
-- WHERE command = 'BACKUP DATABASE' /* the percentage complete of any database backups happening on the server */
