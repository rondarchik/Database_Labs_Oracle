SET SERVEROUTPUT ON;

-- Create users
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

DROP USER Prod CASCADE;
DROP USER Dev CASCADE;

CREATE USER Prod IDENTIFIED BY password;
CREATE USER Dev IDENTIFIED BY password;

GRANT CONNECT, RESOURCE TO Prod;
GRANT CONNECT, RESOURCE TO Dev;

connect dev/password@localhost/xepdb1;
connect prod/password@localhost/xepdb1;
connect sys/password@localhost/xepdb1 as sysdba;

-- Part 1: Table is exists in Dev but not in Prod
-- Test 1: empty dev&prod schemas
BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

-- Test 2: add table to Dev
CREATE TABLE Dev.Table1 (id NUMBER);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

-- Test 3: add same table to Prod
CREATE TABLE Prod.Table1 (id NUMBER);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

-- Test 4: add 2 new tables into Dev
CREATE TABLE Dev.Table2 (id NUMBER);
CREATE TABLE Dev.Table3 (id NUMBER);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

-- Part 2: -//- can be different structure
-- Test 5: Change Table1 in Prod 
DROP TABLE Prod.Table1;
CREATE TABLE Prod.Table1 (id VARCHAR2(10));

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;

-- Part 3: add detecting of loops
-- Test 6: detecting cycles in foreign key constraint
DROP TABLE Prod.Table1 CASCADE CONSTRAINTS;
DROP TABLE Dev.Table1 CASCADE CONSTRAINTS;
DROP TABLE Dev.Table2 CASCADE CONSTRAINTS;
DROP TABLE Dev.Table3;

CREATE TABLE Dev.Table1 (
    id NUMBER PRIMARY KEY,
    table2_id NUMBER
);

CREATE TABLE Dev.Table2 (
    id NUMBER PRIMARY KEY,
    table1_id NUMBER
);

ALTER TABLE Dev.Table1 ADD CONSTRAINT fk_t1_t2 FOREIGN KEY (table2_id) REFERENCES Dev.Table2(id);
ALTER TABLE Dev.Table2 ADD CONSTRAINT fk_t2_t1 FOREIGN KEY (table1_id) REFERENCES Dev.Table1(id);

BEGIN
    COMPARE_SCHEMAS('DEV', 'PROD');
END;