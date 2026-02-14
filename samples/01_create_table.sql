-- Sample SQL: Create Tables
-- This file demonstrates table creation with various column types and constraints

create table EMPLOYEES (
  EMPLOYEE_ID   number primary key,
first_name   varchar2(50)    not null,
  last_name varchar2(50)NOT NULL,
  email  varchar2(100)  unique,
phone_number varchar2(20),
hire_date  date not null,
job_id varchar2(10) not null,
salary number(8,2),
commission_pct  number(2,2),
manager_id number,
department_id  number not null,
created_date  timestamp default current_timestamp,
updated_date timestamp   default current_timestamp
);

CREATE TABLE departments (
    department_id   NUMBER   PRIMARY KEY,
    department_name VARCHAR2(100)NOT NULL,
    manager_id NUMBER,
    location_id   NUMBER,
    CONSTRAINT fk_dept_manager FOREIGN KEY ( manager_id ) REFERENCES employees ( employee_id )
);

CREATE TABLE projects (
    project_id    NUMBER PRIMARY KEY,
    project_name VARCHAR2(200) NOT NULL,
    description CLOB,
    start_date DATE NOT NULL,
    end_date   DATE,
    budget NUMBER(12,2),
    department_id  NUMBER,
    status VARCHAR2(20)DEFAULT'ACTIVE',
    CONSTRAINT fk_proj_dept FOREIGN KEY(department_id)REFERENCES departments(department_id),
    CONSTRAINT CHK_DATES CHECK(end_date IS NULL OR end_date>=start_date)
);

CREATE TABLE project_assignments (
    assignment_id NUMBER PRIMARY KEY,
    project_id NUMBER NOT NULL,
    employee_id  NUMBER  NOT NULL,
    role VARCHAR2(50),
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT fk_assign_project FOREIGN KEY(project_id)REFERENCES projects(project_id),
    CONSTRAINT fk_assign_employee FOREIGN KEY(employee_id)REFERENCES employees(employee_id),
    CONSTRAINT uk_assign UNIQUE(project_id,employee_id)
);
