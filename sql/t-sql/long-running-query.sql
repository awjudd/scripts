/**
 * @author: Andrew Judd
 * @reference: http://blog.andrewjudd.ca/2012/04/determining-long-running-queries-programmatically-v2/
 * @link: https://github.com/awjudd/scripts/blob/master/sql/t-sql/long-running-query.sql
 * @version: 2
 * @description: Programmatic way of viewing all of the long running queries on a server including the following information:
 *   - Who is running the query?
 *   - Where is the server running from?
 *   - How long the query has been running for
 *   - How many threads the query has spooled
 *   - The query
 *  Works best if used as a sysadmin on the database server.
 */
DECLARE	@spid INT ,
	@stmt_start INT ,
	@stmt_end INT ,
	@sql_handle BINARY(20)

DECLARE	@ProcessID INT ,
	@Duration VARCHAR(MAX) ,
	@ProgramName VARCHAR(MAX) ,
	@HostName VARCHAR(MAX) ,
	@LoginName VARCHAR(MAX)

DECLARE	@Processes TABLE
	(
	  ProcessID INT ,
	  Duration VARCHAR(MAX) ,
	  ProgramName VARCHAR(MAX) ,
	  HostName VARCHAR(MAX) ,
	  LoginName VARCHAR(MAX) ,
	  Query VARCHAR(MAX)
	)

DECLARE crsProcesses CURSOR FAST_FORWARD READ_ONLY
FOR
	SELECT	p.spid ,
			RIGHT(CONVERT(VARCHAR, DATEADD(ms,
										   DATEDIFF(ms, P.last_batch,
													GETDATE()), '1900-01-01'), 121),
				  12) AS 'batch_duration' ,
			P.program_name ,
			P.hostname ,
			P.loginame
	FROM	master.dbo.sysprocesses P
	WHERE	P.spid > 50
			AND P.STATUS NOT IN ( 'background', 'sleeping' )
			AND P.cmd NOT IN ( 'AWAITING COMMAND', 'MIRROR HANDLER',
							   'LAZY WRITER', 'CHECKPOINT SLEEP', 'RA MANAGER' )
	ORDER BY batch_duration DESC

OPEN crsProcesses

FETCH NEXT FROM crsProcesses INTO @ProcessID, @Duration, @ProgramName,
	@HostName, @LoginName

WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @spid = @ProcessID

		SELECT TOP 1
				@sql_handle = sql_handle ,
				@stmt_start = CASE stmt_start
								WHEN 0 THEN 0
								ELSE stmt_start / 2
							  END ,
				@stmt_end = CASE stmt_end
							  WHEN -1 THEN -1
							  ELSE stmt_end / 2
							END
		FROM	master.dbo.sysprocesses
		WHERE	spid = @spid
		ORDER BY ecid

		INSERT	INTO @Processes
				( ProcessID ,
				  Duration ,
				  ProgramName ,
				  HostName ,
				  LoginName ,
				  Query
				)
				SELECT	@ProcessID AS ProcessID ,
						@Duration ,
						@ProgramName AS ProgramName ,
						@HostName AS HostName ,
						@LoginName AS LoginName ,
						SUBSTRING(text, COALESCE(NULLIF(@stmt_start, 0), 1),
								  CASE @stmt_end
									WHEN -1 THEN DATALENGTH(text)
									ELSE ( @stmt_end - @stmt_start )
								  END) AS Query
				FROM	::
						fn_get_sql(@sql_handle)



		FETCH NEXT FROM crsProcesses INTO @ProcessID, @Duration, @ProgramName,
			@HostName, @LoginName

	END

CLOSE crsProcesses

DEALLOCATE crsProcesses

SELECT p.ProcessID
		, p.Duration
		, p.ProgramName
		, p.HostName
		, LoginName = MAX(p.LoginName)
		, ThreadCount = COUNT(*)
		, p.Query
FROM	@Processes AS p
GROUP BY p.ProcessID
		, p.Duration
		, p.ProgramName
		, p.HostName
		, p.Query