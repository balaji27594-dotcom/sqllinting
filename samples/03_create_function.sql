-- Sample SQL: Create Functions
-- This file demonstrates various function patterns

CREATE OR REPLACE FUNCTION get_employee_age (
    p_employee_id IN employees.employee_id%TYPE
) RETURN NUMBER AS
    l_hire_date DATE;
    l_age NUMBER;
BEGIN
    SELECT hire_date
    INTO l_hire_date
    FROM employees
    WHERE employee_id = p_employee_id;

    l_age := TRUNC(MONTHS_BETWEEN(SYSDATE, l_hire_date) / 12);

    RETURN l_age;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END get_employee_age;
/

CREATE OR REPLACE FUNCTION calculate_bonus (
    p_salary IN employees.salary%TYPE,
    p_performance_rating IN VARCHAR2
) RETURN NUMBER AS
    l_bonus_percentage NUMBER;
BEGIN
    CASE p_performance_rating
        WHEN 'EXCELLENT' THEN
            l_bonus_percentage := 0.20;
        WHEN 'GOOD' THEN
            l_bonus_percentage := 0.15;
        WHEN 'AVERAGE' THEN
            l_bonus_percentage := 0.10;
        ELSE
            l_bonus_percentage := 0.05;
    END CASE;

    RETURN ROUND(p_salary * l_bonus_percentage, 2);

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END calculate_bonus;
/

CREATE OR REPLACE FUNCTION format_employee_name (
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
    RETURN TRIM(UPPER(p_last_name)) || ', ' || TRIM(INITCAP(p_first_name));
END format_employee_name;
/

CREATE OR REPLACE FUNCTION get_department_headcount (
    p_department_id IN departments.department_id%TYPE
) RETURN NUMBER AS
    l_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO l_count
    FROM employees
    WHERE department_id = p_department_id
        AND employee_id IN (
            SELECT employee_id
            FROM employees
            WHERE hire_date <= SYSDATE
        );

    RETURN l_count;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1;
END get_department_headcount;
/
