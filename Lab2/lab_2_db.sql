DROP TABLE STUDENTS;

DROP TABLE GROUPS;

-- 1) Create tables
CREATE TABLE GROUPS (
    ID NUMBER NOT NULL,
    NAME VARCHAR2(20) NOT NULL,
    C_VAL NUMBER NOT NULL -- number of Students in the group
);

CREATE TABLE STUDENTS (
    ID NUMBER NOT NULL,
    NAME VARCHAR2(20) NOT NULL,
    GROUP_ID NUMBER NOT NULL
);

-- 2) Triggers implementation
--------------------------Auto-increment key generation --------------------------
DROP SEQUENCE ID_AUTO_INCREMENT_GROUPS;

DROP SEQUENCE ID_AUTO_INCREMENT_STUDENS;

CREATE SEQUENCE ID_AUTO_INCREMENT_GROUPS START WITH 1 INCREMENT BY 1 NOMAXVALUE;

CREATE SEQUENCE ID_AUTO_INCREMENT_STUDENS START WITH 1 INCREMENT BY 1 NOMAXVALUE;

--------------------------Students--------------------------
CREATE OR REPLACE TRIGGER generate_student_id
    BEFORE INSERT ON STUDENTS FOR EACH ROW
BEGIN
    SELECT id_auto_increment_studens.NEXTVAL
        INTO :NEW.ID FROM dual;
END;    

ALTER TRIGGER generate_student_id ENABLE;

--------------------------Groups--------------------------
CREATE OR REPLACE TRIGGER generate_group_id
    BEFORE INSERT ON GROUPS FOR EACH ROW
        -- FOLLOWS check_unique_group_name
BEGIN
    SELECT id_auto_increment_groups.NEXTVAL
        INTO :NEW.ID FROM dual;
END;    

ALTER TRIGGER generate_group_id ENABLE;

--------------------------Integrity check (id uniqueness check)--------------------------
CREATE OR REPLACE TRIGGER check_unique_student_id
    BEFORE INSERT ON STUDENTS FOR EACH ROW
        -- FOLLOWS generate_student_id
DECLARE
    is_exists NUMBER;   
    not_unique_value EXCEPTION;
BEGIN
    SELECT COUNT(ID) INTO is_exists FROM STUDENTS WHERE ID=:NEW.ID;

    IF is_exists != 0 THEN
        RAISE not_unique_value;
    END IF;

    EXCEPTION 
        WHEN not_unique_value THEN
            dbms_output.put_line('This id=' || TO_CHAR(:NEW.ID) || 'already exists in table Students!');
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');
END;

-- ALTER TRIGGER check_unique_student_id ENABLE;

CREATE OR REPLACE TRIGGER check_unique_gorup_id
    BEFORE INSERT ON GROUPS FOR EACH ROW
        -- FOLLOWS generate_group_id
DECLARE
    is_exists NUMBER;   
    not_unique_value EXCEPTION;
BEGIN
    SELECT COUNT(ID) INTO is_exists FROM GROUPS WHERE ID=:NEW.ID;

    IF is_exists != 0 THEN
        RAISE not_unique_value;
    END IF;

    EXCEPTION 
        WHEN not_unique_value THEN
            dbms_output.put_line('This id=' || TO_CHAR(:NEW.ID) || 'already exists in table Groups!');
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');
END;

-- ALTER TRIGGER check_unique_gorup_id ENABLE;

--------------------------Uniqueness check (field: GROUP.name)--------------------------
CREATE OR REPLACE TRIGGER check_unique_group_name
    BEFORE INSERT OR UPDATE OF NAME ON GROUPS FOR EACH ROW
DECLARE
    is_exists NUMBER;
    not_unique_value EXCEPTION;
BEGIN
    SELECT COUNT(NAME) INTO is_exists FROM GROUPS WHERE NAME=:NEW.NAME;

    IF is_exists != 0 THEN
        RAISE not_unique_value;
    END IF;

    EXCEPTION 
        WHEN not_unique_value THEN
            dbms_output.put_line('This name=' || TO_CHAR(:NEW.NAME) || 'already exists in table Groups!');
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');
END;

-- ALTER TRIGGER check_unique_group_name ENABLE;

-- 3) Foreign Key - trigger implementation
-- 4) Implementation of trigger that logs all actions (table : Students)
-- 5) Procedure for task 4
-- 6) Implementation of trigger that update c_val in Groups