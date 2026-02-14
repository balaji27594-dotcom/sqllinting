-- Sample SQL: Create Triggers
-- This file demonstrates various trigger patterns
 
CREATE OR REPLACE TRIGGER employees_before_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF: NEW.employee_id IS NULL THEN
        SELECT COALESCE(MAX(employee_id), 0) + 1
        INTO: NEW.employee_id
        FROM employees;
    END IF;

    IF: NEW.created_date IS NULL THEN
        : NEW.created_date := CURRENT_TIMESTAMP;
    END IF;

    IF: NEW.updated_date IS NULL THEN
        : NEW.updated_date := CURRENT_TIMESTAMP;
    END IF;

    IF: NEW.salary < 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Salary cannot be negative');
    END IF;
END employees_before_insert;
/

CREATE OR REPLACE TRIGGER employees_before_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    : NEW.updated_date := CURRENT_TIMESTAMP;

    IF: NEW.salary < 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Salary cannot be negative');
    END IF;

    IF: NEW.employee_id !=: OLD.employee_id THEN
        RAISE_APPLICATION_ERROR(-20101, 'Employee ID cannot be changed');
    END IF;
END employees_before_update;
/

CREATE OR REPLACE TRIGGER employees_after_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        action,
        table_name,
        record_id,
        details,
        created_date
    ) VALUES (
        'INSERT',
        'EMPLOYEES',
        : NEW.employee_id,
        'New employee: ' ||: NEW.first_name || ' ' ||: NEW.last_name,
        SYSDATE
    );
END employees_after_insert;
/

CREATE OR REPLACE TRIGGER employees_after_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF: NEW.salary !=: OLD.salary THEN
        INSERT INTO salary_change_log (
            employee_id,
            old_salary,
            new_salary,
            change_date
        ) VALUES (
            : NEW.employee_id,
            : OLD.salary,
            : NEW.salary,
            SYSDATE
        );
    END IF;

    IF: NEW.department_id !=: OLD.department_id THEN
        INSERT INTO audit_log (
            action,
            table_name,
            record_id,
            details,
            created_date
        ) VALUES (
            'UPDATE',
            'EMPLOYEES',
            : NEW.employee_id,
            'Department changed from '
            ||: OLD.department_id
            || ' to '
            ||: NEW.department_id,
            SYSDATE
        );
    END IF;
END employees_after_update;
/

CREATE OR REPLACE TRIGGER employees_after_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        action,
        table_name,
        record_id,
        details,
        created_date
    ) VALUES (
        'DELETE',
        'EMPLOYEES',
        : OLD.employee_id,
        'Employee deleted: ' ||: OLD.first_name || ' ' ||: OLD.last_name,
        SYSDATE
    );
END employees_after_delete;
/

CREATE OR REPLACE TRIGGER projects_status_update
BEFORE UPDATE OF status ON projects
FOR EACH ROW
BEGIN
    IF: NEW.status NOT IN ('ACTIVE', 'ON_HOLD', 'COMPLETED', 'CANCELLED') THEN
        RAISE_APPLICATION_ERROR(-20102, 'Invalid project status');
    END IF;

    IF: NEW.status = 'COMPLETED' AND: NEW.end_date IS NULL THEN
        : NEW.end_date := TRUNC(SYSDATE);
    END IF;
END projects_status_update;
/
