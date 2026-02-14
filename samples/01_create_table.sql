-- Sample SQL: Create Tables
-- This file demonstrates table creation with various column types and constraints
 
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR2(10) NOT NULL,
    salary NUMBER(8, 2),
    commission_pct NUMBER(2, 2),
    manager_id NUMBER,
    department_id NUMBER NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE departments (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL,
    manager_id NUMBER,
    location_id NUMBER,
    CONSTRAINT fk_dept_manager FOREIGN KEY (manager_id) REFERENCES employees (
        employee_id
    )
);

CREATE TABLE projects (
    project_id NUMBER PRIMARY KEY,
    project_name VARCHAR2(200) NOT NULL,
    description CLOB,
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMBER(12, 2),
    department_id NUMBER,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    CONSTRAINT fk_proj_dept FOREIGN KEY (
        department_id
    ) REFERENCES departments (department_id),
    CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE project_assignments (
    assignment_id NUMBER PRIMARY KEY,
    project_id NUMBER NOT NULL,
    employee_id NUMBER NOT NULL,
    role VARCHAR2(50),
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT fk_assign_project FOREIGN KEY (project_id) REFERENCES projects (
        project_id
    ),
    CONSTRAINT fk_assign_employee FOREIGN KEY (
        employee_id
    ) REFERENCES employees (employee_id),
    CONSTRAINT uk_assign UNIQUE (project_id, employee_id)
);
