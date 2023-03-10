-- Solution: LeetCode 185. Department Top Three Salaries
-- This solution is for MySQL 8

-- We begin by loading in our example. (Skip to 33 for solutions if you are working in LeetCode)

CREATE TABLE Employee (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL UNIQUE,
    salary INT,
    departmentId INT
);

INSERT INTO Employee (name, salary, departmentId) VALUES
    ('Joe', 85000, 1),
    ('Henry', 80000, 2),
    ('Sam', 60000, 2),
    ('Max', 90000, 1),
    ('Janet', 69000, 1),
    ('Randy', 85000, 1),
    ('Will', 70000, 1)
;

CREATE TABLE Department (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL UNIQUE
);

INSERT INTO Department (name) VALUES
    ('IT'),
    ('Sales')
;

-- APPROACH 1: JOIN + Subquery

-- A good starting place for this problem is to just select the end data without the problem conditions
-- We need information from both tables so we need to JOIN

SELECT
    d.name AS Department, e.name AS Employee, e.salary AS Salary
FROM
    Employee e
        JOIN
    Department d On e.departmentId = d.id
;

-- Now we move on to the condition, only selecting employees with salaries in the top 3
-- unique salaries for their department
-- Ideally, we want to just use a WHERE clause
-- Now the problem is how to we come up with the appropriate Subquery

-- The trick is to count the number of bigger salaries to determine the ranking
-- We do this by a self-join and come up with our accepted solution
-- (Note the change from e to e1)

SELECT
    d.name AS Department, e1.name AS Employee, e1.salary AS Salary
FROM
    Employee e1
        JOIN
    Department d ON e1.departmentId = d.id
WHERE
    3 > (SELECT
            COUNT(DISTINCT(e2.salary))         -- Count number of distinct salaries
        FROM
            Employee e2
        WHERE
            e2.salary > e1.salary              -- Greater than e1.salary
                AND
            e1.departmentId = e2.departmentId  -- Within the same department
        )
;

-- APPROACH 2: WINDOW FUNCTION

-- Window functions are very useful, they make this problem a lot easier
-- If we find ourselves wanting to group and order but want to avoid a GROUP BY clause,
-- a window function might be useful
-- Here we want to group by departmentId and rank by UNIQUE salary, so we use RANK_DENSE

SELECT Department, Employee, Salary
FROM
	(SELECT
		d.name AS Department,
        e.name AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER (
			PARTITION BY d.name
            ORDER BY e.salary DESC
		) AS drk
	FROM
		Employee e
			JOIN
		Department d ON e.departmentId = d.id
	) AS T
WHERE
	T.drk <= 3
;

