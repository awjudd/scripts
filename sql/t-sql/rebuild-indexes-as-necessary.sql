-- ==========================================================================================
--  Description: Used to go through all of the tables in your specified database and
--               check the fragmentation levels of the indexes.  If the indexes are
--               highly fragmented, it will rebuild it, otherwise it will just try to
--               run a reorganize.
--  Background:  http://blog.sqlauthority.com/2007/12/22/sql-server-difference-between-index-rebuild-and-index-reorganize-explained-with-t-sql-script/
-- ==========================================================================================
CREATE PROCEDURE dbo.usp_RebuildIndexesAsNecessary
	@RebuildThreshold FLOAT = 40
	, @FragmentationThreshold FLOAT = 10
AS
BEGIN

	SET NOCOUNT ON

	CREATE TABLE #Fragmentation 
	(
		  TableName NVARCHAR(200)
		, IndexName NVARCHAR(200)
		, FragmentationAmount DECIMAL(18,4)
	)

	-- Load all of the fragmented tables
	INSERT  INTO #Fragmentation ( TableName, IndexName, FragmentationAmount )
			SELECT  DISTINCT 
					TableName = S.name + '.' + tbl.[name]
					, IndexName = ind.name
					, FragmentationAmount = MAX(mn.avg_fragmentation_in_percent)
			FROM    sys.dm_db_index_physical_stats(NULL, NULL, NULL, NULL, NULL) AS mn
			INNER JOIN sys.tables tbl ON tbl.[object_id] = mn.[object_id]
			INNER JOIN sys.indexes ind ON ind.[object_id] = mn.[object_id]
			INNER JOIN sys.schemas S ON tbl.schema_id = S.schema_id
			WHERE   [database_id] = DB_ID()
					AND mn.avg_fragmentation_in_percent > @FragmentationThreshold
					AND ind.type_desc <> 'NONCLUSTERED COLUMNSTORE'
					AND ind.name IS NOT NULL
			GROUP BY S.name + '.' + tbl.[name], ind.name
			ORDER BY MAX(mn.avg_fragmentation_in_percent) DESC

	WHILE EXISTS ( SELECT TOP 1
							TableName
				   FROM     #Fragmentation ) 
		BEGIN
			DECLARE @TableName AS NVARCHAR(200)
				   , @IndexName AS NVARCHAR(200)
				   , @FragmentationAmount DECIMAL(18,4)
				   , @sql VARCHAR(1000)
			SELECT TOP 1
					@TableName = TableName
					, @IndexName = IndexName
					, @FragmentationAmount = FragmentationAmount
			FROM    #Fragmentation

			SET @sql = 'ALTER INDEX ' + @IndexName + ' ON ' + @TableName + CASE WHEN @FragmentationAmount > @RebuildThreshold THEN ' REBUILD' ELSE ' REORGANIZE' END
            
			PRINT @sql
			EXEC(  @sql )

			DELETE  FROM #Fragmentation WHERE   TableName = @TableName AND IndexName = @IndexName

			BREAK
		END

	DROP TABLE #Fragmentation


END