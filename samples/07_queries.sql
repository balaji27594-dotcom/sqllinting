-- Sample SQL: SELECT Queries
-- This file demonstrates various query patterns
 
-- Query 1: Simple SELECT with WHERE clause
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    hire_date
FROM employees
WHERE
    salary > 50000
    AND hire_date > DATE '2020-01-01'
ORDER BY salary DESC;

-- Query 2: JOIN with aggregate functions
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) > 0
ORDER BY avg_salary DESC;

-- Query 3: Subquery with CASE statement
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    (
        SELECT COUNT(*)
        FROM project_assignments
        WHERE employee_id = e.employee_id
    ) AS project_count,
    CASE
        WHEN e.salary < 50000 THEN 'Low'
        WHEN e.salary < 75000 THEN 'Medium'
        WHEN e.salary < 100000 THEN 'High'
        ELSE 'Very High'
    END AS salary_level
FROM employees e
WHERE
    e.employee_id IN (
        SELECT DISTINCT employee_id
        FROM project_assignments
        WHERE end_date IS NULL
    )
ORDER BY e.salary DESC;

-- Query 4: Window functions
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name,
    RANK()
        OVER (PARTITION BY e.department_id ORDER BY e.salary DESC)
        AS salary_rank,
    ROUND(
        AVG(e.salary) OVER (PARTITION BY e.department_id),
        2
    ) AS dept_avg_salary,
    e.salary
    - ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2)
        AS diff_from_avg
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
ORDER BY e.department_id ASC, e.salary DESC;

-- Query 5: CTE (Common Table Expression)
WITH active_projects AS (
    SELECT
        project_id,
        project_name,
        department_id
    FROM projects
    WHERE
        status = 'ACTIVE'
        AND end_date IS NULL
),

project_teams AS (
    SELECT
        ap.project_id,
        ap.project_name,
        COUNT(pa.employee_id) AS team_size
    FROM active_projects ap
    LEFT JOIN project_assignments pa ON ap.project_id = pa.project_id
    GROUP BY ap.project_id, ap.project_name
)

SELECT
    pt.project_id,
    pt.project_name,
    pt.team_size,
    d.department_name
FROM project_teams pt
LEFT JOIN active_projects ap ON pt.project_id = ap.project_id
LEFT JOIN departments d ON ap.department_id = d.department_id
WHERE pt.team_size > 0
ORDER BY pt.team_size DESC;

-- Query 6: Self-join for manager hierarchy
SELECT
    e.employee_id,
    m.employee_id AS manager_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    m.first_name || ' ' || m.last_name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.manager_id, e.employee_id;

-- Query 7: UNION query
SELECT
    'Active Projects' AS category,
    COUNT(*) AS count
FROM projects
WHERE status = 'ACTIVE'
UNION ALL
SELECT
    'Completed Projects',
    COUNT(*)
FROM projects
WHERE status = 'COMPLETED'
UNION ALL
SELECT
    'On Hold Projects',
    COUNT(*)
FROM projects
WHERE status = 'ON_HOLD';

-- Query 8: Complex query with multiple JOINs
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name,
    COUNT(pa.assignment_id) AS active_projects,
    MAX(p.end_date) AS latest_project_end
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN project_assignments pa
    ON
        e.employee_id = pa.employee_id
        AND pa.end_date IS NULL
LEFT JOIN projects p ON pa.project_id = p.project_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
HAVING COUNT(pa.assignment_id) > 0
ORDER BY active_projects DESC;
