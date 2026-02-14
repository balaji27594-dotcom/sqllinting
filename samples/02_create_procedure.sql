-- Sample SQL: Create Stored Procedures
-- This file demonstrates various procedure patterns and best practices
 
CREATE OR REPLACE PROCEDURE get_employee_details(
    p_employee_id IN employees.employee_id % TYPE,
    p_first_name OUT employees.first_name % TYPE,
    p_last_name OUT employees.last_name % TYPE,
    p_salary OUT employees.salary % TYPE,
    p_department_name OUT departments.department_name % TYPE
) AS
    l_dept_id employees.department_id % TYPE;
BEGIN
    SELECT
        e.first_name,
        e.last_name,
        e.salary,
        e.department_id
    INTO
    p_first_name,
    p_last_name,
    p_salary,
    l_dept_id
    FROM employees e
    WHERE e.employee_id = e.p_employee_id;

    IF l_dept_id IS NOT NULL THEN
        SELECT d.department_name
        INTO p_department_name
        FROM departments d
        WHERE d.department_id = d.l_dept_id;
    END IF;

    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(-20001, 'Employee not found');
        WHEN OTHERS THEN
            raise_application_error(
                -20002, 'Error retrieving employee details'
            );
END get_employee_details;
/

CREATE OR REPLACE PROCEDURE hire_employee(
    p_first_name IN employees.first_name % TYPE,
    p_last_name IN employees.last_name % TYPE,
    p_email IN employees.email % TYPE,
    p_job_id IN employees.job_id % TYPE,
    p_salary IN employees.salary % TYPE,
    p_department_id IN employees.department_id % TYPE,
    p_employee_id OUT employees.employee_id % TYPE
) AS
    l_next_id NUMBER;
BEGIN
    SELECT coalesce(max(employee_id), 0) + 1
    INTO l_next_id
    FROM employees;

    INSERT INTO employees (
        employee_id,
        first_name,
        last_name,
        email,
        job_id,
        salary,
        department_id,
        hire_date
    ) VALUES (
        l_next_id,
        p_first_name,
        p_last_name,
        p_email,
        p_job_id,
        p_salary,
        p_department_id,
        trunc(sysdate)
    );

    p_employee_id := l_next_id;
    COMMIT;

    EXCEPTION
        WHEN dup_val_on_index THEN
            ROLLBACK;
            raise_application_error(-20003, 'Email already exists');
        WHEN OTHERS THEN
            ROLLBACK;
            raise_application_error(-20004, 'Error hiring employee');
END hire_employee;
/

CREATE OR REPLACE PROCEDURE update_employee_salary(
    p_employee_id IN employees.employee_id % TYPE,
    p_new_salary IN employees.salary % TYPE
) AS
BEGIN
    IF p_new_salary <= 0 THEN
        raise_application_error(-20005, 'Salary must be greater than zero');
    END IF;

    UPDATE employees
    SET
        salary = p_new_salary,
        updated_date = current_timestamp
    WHERE employee_id = p_employee_id;

    IF sql % ROWCOUNT = 0 THEN
        raise_application_error(-20001, 'Employee not found');
    END IF;

    COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            raise_application_error(-20006, 'Error updating salary');
END update_employee_salary;
/
