SET SERVEROUTPUT ON;

-- Create users
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

DROP USER Prod CASCADE;
DROP USER Dev CASCADE;

CREATE USER Prod IDENTIFIED BY password;
CREATE USER Dev IDENTIFIED BY password;

GRANT CONNECT, RESOURCE TO Prod;
GRANT CONNECT, RESOURCE TO Dev;

/*connect dev/password@localhost/xepdb1;
connect prod/password@localhost/xepdb1;*/
connect sys/password@localhost/xepdb1 as sysdba;

DROP TABLE diff_tables;
DROP TABLE out_tables;

CREATE TABLE diff_tables (
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(100)
);

CREATE TABLE out_tables (
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(100)
);

/*BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

CREATE TABLE Dev.Table1 (id NUMBER);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

CREATE TABLE Prod.Table1 (id NUMBER);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

CREATE TABLE Dev.Table2 (id NUMBER);
CREATE TABLE Dev.Table3 (id NUMBER);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

DROP TABLE Prod.Table1;
CREATE TABLE Prod.Table1 (id VARCHAR2(10));

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

DROP TABLE Prod.Table1;
DROP TABLE Dev.Table1;
DROP TABLE Dev.Table2;
DROP TABLE Dev.Table3;*/

-- task 1
DROP TABLE dev.groups;
DROP TABLE prod.groups;
DROP TABLE dev.students;
DROP TABLE dev.test1 CASCADE CONSTRAINTS;
DROP TABLE dev.test2 CASCADE CONSTRAINTS;

CREATE TABLE dev.groups (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(20) NOT NULL,
    c_val NUMBER NOT NULL
);

CREATE TABLE prod.groups (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(30) NOT NULL,
    c_val NUMBER NOT NULL
);

CREATE TABLE dev.students (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(20) NOT NULL,
    group_id NUMBER NOT NULL
);

CREATE TABLE dev.test1 (
    id NUMERIC(10) NOT NULL,
    col1 VARCHAR2(20) NOT NULL,
    col2 VARCHAR(20),
    CONSTRAINT test1_pk PRIMARY KEY(id)
);

CREATE TABLE dev.test2 ( 
    id NUMERIC(10) NOT NULL,
    test1_id NUMERIC(10) NOT NULL,
    CONSTRAINT test1_fk FOREIGN KEY(test1_id)
        REFERENCES  dev.test1(id)
);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

SELECT * FROM out_tables;

-- cycle
DROP TABLE dev.department CASCADE CONSTRAINT;
DROP TABLE dev.Employee CASCADE CONSTRAINT;
DROP TABLE dev.task CASCADE CONSTRAINT;

CREATE TABLE Dev.Department (
  id NUMBER(10) PRIMARY KEY,
  name VARCHAR2(100)
);

CREATE TABLE Dev.Employee (
    id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100),
    department_id NUMBER(10),
    CONSTRAINT FK_Employee_Department FOREIGN KEY(department_id)
        REFERENCES Dev.Department(id)
);

CREATE TABLE Dev.Task (
    id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100),
    employee_id NUMBER(10),
    CONSTRAINT FK_Task_Employee FOREIGN KEY(employee_id)
        REFERENCES Dev.Employee(id)
);

ALTER TABLE Dev.Department ADD CONSTRAINT FK_Department_Task FOREIGN KEY(id)
    REFERENCES Dev.Task(id);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

-- task 2
DROP TABLE diff_tables;
DROP TABLE out_tables;

CREATE TABLE diff_tables (
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(100)
);

CREATE TABLE out_tables (
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(100)
);

DROP FUNCTION dev.test_func;
DROP FUNCTION prod.test_func;
DROP PROCEDURE prod.test_proc;
DROP PROCEDURE dev.test_proc;

CREATE OR REPLACE FUNCTION dev.test_func
    RETURN NUMBER
IS
    val1 NUMBER;
    val2 NUMBER;
BEGIN
    dbms_output.put_line('dev.test_func');
    RETURN 1;
END test_func;

CREATE OR REPLACE FUNCTION prod.test_func(
    param1 IN NUMBER,
    param2 IN VARCHAR2
) RETURN NUMBER
IS
    val1 NUMBER;
    val2 NUMBER;
BEGIN
    dbms_output.put_line('prod.test_func');
    RETURN 1;
END test_func;

CREATE OR REPLACE PROCEDURE dev.test_proc(
    param1 IN NUMBER,
    param2 IN VARCHAR2
) 
IS
    val NUMBER;
BEGIN
    dbms_output.put_line('dev.test_proc');
END test_proc;

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

DROP TABLE Dev.test_table;
DROP TABLE Prod.test_table;

CREATE TABLE Dev.test_table (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100)
);

CREATE TABLE Prod.test_table (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100)
);

DROP INDEX Dev.test_table_idx2;

CREATE INDEX Dev.test_table_idx1 ON Dev.test_table(name);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

-- task 3

DROP TABLE Dev.test_table;
DROP TABLE Dev.test_table2;
DROP TABLE Prod.test_table;
DROP TABLE Prod.test_table2;

CREATE TABLE Dev.test_table (id NUMBER);
CREATE TABLE Dev.test_table2 (id NUMBER);

CREATE TABLE Prod.test_table (id NUMBER);
CREATE TABLE Prod.test_table2 (id NUMBER);

DROP TABLE diff_tables;
DROP TABLE out_tables;

CREATE TABLE diff_tables (
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(100)
);

CREATE TABLE out_tables (
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(100)
);


BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
    COMPARE_OBJECTS('DEV', 'PROD', 'PROCEDURE');
END;