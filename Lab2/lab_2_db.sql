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

CREATE SEQUENCE ID_AUTO_INCREMENT_GROUPS 
    START WITH 1 
    INCREMENT BY 1 
    NOMAXVALUE;

CREATE SEQUENCE ID_AUTO_INCREMENT_STUDENS 
    START WITH 1 
    INCREMENT BY 1 
    NOMAXVALUE;

--------------------------Students--------------------------
CREATE OR REPLACE TRIGGER GENERATE_STUDENT_ID BEFORE
    INSERT ON STUDENTS FOR EACH ROW
BEGIN
    SELECT  ID_AUTO_INCREMENT_STUDENS.NEXTVAL 
        INTO :NEW.ID FROM DUAL;
END;

-- ALTER TRIGGER GENERATE_STUDENT_ID ENABLE;

--------------------------Groups--------------------------
CREATE OR REPLACE TRIGGER GENERATE_GROUP_ID 
    BEFORE INSERT ON GROUPS FOR EACH ROW
BEGIN
    SELECT ID_AUTO_INCREMENT_GROUPS.NEXTVAL 
        INTO :NEW.ID FROM DUAL;
END;

-- ALTER TRIGGER GENERATE_GROUP_ID ENABLE;

--------------------------Integrity check (id uniqueness check)--------------------------
CREATE OR REPLACE TRIGGER CHECK_UNIQUE_STUDENT_ID 
    BEFORE INSERT ON STUDENTS FOR EACH ROW
DECLARE 
    IS_EXISTS NUMBER;
    NOT_UNIQUE_VALUE EXCEPTION;
BEGIN
    SELECT COUNT(ID) INTO IS_EXISTS FROM STUDENTS
        WHERE ID=:NEW.ID;
        
    IF IS_EXISTS != 0 THEN
        RAISE NOT_UNIQUE_VALUE;
    END IF;
        
    EXCEPTION
        WHEN NOT_UNIQUE_VALUE THEN
            DBMS_OUTPUT.PUT_LINE('This id=' || TO_CHAR(:NEW.ID)
                || 'already exists in table Students!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('something wrong!');
END;

-- ALTER TRIGGER check_unique_student_id ENABLE;

CREATE OR REPLACE TRIGGER CHECK_UNIQUE_GORUP_ID 
    BEFORE INSERT ON GROUPS FOR EACH ROW
DECLARE 
    IS_EXISTS NUMBER;
    NOT_UNIQUE_VALUE EXCEPTION;
BEGIN
    SELECT COUNT(ID) INTO IS_EXISTS FROM GROUPS
        WHERE ID=:NEW.ID;
        
    IF IS_EXISTS != 0 THEN
        RAISE NOT_UNIQUE_VALUE;
    END IF;

    EXCEPTION
        WHEN NOT_UNIQUE_VALUE THEN
            DBMS_OUTPUT.PUT_LINE('This id=' || TO_CHAR(:NEW.ID)
                || 'already exists in table Groups!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('something wrong!');
END;

-- ALTER TRIGGER check_unique_gorup_id ENABLE;

--------------------------Uniqueness check (field: GROUP.name)--------------------------
CREATE OR REPLACE TRIGGER CHECK_UNIQUE_GROUP_NAME 
    BEFORE INSERT OR UPDATE OF NAME ON GROUPS FOR EACH ROW 
DECLARE 
    IS_EXISTS NUMBER;
    NOT_UNIQUE_VALUE EXCEPTION;
BEGIN
    SELECT COUNT(NAME) INTO IS_EXISTS FROM GROUPS
        WHERE NAME=:NEW.NAME;
        
    IF IS_EXISTS != 0 THEN
        RAISE NOT_UNIQUE_VALUE;
    END IF;
        
    EXCEPTION
        WHEN NOT_UNIQUE_VALUE THEN
            DBMS_OUTPUT.PUT_LINE('This name=' || TO_CHAR(:NEW.NAME)
                || 'already exists in table Groups!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('something wrong!');
END;

-- ALTER TRIGGER check_unique_group_name ENABLE;

-- 3) Foreign Key - trigger implementation
CREATE OR REPLACE TRIGGER CASCADE_DELETE 
    BEFORE DELETE ON GROUPS FOR EACH ROW 
BEGIN
    DELETE FROM STUDENTS WHERE GROUP_ID = :OLD.ID;
END;

 -- 4) Implementation of trigger that logs all actions (table : Students)
DROP TABLE STUDENTS_TABLE_LOGS;

CREATE TABLE STUDENTS_TABLE_LOGS ( 
    ID NUMBER PRIMARY KEY NOT NULL, 
    DATE_TIME TIMESTAMP NOT NULL, 
    DESCRIPTION VARCHAR2(100) NOT NULL,
    NEW_ID NUMBER, 
    OLD_ID NUMBER, 
    NEW_NAME VARCHAR2(20), 
    OLD_NAME VARCHAR2(20), 
    NEW_DROUP_ID NUMBER, 
    OLD_GROUP_ID NUMBER
);

CREATE OR REPLACE TRIGGER STUDENTS_LOGGER 
    AFTER INSERT OR UPDATE OR DELETE ON STUDENTS FOR EACH ROW 
DECLARE 
    ID NUMBER;
BEGIN
    SELECT COUNT(*) INTO ID FROM STUDENTS_TABLE_LOGS;
    
    CASE
        WHEN INSERTING THEN
            INSERT INTO STUDENTS_TABLE_LOGS VALUES (
                ID + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING',
                :NEW.ID, NULL, :NEW.NAME, NULL, :NEW.GROUP_ID, NULL);
        WHEN UPDATING THEN
            INSERT INTO STUDENTS_TABLE_LOGS VALUES (
                ID + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING',
                :NEW.ID, :OLD.ID, :NEW.NAME, :OLD.NAME, :NEW.GROUP_ID, :OLD.GROUP_ID);
        WHEN DELETING THEN
            INSERT INTO STUDENTS_TABLE_LOGS VALUES (
                ID + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING',
                NULL, :OLD.ID, NULL, :OLD.NAME, NULL, :OLD.GROUP_ID);
    END CASE;
END;

 -- 5) Procedure for task 4


 -- 6) Implementation of trigger that update c_val in Groups
CREATE OR REPLACE TRIGGER UPDATE_STUDENTS_VALUE AFTER
    INSERT OR UPDATE OR DELETE ON STUDENTS FOR EACH ROW
BEGIN
    CASE
        WHEN INSERTING THEN
            UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE ID = :NEW.GROUP_ID;
        WHEN UPDATING THEN
            UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE ID = :OLD.GROUP_ID;
            UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE ID = :NEW.GROUP_ID;
        WHEN DELETING THEN
            UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE ID = :OLD.GROUP_ID;
    END CASE;
END;