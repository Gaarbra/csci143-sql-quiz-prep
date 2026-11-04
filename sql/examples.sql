-- Every example from index.html, with the real output from postgres (psql) and sqlite3.
-- Load the tables first:  psql -f quiz1_create_tables.sql -f quiz2_create_tables.sql -f datalemur_example_tables.sql
--                          sqlite3 prep.db < quiz1_create_tables.sql  (and the other two)


-- Edit me and press Run (or Ctrl+Enter).
SELECT id, sum(id) OVER (ORDER BY id) AS running_sum
FROM basket_a
ORDER BY id;
/* postgres:
  id  | running_sum 
------+-------------
    1 |           2
    1 |           2
    2 |           4
    3 |           7
    4 |          11
 NULL |          11
 NULL |          11

   sqlite3:
id    running_sum
----  -----------
NULL  NULL       
NULL  NULL       
1     2          
1     2          
2     4          
3     7          
4     11
*/

------------------------------------------------------------------------------
-- The tables you're given
------------------------------------------------------------------------------

SELECT * FROM basket_a;
/* postgres:
  id  | fruit_a  
------+----------
    1 | Apple
    1 | Apple
    2 | Orange
    3 | Banana
 NULL | Cucumber
    4 | NULL
 NULL | NULL

   sqlite3:
id    fruit_a 
----  --------
1     Apple   
1     Apple   
2     Orange  
3     Banana  
NULL  Cucumber
4     NULL    
NULL  NULL
*/

SELECT sid, count(*) AS messages
FROM message
GROUP BY sid
ORDER BY sid;
/* postgres:
 sid  | messages 
------+----------
    1 |        4
    2 |        7
    3 |        6
    9 |        1
 NULL |        3

   sqlite3:
sid   messages
----  --------
NULL  3       
1     4       
2     7       
3     6       
9     1
*/

------------------------------------------------------------------------------
-- Postgres vs SQLite
------------------------------------------------------------------------------

SELECT id, fruit_a FROM basket_a ORDER BY id;
/* postgres:
  id  | fruit_a  
------+----------
    1 | Apple
    1 | Apple
    2 | Orange
    3 | Banana
    4 | NULL
 NULL | Cucumber
 NULL | NULL

   sqlite3:
id    fruit_a 
----  --------
NULL  Cucumber
NULL  NULL    
1     Apple   
1     Apple   
2     Orange  
3     Banana  
4     NULL
*/

------------------------------------------------------------------------------
-- Quiz 1: basics, NULL, joins, window functions
------------------------------------------------------------------------------

-- ### How each line of a query runs

-- ### NULL poisons everything

SELECT 'a' || NULL AS concat, 1 + NULL AS plus,
       NULL = NULL AS equals, NULL IS NULL AS is_null;
/* postgres:
 concat | plus | equals | is_null 
--------+------+--------+---------
 NULL   | NULL | NULL   | t

   sqlite3:
concat  plus  equals  is_null
------  ----  ------  -------
NULL    NULL  NULL    1
*/

-- 5 rows have an id, but only 3 survive: NULL <> 1 is NULL, not TRUE.
SELECT count(*) FROM basket_a WHERE id <> 1;
/* postgres:
 count 
-------
     3

   sqlite3:
count(*)
--------
3
*/

-- ### Aggregates skip NULLs, count(*) doesn't

SELECT count(*), count(id), count(fruit_a), count(DISTINCT id),
       sum(id), max(fruit_a)
FROM basket_a;
/* postgres:
 count | count | count | count | sum |  max   
-------+-------+-------+-------+-----+--------
     7 |     5 |     5 |     4 |  11 | Orange

   sqlite3:
count(*)  count(id)  count(fruit_a)  count(DISTINCT id)  sum(id)  max(fruit_a)
--------  ---------  --------------  ------------------  -------  ------------
7         5          5               4                   11       Orange
*/

-- His Problem 1: the two NULL ids become 1s, so 11 + 2 = 13.
SELECT sum(COALESCE(id, 1)) FROM basket_a;
/* postgres:
 sum 
-----
  13

   sqlite3:
sum(COALESCE(id, 1))
--------------------
13
*/

-- ### CASE and COALESCE

SELECT sum(CASE WHEN fruit_a = 'Apple' THEN 1 ELSE 0 END) AS apples_sum,
       count(CASE WHEN fruit_a = 'Apple' THEN 1 END)      AS apples_count
FROM basket_a;
/* postgres:
 apples_sum | apples_count 
------------+--------------
          2 |            2

   sqlite3:
apples_sum  apples_count
----------  ------------
2           2
*/

SELECT id, fruit_a,
       CASE WHEN id >= 3 THEN 'big' WHEN id >= 1 THEN 'small' END AS size,
       COALESCE(fruit_a, 'unknown') AS fruit
FROM basket_a
ORDER BY id;
/* postgres:
  id  | fruit_a  | size  |  fruit   
------+----------+-------+----------
    1 | Apple    | small | Apple
    1 | Apple    | small | Apple
    2 | Orange   | small | Orange
    3 | Banana   | big   | Banana
    4 | NULL     | big   | unknown
 NULL | Cucumber | NULL  | Cucumber
 NULL | NULL     | NULL  | unknown

   sqlite3:
id    fruit_a   size   fruit   
----  --------  -----  --------
NULL  Cucumber  NULL   Cucumber
NULL  NULL      NULL   unknown 
1     Apple     small  Apple   
1     Apple     small  Apple   
2     Orange    small  Orange  
3     Banana    big    Banana  
4     NULL      big    unknown
*/

-- ### LIKE vs ILIKE

SELECT count(*) FROM basket_a WHERE fruit_a LIKE '%a%';
/* postgres:
 count 
-------
     2

   sqlite3:
count(*)
--------
4
*/

-- His Problem 2
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE '%a%';
/* postgres:
 count 
-------
     4

   sqlite3:
Parse error near line 2: near "ILIKE": syntax error
*/

-- ### GROUP BY, WHERE vs HAVING

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(*) >= 1
ORDER BY fruit_a;
/* postgres:
 fruit_a  | count 
----------+-------
 Apple    |     2
 Banana   |     1
 Cucumber |     1
 Orange   |     1
 NULL     |     2

   sqlite3:
fruit_a   count(*)
--------  --------
NULL      2       
Apple     2       
Banana    1       
Cucumber  1       
Orange    1
*/

-- An aggregate in WHERE is an error on both engines.
SELECT fruit_a FROM basket_a WHERE count(*) > 1 GROUP BY fruit_a;
/* postgres:
ERROR:  aggregate functions are not allowed in WHERE

   sqlite3:
Parse error near line 2: misuse of aggregate: count()
*/

-- ### Joins are a cross join plus a filter

-- His Problem 3: the two id-1 rows match each other 2 x 2 = 4, plus ids 2, 3, 4.
SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id);
/* postgres:
 count 
-------
     7

   sqlite3:
count(*)
--------
7
*/

-- NATURAL JOIN joins on every shared column name. Here that's only id.
-- Avoid it in real code: adding a column silently changes the join.
SELECT count(*) FROM basket_a NATURAL JOIN basket_b;
/* postgres:
 count 
-------
     5

   sqlite3:
count(*)
--------
5
*/

-- ### Window functions (his Problem 4 was lag)

-- ### Views, CTEs and functions

DROP VIEW IF EXISTS apples;
CREATE VIEW apples AS SELECT * FROM basket_a WHERE fruit_a = 'Apple';
SELECT count(*) FROM apples NATURAL JOIN basket_b;
/* postgres:
 count 
-------
     2


   sqlite3:
count(*)
--------
2
*/

WITH large_a AS (
    SELECT * FROM basket_a WHERE id >= 2
)
SELECT count(*) FROM large_a;
/* postgres:
 count 
-------
     3

   sqlite3:
count(*)
--------
3
*/

------------------------------------------------------------------------------
-- Quiz 2: subqueries, set operations, outer joins, recursion
------------------------------------------------------------------------------

-- ### Subqueries

-- mid 15 is duplicated, so this subquery returns 2 rows.
SELECT name FROM session
WHERE sid = (SELECT sid FROM message WHERE mid = 15);
/* postgres:
ERROR:  more than one row returned by a subquery used as an expression

   sqlite3:
name
----
c
*/

SELECT count(*) FROM (SELECT DISTINCT sid FROM message) t;
/* postgres:
 count 
-------
     5

   sqlite3:
count(*)
--------
5
*/

-- ### Set operations stack results vertically

-- His Problem 1
SELECT count(*) FROM (
    SELECT model_id FROM message
    UNION ALL
    SELECT sid FROM session
) t;
/* postgres:
ERROR:  UNION types text and integer cannot be matched

   sqlite3:
count(*)
--------
28
*/

SELECT sid FROM message
UNION
SELECT sid FROM session
ORDER BY 1;
/* postgres:
 sid  
------
    1
    2
    3
    4
    5
    9
 NULL

   sqlite3:
sid 
----
NULL
1   
2   
3   
4   
5   
9
*/

-- Try INTERSECT, and price EXCEPT message, too.
SELECT model_id FROM message
EXCEPT
SELECT model_id FROM price
ORDER BY 1;
/* postgres:
 model_id 
----------
 mistral
 NULL

   sqlite3:
model_id
--------
NULL    
mistral
*/

-- ### Outer joins: the inner join plus the unmatched rows

-- ### Anti-joins: NOT IN vs LEFT JOIN ... IS NULL

-- ### Recursive CTEs: walking the conversation tree

------------------------------------------------------------------------------
-- Quiz 3: bytes per row
------------------------------------------------------------------------------

-- ### Rest of Topic 06, short-answer level

------------------------------------------------------------------------------
-- DataLemur walkthroughs
------------------------------------------------------------------------------

-- ### Page With No Likes Quiz 2 anti-join

SELECT p.page_id
FROM pages p
LEFT JOIN page_likes l ON p.page_id = l.page_id
WHERE l.page_id IS NULL
ORDER BY p.page_id;
/* postgres:
 page_id 
---------
   20701

   sqlite3:
page_id
-------
20701
*/

-- ### Laptop vs. Mobile Viewership Quiz 1 CASE inside sum

SELECT
  sum(CASE WHEN device_type = 'laptop' THEN 1 ELSE 0 END)             AS laptop_views,
  sum(CASE WHEN device_type IN ('tablet', 'phone') THEN 1 ELSE 0 END) AS mobile_views
FROM viewership;
/* postgres:
 laptop_views | mobile_views 
--------------+--------------
            2 |            3

   sqlite3:
laptop_views  mobile_views
------------  ------------
2             3
*/

-- ### Histogram of Tweets Quiz 1 GROUP BY + Quiz 2 subquery in FROM

SELECT tweet_bucket, count(*) AS users_num
FROM (
    SELECT user_id, count(*) AS tweet_bucket
    FROM tweets
    WHERE tweet_date >= '2022-01-01' AND tweet_date < '2023-01-01'
    GROUP BY user_id
) t
GROUP BY tweet_bucket
ORDER BY tweet_bucket;
/* postgres:
 tweet_bucket | users_num 
--------------+-----------
            1 |         2
            2 |         1

   sqlite3:
tweet_bucket  users_num
------------  ---------
1             2        
2             1
*/

-- ### User's Third Transaction Quiz 1 window functions

SELECT user_id, spend, transaction_date
FROM (
    SELECT *, row_number() OVER (PARTITION BY user_id ORDER BY transaction_date) AS rn
    FROM transactions
) t
WHERE rn = 3;
/* postgres:
 user_id | spend |  transaction_date   
---------+-------+---------------------
     111 |  89.6 | 2022-02-05 12:00:00

   sqlite3:
user_id  spend  transaction_date   
-------  -----  -------------------
111      89.6   2022-02-05 12:00:00
*/

------------------------------------------------------------------------------
-- Practice tracker
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Quiz-day checklist
------------------------------------------------------------------------------
