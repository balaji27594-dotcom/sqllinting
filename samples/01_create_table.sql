-- Sample SQL: Create Tables
-- This file demonstrates table creation with various column types and constraints

create table EMPLOYEES (
    EMPLOYEE_ID number primary key,
    FIRST_NAME varchar2(50) not null,
    LAST_NAME varchar2(50) not null,
    EMAIL varchar2(100) unique,
    PHONE_NUMBER varchar2(20),
    HIRE_DATE date not null,
    JOB_ID varchar2(10) not null,
    SALARY number(8, 2),
    COMMISSION_PCT number(2, 2),
    MANAGER_ID number,
    DEPARTMENT_ID number not null,
    CREATED_DATE timestamp default current_timestamp,
    UPDATED_DATE timestamp default current_timestamp
);

create table DEPARTMENTS (
    DEPARTMENT_ID NUMBER primary key,
    DEPARTMENT_NAME VARCHAR2(100) not null,
    MANAGER_ID NUMBER,
    LOCATION_ID NUMBER,
    constraint FK_DEPT_MANAGER foreign key (MANAGER_ID) references EMPLOYEES (
        EMPLOYEE_ID
    )
);

create table PROJECTS (
    PROJECT_ID NUMBER primary key,
    PROJECT_NAME VARCHAR2(200) not null,
    DESCRIPTION CLOB,
    START_DATE DATE not null,
    END_DATE DATE,
    BUDGET NUMBER(12, 2),
    DEPARTMENT_ID NUMBER,
    STATUS VARCHAR2(20) default 'ACTIVE',
    constraint FK_PROJ_DEPT foreign key (
        DEPARTMENT_ID
    ) references DEPARTMENTS (DEPARTMENT_ID),
    constraint CHK_DATES check (END_DATE is NULL or END_DATE >= START_DATE)
);

create table PROJECT_ASSIGNMENTS (
    ASSIGNMENT_ID NUMBER primary key,
    PROJECT_ID NUMBER not null,
    EMPLOYEE_ID NUMBER not null,
    ROLE VARCHAR2(50),
    START_DATE DATE not null,
    END_DATE DATE,
    constraint FK_ASSIGN_PROJECT foreign key (PROJECT_ID) references PROJECTS (
        PROJECT_ID
    ),
    constraint FK_ASSIGN_EMPLOYEE foreign key (
        EMPLOYEE_ID
    ) references EMPLOYEES (EMPLOYEE_ID),
    constraint UK_ASSIGN unique (PROJECT_ID, EMPLOYEE_ID)
);
