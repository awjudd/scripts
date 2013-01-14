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