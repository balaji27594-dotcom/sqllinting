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
    trunc(months_between(sysdate, e.hire_date) / 12) as years_employed
from employees e
inner join departments d on e.department_id = d.department_id;

create or replace view department_statistics_view as
select
    d.department_id,
    d.department_name,
    count(e.employee_id) as total_employees,
    round(avg(e.salary), 2) as avg_salary,
    min(e.salary) as min_salary,
    max(e.salary) as max_salary,
    round(sum(e.salary), 2) as total_payroll
from departments d
left join employees e on d.department_id = e.department_id
group by d.department_id, d.department_name;

create or replace view project_status_view as
select
    p.project_id,
    p.project_name,
    p.start_date,
    p.end_date,
    p.status,
    d.department_name,
    count(distinct pa.employee_id) as team_size
from projects p
left join project_assignments pa on p.project_id = pa.project_id
left join departments d on p.department_id = d.department_id
group by
    p.project_id, p.project_name, p.start_date, p.end_date, p.status, d.department_name;

create or replace view employee_salary_ranges_view as
select
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name,
    case
        when e.salary < 50000 then 'Entry Level'
        when e.salary < 75000 then 'Mid Level'
        when e.salary < 100000 then 'Senior Level'
        else 'Executive Level'
    end as salary_range
from employees e
left join departments d on e.department_id = d.department_id;
