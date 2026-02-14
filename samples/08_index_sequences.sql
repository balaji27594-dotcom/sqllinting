-- Sample SQL: Indexes and Sequences
-- This file demonstrates index and sequence creation

-- Create Sequences
CREATE SEQUENCE employee_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE department_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE project_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE assignment_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE audit_log_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Create Indexes on Employee table
CREATE INDEX idx_employee_email ON employees(email);

CREATE INDEX idx_employee_department ON employees(department_id);

CREATE INDEX idx_employee_hire_date ON employees(hire_date);

CREATE INDEX idx_employee_manager ON employees(manager_id);

CREATE UNIQUE INDEX idx_employee_unique_email ON employees(email);

-- Create Indexes on Department table
CREATE INDEX idx_department_manager ON departments(manager_id);

-- Create Indexes on Project table
CREATE INDEX idx_project_status ON projects(status);

CREATE INDEX idx_project_department ON projects(department_id);

CREATE INDEX idx_project_dates ON projects(start_date, end_date);

-- Create Indexes on Project Assignments table
CREATE INDEX idx_assignment_project ON project_assignments(project_id);

CREATE INDEX idx_assignment_employee ON project_assignments(employee_id);

CREATE INDEX idx_assignment_dates ON project_assignments(start_date, end_date);

-- Composite indexes
CREATE INDEX idx_assignment_project_emp
ON project_assignments(project_id, employee_id);

-- Create function-based index
CREATE INDEX idx_employee_name_upper
ON employees(UPPER(first_name), UPPER(last_name));

-- Create bitmap indexes (useful for columns with few distinct values)
CREATE BITMAP INDEX idx_project_status_bitmap
ON projects(status);

-- Analyze table for statistics
ANALYZE TABLE employees COMPUTE STATISTICS;
ANALYZE TABLE departments COMPUTE STATISTICS;
ANALYZE TABLE projects COMPUTE STATISTICS;
ANALYZE TABLE project_assignments COMPUTE STATISTICS;
