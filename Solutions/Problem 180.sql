-- Solution: LeetCode 180. Consecutive Numbers
-- This solution is for MySQL 8

-- We begin by loading in our example. (Skip to 21 for solutions if you are working in LeetCode)

CREATE TABLE Logs (
	id INT PRIMARY KEY AUTO_INCREMENT UNIQUE,
    num VARCHAR(255) NOT NULL
);

INSERT INTO Logs (num) VALUES
	(1),
    (1),
    (1),
    (2),
    (1),
    (2),
    (2)
;

-- APPROACH 1: QUERY FROM THREE TABLES

-- We want to compare three entries in Logs so we can just query from three copies of Logs
-- We want to find all triples with consectutive ids and the same num

SELECT
	DISTINCT l1.num AS ConsecutiveNums           -- Notice the DISTINCT
FROM
	Logs l1,
    Logs l2,
    Logs l3
WHERE
	l1.id = l2.id - 1
		AND
	l2.id = l3.id - 1
		AND
	l2.num = l2.num
		AND
	l2.num = l3.num
;

-- APPROACH 2: QUERY FROM ONE TABLE

-- It is true that we want to look for three entries, but we know exactly what those entries are
-- For example, for (1, 1), we are looking for (2, 1) and (3, 1)

SELECT
	DISTINCT num AS ConsecutiveNums
FROM
	Logs
WHERE
	(id + 1, num) in (SELECT * FROM Logs)
		AND
	(id + 2, num) in (SELECT * FROM Logs)
;

-- APPROACH: WINDOW FUNCTION

-- Yet, in all these approaches we don't take advantage that the id is AUTO_INCREMENT
-- In the above approaches we search through our tables for what we are looking for
-- Instead, we only need to compare with the next entry, and the one after that
-- We can look at all these entries at once using LAG (or LEAD if you wanted)

SELECT
	DISTINCT T.num AS ConsecutiveNums
FROM
	(SELECT
		num,
        LAG(num, 1) OVER() AS prev1,
        LAG(num, 2) OVER() AS prev2
	FROM
		Logs
	) AS T
WHERE
	T.num = T.prev1
		AND
	T.prev1 = T.prev2
;