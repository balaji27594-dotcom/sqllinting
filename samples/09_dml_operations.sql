-- Sample SQL: DML Operations (INSERT, UPDATE, DELETE)
-- This file demonstrates data manipulation operations
 
-- Sample INSERT statements
INSERT INTO departments (
    department_id,
    department_name,
    location_id
) VALUES (
    1,
    'Human Resources',
    100
);

INSERT INTO departments (
    department_id,
    department_name,
    location_id
) VALUES (
    2,
    'Information Technology',
    100
);

INSERT INTO departments (
    department_id,
    department_name,
    location_id
) VALUES (
    3,
    'Finance',
    100
);

-- INSERT with subquery
INSERT INTO employees (
    employee_id,
    first_name,
    last_name,
    email,
    job_id,
    salary,
    department_id,
    hire_date
)
SELECT
    employee_id_seq.nextval,
    'John',
    'Doe',
    'john.doe@company.com',
    'IT001',
    85000,
    departments.department_id
FROM departments
WHERE departments.department_name = 'Information Technology';

-- Bulk INSERT with multiple rows
INSERT ALL
INTO employees (
    employee_id,
    first_name,
    last_name,
    email,
    job_id,
    salary,
    department_id,
    hire_date
)
VALUES (
    employee_id_seq.nextval,
    'Jane',
    'Smith',
    'jane.smith@company.com',
    'IT002',
    95000,
    2,
    SYSDATE
)
INTO employees (
    employee_id,
    first_name,
    last_name,
    email,
    job_id,
    salary,
    department_id,
    hire_date
)
VALUES (
    employee_id_seq.nextval,
    'Mike',
    'Johnson',
    'mike.johnson@company.com',
    'FIN001',
    75000,
    3,
    SYSDATE
)
INTO employees (
    employee_id,
    first_name,
    last_name,
    email,
    job_id,
    salary,
    department_id,
    hire_date
)
VALUES (
    employee_id_seq.nextval,
    'Sarah',
    'Williams',
    'sarah.williams@company.com',
    'HR001',
    65000,
    1,
    SYSDATE
)
SELECT * FROM dual;

-- UPDATE single table
UPDATE employees
SET salary = salary * 1.10
WHERE
    department_id = 2
    AND hire_date > DATE '2020-01-01';

-- UPDATE with subquery
UPDATE employees
SET
    salary = (
        SELECT AVG(salary) * 1.05
        FROM employees
        WHERE department_id = 2
    )
WHERE employee_id IN (
        SELECT employee_id
        FROM employees
        WHERE
            department_id = 2
            AND salary < 80000
    );

-- UPDATE with CASE statement
UPDATE employees
SET
    salary = CASE
        WHEN salary < 50000 THEN salary * 1.15
        WHEN salary < 75000 THEN salary * 1.10
        WHEN salary < 100000 THEN salary * 1.05
        ELSE salary * 1.02
    END,
    updated_date = CURRENT_TIMESTAMP
WHERE hire_date > DATE '2019-01-01';

-- DELETE with WHERE clause
DELETE FROM project_assignments
WHERE
    end_date < ADD_MONTHS(SYSDATE, -12)
    AND project_id IN (
        SELECT project_id
        FROM projects
        WHERE status = 'COMPLETED'
    );

-- DELETE with subquery
DELETE FROM employees
WHERE employee_id NOT IN (
        SELECT DISTINCT employee_id
        FROM project_assignments
    );

-- MERGE operation
MERGE INTO employees tgt
USING (
    SELECT
        1 AS employee_id,
        'Robert' AS first_name,
        'Brown' AS last_name,
        'robert.brown@company.com' AS email,
        'IT003' AS job_id,
        88000 AS salary,
        2 AS department_id,
        SYSDATE AS hire_date
    FROM dual
) src
    ON (tgt.employee_id = src.employee_id)
WHEN MATCHED THEN
    UPDATE SET
        tgt.first_name = src.first_name,
        tgt.last_name = src.last_name,
        tgt.email = src.email,
        tgt.job_id = src.job_id,
        tgt.salary = src.salary,
        tgt.updated_date = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT (
        employee_id,
        first_name,
        last_name,
        email,
        job_id,
        salary,
        department_id,
        hire_date
    ) VALUES (
        src.employee_id,
        src.first_name,
        src.last_name,
        src.email,
        src.job_id,
        src.salary,
        src.department_id,
        src.hire_date
    );

-- Commit changes
COMMIT;
