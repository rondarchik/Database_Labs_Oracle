DROP TABLE STUDENTS;

DROP TABLE GROUPS;

-- 1) Create tables
CREATE TABLE GROUPS (
    ID NUMBER PRIMARY KEY NOT NULL,
    NAME VARCHAR2(20) NOT NULL,
    C_VAL NUMBER NOT NULL -- number of students in the group
);

CREATE TABLE STUDENTS (
    ID NUMBER PRIMARY KEY NOT NULL,
    NAME VARCHAR2(20) NOT NULL,
    GROUP_ID NUMBER REFERENCES GROUPS(ID) NOT NULL
);

-- 2) Triggers implementation
--------------------------Uniqueness check (field: GROUP.NAME)--------------------------
CREATE OR REPLACE TRIGGER check_unique_group_name
    BEFORE INSERT OR UPDATE OF name ON Groups FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    is_exists NUMBER;
    not_unique_value EXCEPTION;
    PRAGMA EXCEPTION_INIT(not_unique_value, -1);
BEGIN
    SELECT COUNT(name) INTO is_exists FROM Groups WHERE name=:NEW.name;

    IF is_exists <> 0 THEN
        RAISE not_unique_value;
    END IF;
END;

ALTER TRIGGER check_unique_group_name ENABLE;

--------------------------Auto-increment key generation --------------------------
CREATE SEQUENCE id_auto_increment
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE;

--------------------------STUDENTS--------------------------
CREATE OR REPLACE TRIGGER generate_student_id
    BEFORE INSERT ON Students FOR EACH ROW
BEGIN
    SELECT id_auto_increment.NEXTVAL
        INTO :NEW.id FROM dual;
END;    

ALTER TRIGGER generate_student_id ENABLE;

--------------------------GROUPS--------------------------
CREATE OR REPLACE TRIGGER generate_group_id
    BEFORE INSERT ON Groups FOR EACH ROW
        FOLLOWS check_unique_group_name
BEGIN
    SELECT id_auto_increment.NEXTVAL
        INTO :NEW.id FROM dual;
END;    

ALTER TRIGGER generate_group_id ENABLE;

--------------------------Integrity check (ID uniqueness check)--------------------------
CREATE OR REPLACE TRIGGER check_unique_student_id
    BEFORE INSERT OR UPDATE OF NAME ON Students FOR EACH ROW
        FOLLOWS generate_student_id
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    is_exists NUMBER;   
    not_unique_value EXCEPTION;
    PRAGMA EXCEPTION_INIT(not_unique_value, -1);
BEGIN
    SELECT COUNT(id) INTO is_exists FROM Students WHERE id=:NEW.id;

    IF is_exists <> 0 THEN
        RAISE not_unique_value;
    END IF;
END;

ALTER TRIGGER check_unique_student_id ENABLE;

CREATE OR REPLACE TRIGGER check_unique_gorup_id
    BEFORE INSERT OR UPDATE OF NAME ON Groups FOR EACH ROW
        FOLLOWS generate_group_id
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    is_exists NUMBER;   
    not_unique_value EXCEPTION;
    PRAGMA EXCEPTION_INIT(not_unique_value, -1);
BEGIN
    SELECT COUNT(id) INTO is_exists FROM Groups WHERE id=:NEW.id;

    IF is_exists <> 0 THEN
        RAISE not_unique_value;
    END IF;
END;

ALTER TRIGGER check_unique_gorup_id ENABLE;

-- 3) Foreign Key - trigger implementation
-- 4) Implementation of trigger that logs all actions (table : STUDENTS)
-- 5) Procedure for task 4
-- 6) Implementation of trigger that update C_VAL in GROUPS