-- Sample SQL: Create Package Specification
-- This file demonstrates package structure and declarations

CREATE OR REPLACE PACKAGE hr_management AS

    -- Constants
    g_package_version CONSTANT VARCHAR2(10) := '1.0.0';
    g_min_salary CONSTANT NUMBER := 1000;
    g_max_salary CONSTANT NUMBER := 999999;

    -- Type definitions
    TYPE employee_record IS RECORD (
        employee_id employees.employee_id % TYPE,
        first_name employees.first_name % TYPE,
        last_name employees.last_name % TYPE,
        email employees.email % TYPE,
        department_name departments.department_name % TYPE,
        salary employees.salary % TYPE
    );

    TYPE employee_table IS TABLE OF EMPLOYEE_RECORD;

    TYPE department_summary IS RECORD (
        department_id departments.department_id % TYPE,
        department_name departments.department_name % TYPE,
        employee_count NUMBER,
        avg_salary NUMBER,
        min_salary NUMBER,
        max_salary NUMBER
    );

    -- Procedure declarations
    PROCEDURE HIRE_NEW_EMPLOYEE(
        p_first_name IN employees.first_name % TYPE,
        p_last_name IN employees.last_name % TYPE,
        p_email IN employees.email % TYPE,
        p_job_id IN employees.job_id % TYPE,
        p_salary IN employees.salary % TYPE,
        p_department_id IN employees.department_id % TYPE,
        p_employee_id OUT employees.employee_id % TYPE
    );

    PROCEDURE TERMINATE_EMPLOYEE(
        p_employee_id IN employees.employee_id % TYPE,
        p_termination_date IN DATE
    );

    PROCEDURE UPDATE_SALARY(
        p_employee_id IN employees.employee_id % TYPE,
        p_new_salary IN employees.salary % TYPE
    );

    PROCEDURE ASSIGN_TO_PROJECT(
        p_employee_id IN employees.employee_id % TYPE,
        p_project_id IN projects.project_id % TYPE,
        p_role IN project_assignments.role % TYPE
    );

    -- Function declarations
    FUNCTION GET_EMPLOYEE_INFO(
        p_employee_id IN employees.employee_id % TYPE
    ) RETURN EMPLOYEE_RECORD;

    FUNCTION GET_DEPARTMENT_SUMMARY(
        p_department_id IN departments.department_id % TYPE
    ) RETURN DEPARTMENT_SUMMARY;

    FUNCTION CALCULATE_PAYROLL(
        p_employee_id IN employees.employee_id % TYPE
    ) RETURN NUMBER;

    FUNCTION IS_VALID_EMAIL(
        p_email IN VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION GET_ALL_EMPLOYEES RETURN EMPLOYEE_TABLE;

END hr_management;


-- Package Body
CREATE OR REPLACE PACKAGE BODY hr_management AS

    -- Private procedure
    PROCEDURE LOG_ACTION(
        p_action IN VARCHAR2,
        p_details IN VARCHAR2
    ) AS
    BEGIN
        INSERT INTO audit_log (
            action,
            details,
            created_date
        ) VALUES (
            p_action,
            p_details,
            SYSDATE
        );
        COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
    END log_action;

    -- Implementation of hire_new_employee
    PROCEDURE HIRE_NEW_EMPLOYEE(
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
        IF NOT IS_VALID_EMAIL(p_email) THEN
            RAISE_APPLICATION_ERROR(-20010, 'Invalid email format');
        END IF;

        IF p_salary < g_min_salary OR p_salary > g_max_salary THEN
            RAISE_APPLICATION_ERROR(-20011, 'Salary out of valid range');
        END IF;

        SELECT MAX(employee_id) + 1
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
            TRUNC(SYSDATE)
        );

        p_employee_id := l_next_id;
        LOG_ACTION('HIRE', 'Employee ' || l_next_id || ' hired');
        COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                LOG_ACTION('ERROR', sqlcode || ' - ' || sqlerrm);
                RAISE;
    END hire_new_employee;

    -- Implementation of terminate_employee
    PROCEDURE TERMINATE_EMPLOYEE(
        p_employee_id IN employees.employee_id % TYPE,
        p_termination_date IN DATE
    ) AS
    BEGIN
        UPDATE employees
        SET updated_date = CURRENT_TIMESTAMP
        WHERE employee_id = p_employee_id;

        LOG_ACTION('TERMINATE', 'Employee ' || p_employee_id || ' terminated');
        COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
    END terminate_employee;

    -- Implementation of update_salary
    PROCEDURE UPDATE_SALARY(
        p_employee_id IN employees.employee_id % TYPE,
        p_new_salary IN employees.salary % TYPE
    ) AS
    BEGIN
        UPDATE employees
        SET
            salary = p_new_salary,
            updated_date = CURRENT_TIMESTAMP
        WHERE employee_id = p_employee_id;

        LOG_ACTION('SALARY_UPDATE', 'Employee ' || p_employee_id);
        COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
    END update_salary;

    -- Implementation of assign_to_project
    PROCEDURE ASSIGN_TO_PROJECT(
        p_employee_id IN employees.employee_id % TYPE,
        p_project_id IN projects.project_id % TYPE,
        p_role IN project_assignments.role % TYPE
    ) AS
    BEGIN
        INSERT INTO project_assignments (
            assignment_id,
            employee_id,
            project_id,
            role,
            start_date
        ) VALUES (
            (SELECT MAX(assignment_id) + 1 FROM project_assignments),
            p_employee_id,
            p_project_id,
            p_role,
            TRUNC(SYSDATE)
        );

        LOG_ACTION('PROJECT_ASSIGN', 'Employee ' || p_employee_id);
        COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
    END assign_to_project;

    -- Implementation of get_employee_info
    FUNCTION GET_EMPLOYEE_INFO(
        p_employee_id IN employees.employee_id % TYPE
    ) RETURN EMPLOYEE_RECORD AS
        l_employee EMPLOYEE_RECORD;
    BEGIN
        SELECT
            e.employee_id,
            e.first_name,
            e.last_name,
            e.email,
            d.department_name,
            e.salary
        INTO l_employee
        FROM employees e
        LEFT JOIN departments d ON e.department_id = d.department_id
        WHERE e.employee_id = p_employee_id;

        RETURN l_employee;

        EXCEPTION
            WHEN no_data_found THEN
                RETURN NULL;
    END get_employee_info;

    -- Implementation of get_department_summary
    FUNCTION GET_DEPARTMENT_SUMMARY(
        p_department_id IN departments.department_id % TYPE
    ) RETURN DEPARTMENT_SUMMARY AS
        l_summary DEPARTMENT_SUMMARY;
    BEGIN
        SELECT
            p_department_id,
            d.department_name,
            COUNT(e.employee_id),
            ROUND(AVG(e.salary), 2),
            MIN(e.salary),
            MAX(e.salary)
        INTO l_summary
        FROM departments d
        LEFT JOIN employees e ON d.department_id = e.department_id
        WHERE d.department_id = p_department_id
        GROUP BY d.department_id, d.department_name;

        RETURN l_summary;

        EXCEPTION
            WHEN no_data_found THEN
                RETURN NULL;
    END get_department_summary;

    -- Implementation of calculate_payroll
    FUNCTION CALCULATE_PAYROLL(
        p_employee_id IN employees.employee_id % TYPE
    ) RETURN NUMBER AS
        l_salary employees.salary % TYPE;
    BEGIN
        SELECT salary
        INTO l_salary
        FROM employees
        WHERE employee_id = p_employee_id;

        RETURN ROUND(l_salary / 12, 2);

        EXCEPTION
            WHEN no_data_found THEN
                RETURN 0;
    END calculate_payroll;

    -- Implementation of is_valid_email
    FUNCTION IS_VALID_EMAIL(
        p_email IN VARCHAR2
    ) RETURN BOOLEAN AS
    BEGIN
        IF INSTR(p_email, '@') > 0
        AND INSTR(p_email, '.') > INSTR(p_email, '@') THEN
            RETURN TRUE;
        END IF;
        RETURN FALSE;
    END is_valid_email;

    -- Implementation of get_all_employees
    FUNCTION GET_ALL_EMPLOYEES RETURN EMPLOYEE_TABLE AS
        l_employees EMPLOYEE_TABLE;
    BEGIN
        SELECT
            EMPLOYEE_RECORD(
                e.employee_id,
                e.first_name,
                e.last_name,
                e.email,
                COALESCE(d.department_name, 'Unknown'),
                e.salary
            )
        BULK COLLECT INTO l_employees
        FROM employees e
        LEFT JOIN departments d ON e.department_id = d.department_id
        ORDER BY e.employee_id;

        RETURN l_employees;

        EXCEPTION
            WHEN OTHERS THEN
                RETURN EMPLOYEE_TABLE();
    END get_all_employees;

END hr_management;
