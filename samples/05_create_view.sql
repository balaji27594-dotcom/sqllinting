-- Sample SQL: Create Views
-- This file demonstrates various view patterns

CREATE OR REPLACE VIEW employee_details_view AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.phone_number,
    e.hire_date,
    e.job_id,
    e.salary,
    e.commission_pct,
    d.department_id,
    d.department_name,
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS years_employed
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

CREATE OR REPLACE VIEW department_statistics_view AS
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS total_employees,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    ROUND(SUM(e.salary), 2) AS total_payroll
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;

CREATE OR REPLACE VIEW project_status_view AS
SELECT
    p.project_id,
    p.project_name,
    p.start_date,
    p.end_date,
    p.status,
    COUNT(DISTINCT pa.employee_id) AS team_size,
    d.department_name
FROM projects p
LEFT JOIN project_assignments pa ON p.project_id = pa.project_id
LEFT JOIN departments d ON p.department_id = d.department_id
GROUP BY p.project_id, p.project_name, p.start_date, p.end_date, p.status, d.department_name;

CREATE OR REPLACE VIEW employee_salary_ranges_view AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    CASE
        WHEN e.salary < 50000 THEN 'Entry Level'
        WHEN e.salary < 75000 THEN 'Mid Level'
        WHEN e.salary < 100000 THEN 'Senior Level'
        ELSE 'Executive Level'
    END AS salary_range,
    d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
