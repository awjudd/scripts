DECLARE @Foo TABLE (
    FooBar INT
)

DECLARE @Bar TABLE (
    FooBar INT
)

INSERT INTO @Foo ( FooBar )
    VALUES ( 1 ), ( 2 ), ( 3 )


INSERT INTO @Bar ( FooBar )
    VALUES ( 2 ), ( 5 ), ( 4 )

-- Query #1
SELECT FooBar FROM @Foo
EXCEPT
SELECT FooBar FROM @Bar

UNION

SELECT FooBar FROM @Bar
EXCEPT
SELECT FooBar FROM @Foo

-- Query #2
SELECT FooBar FROM @Bar
EXCEPT
SELECT FooBar FROM @Foo

UNION

SELECT FooBar FROM @Foo
EXCEPT
SELECT FooBar FROM @Bar

-- Query #3
SELECT *
FROM (
    SELECT FooBar FROM @Bar
    EXCEPT
    SELECT FooBar FROM @Foo
) a

UNION

SELECT *
FROM (
    SELECT FooBar FROM @Foo
    EXCEPT
    SELECT FooBar FROM @Bar
) b

-- Query #4
SELECT a.FooBar
FROM @Foo a
LEFT JOIN @Bar b ON a.FooBar = b.FooBar
WHERE b.FooBar IS NULL

UNION

SELECT a.FooBar
FROM @Bar a
LEFT JOIN @Foo b ON a.FooBar = b.FooBar
WHERE b.FooBar IS NULL
