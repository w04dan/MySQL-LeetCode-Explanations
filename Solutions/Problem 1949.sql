-- Solution: LeetCode 1949. Strong Friendship
-- This solution is for MySQL 8

-- We begin by loading in our example. (Skip to 27 for solutions if you are working in LeetCode)

CREATE TABLE Friendship (
	user1_id INT NOT NULL,
    user2_id INT NOT NULL,
    PRIMARY KEY (user1_id, user2_id)
);

INSERT INTO Friendship (user1_id, user2_id) VALUES
	(1, 2),
    (1, 3),
    (2, 3),
    (1, 4),
    (2, 4),
    (1, 5),
    (2, 5),
    (1, 7),
    (3, 7),
    (1, 6),
    (3, 6),
    (2, 6)
;

-- APPROACH 1: SELF UNION AND SELF JOIN

-- The main question is how to count common friends.
-- An immediate problem we face is that sometimes we have common friends on user1_id and sometimes on user2_id
-- For example, we have (1, 5) and (2, 5) with 5 (user2_id) being the common friend of 1 and 2
-- But we also have (3, 6) and (3, 7) with 3 (user1_id) being the common friend of 6 and 7
-- Notable, we do not have (6, 3) and (7, 3), so if we counted common friends in user1_id we would miss out
-- The solution to this is making sure we always have both and considering just one

WITH cte AS (
	SELECT user1_id, user2_id FROM Friendship        -- We add, say (3, 6) and (3, 7)
		UNION
	SELECT user2_id, user1_id FROM Friendship        -- Along with (6, 3) and (7, 3)
)

SELECT * FROM cte;

-- Run this code and look at what the table looks like now.
-- Notice that to find common friends we need to compare friend pairs with other friend pairs
-- For example, we need to look at both (3, 6) and (3, 7) to find 3 is a common friend of 6 and 7
-- This immediately suggests to us we need to self join	

WITH cte AS (
	SELECT user1_id, user2_id FROM Friendship
		UNION
	SELECT user2_id, user1_id FROM Friendship
)

SELECT
	*
FROM
	cte c1
		JOIN
	cte c2
    ON
		c1.user1_id = c2.user1_id       -- With commnon friend on say user1_id
			AND
		c1.user2_id < c2.user2_id       -- Making sure to select only one of the two pairs we now have
;

-- At this point, we simply need to filter to those who are actually friends themselves
-- And then group, count, and get our final solution

WITH cte AS (
	SELECT user1_id, user2_id FROM Friendship
		UNION
	SELECT user2_id, user1_id FROM Friendship
)

SELECT
	c1.user2_id AS user1_id,
    c2.user2_id AS user2_id,
    COUNT(*) AS common_friend
FROM
	cte c1
		JOIN
	cte c2
    ON
		c1.user1_id = c2.user1_id
			AND
		c1.user2_id < c2.user2_id
WHERE
	(c1.user2_id, c2.user2_id) IN (
		SELECT * FROM Friendship           -- Making sure our pair are actually friends
	)
GROUP BY
	c1.user2_id, c2.user2_id
HAVING
	COUNT(*) >= 3                          -- And have at least 3 common friends
;