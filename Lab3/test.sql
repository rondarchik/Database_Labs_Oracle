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