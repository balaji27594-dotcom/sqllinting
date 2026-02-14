-- Sample SQL: Create Views
-- This file demonstrates various view patterns

create or replace view employee_details_view as
select
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
    trunc(months_between(sysdate,e.hire_date)/12)as years_employed
from employees e
join departments d on e.department_id=d.department_id;

create or replace view department_statistics_view as
select
    d.department_id,
    d.department_name,
    count(e.employee_id)as total_employees,
    round(avg(e.salary),2)as avg_salary,
    min(e.salary)as  min_salary,
    max(e.salary)as max_salary,
    round(sum(e.salary),2)as total_payroll
from departments d
left join employees e on d.department_id=e.department_id
group by d.department_id,d.department_name;

CREATE OR REPLACE VIEW project_status_view AS
SELECT
    p.project_id,
    p.project_name,
    p.start_date,
    p.end_date,
    p.status,
    d.department_name,
    COUNT(DISTINCT pa.employee_id) AS team_size
FROM projects p
LEFT JOIN project_assignments pa ON p.project_id = pa.project_id
LEFT JOIN departments d ON p.department_id = d.department_id
GROUP BY
    p.project_id, p.project_name, p.start_date, p.end_date, p.status, d.department_name;

CREATE OR REPLACE VIEW employee_salary_ranges_view AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name,
    CASE
        WHEN e.salary < 50000 THEN 'Entry Level'
        WHEN e.salary < 75000 THEN 'Mid Level'
        WHEN e.salary < 100000 THEN 'Senior Level'
        ELSE 'Executive Level'
    END AS salary_range
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
