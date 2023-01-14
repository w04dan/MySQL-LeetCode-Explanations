-- Solution: LeetCode 613. Shortest Distance in a Line
-- This solution is for MySQL 8

-- We begin by loading in our example. (Skip to 16 for solutions if you are working in LeetCode)

CREATE TABLE Point (
	x INT NOT NULL PRIMARY KEY
);

INSERT INTO Point (x) VALUES
	(-1),
    (0),
    (2)
;

-- APPROACH 1: SELF JOIN

-- To find the distance between points, we need to compare the points in Point to themselves
-- We can do this with a self-join, and then taking the distance is straightforward

SELECT
	MIN(ABS(p1.x - p2.x)) AS shortest           -- Literally, the minimum distance (absolute difference)
FROM
	Point p1
		JOIN                                    -- Self-join
	Point p2
WHERE
	p1.x != p2.x                                -- We do not count distances from a point to itself
;

-- This is accepted, but we can make it a bit better by taking into account symmetry
-- If we take the distance from x1 to x2, we don't need to take the distance from x2 to x1 as well

SELECT
	MIN(p1.x - p2.x) AS shortest
FROM
	Point p1
		JOIN
	Point p2
WHERE
	p1.x > p2.x                                 -- We only consider when x1 > x2
;

-- APPROACH 2: WINDOW FUNCTION

-- As is often the case, window functions make things a lot easier
-- Notice, if the points are sorted, then we only need to consider the distance between consecutive points
-- Consider three points on the number line from left to right, x1, x2, and x3. There is no way the distance
-- from x1 to x3 is smaller than the distance from x1 to x2.
-- To work with data offset by some amount, we can use LEAD or LAG

SELECT
	MIN(T.distance) AS shortest
FROM
	(SELECT
		x,
        x - LAG(x, 1) OVER (                  -- Distance is a point minus the previous point along the line
			ORDER BY x ASC                    -- Note we must have the points be ordered
		) AS distance
	FROM
		Point
	) AS T
;

-- FOLLOW UP:

-- The follow up asks what about if x in Point was sorted in ascending order
-- Well then, we wouldn't have to order it in our window function

SELECT
	MIN(T.distance) AS shortest
FROM
	(SELECT
		x,
        x - LAG(x, 1) OVER () AS distance          -- Note window functions still need OVER (), even though
	FROM                                           -- PARTITION BY and ORDER BY are optional
		Point
	) AS T
;
