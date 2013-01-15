/**
 * @author: Andrew Judd
 * @reference: http://blog.andrewjudd.ca/2012/07/sql-server-finding-table-sizes-programmatically/
 * @link: https://github.com/awjudd/scripts/blob/master/sql/t-sql/table-size.sql
 * @version: 1
 * @description: Programmatic way of determining the size of each of the tables in a database
 */
SET NOCOUNT ON

DBCC UPDATEUSAGE(0)

-- DB size.
EXEC sp_spaceused

-- Table row counts and sizes.
CREATE TABLE #t
(
     [name] NVARCHAR(128)
     , [ROWS] CHAR(11)
     , reserved VARCHAR(18)
     , DATA VARCHAR(18)
     , index_size VARCHAR(18)
     , unused VARCHAR(18)
)

INSERT #t
    EXEC sp_msForEachTable 'EXEC sp_spaceused ''?'''

SELECT *
FROM   #t

-- # of rows.
SELECT SUM(CAST([ROWS] AS INT)) AS [ROWS]
FROM   #t

DROP TABLE #t