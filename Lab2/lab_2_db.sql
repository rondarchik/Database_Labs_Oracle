DROP TABLE Students;

DROP TABLE Groups;

-- 1) Create tables
CREATE TABLE Groups (
    id NUMBER NOT NULL,
    name VARCHAR2(20) NOT NULL,
    c_val NUMBER NOT NULL -- number of Students in the group
);

CREATE TABLE Students (
    id NUMBER NOT NULL,
    name VARCHAR2(20) NOT NULL,
    group_id NUMBER NOT NULL
);

-- 2) Triggers implementation
--------------------------Auto-increment key generation --------------------------
DROP SEQUENCE id_auto_increment_for_groups;

DROP SEQUENCE id_auto_increment_for_students;

CREATE SEQUENCE id_auto_increment_for_groups 
    START WITH 1 
    INCREMENT BY 1 
    NOMAXVALUE;

CREATE SEQUENCE id_auto_increment_for_students 
    START WITH 1 
    INCREMENT BY 1 
    NOMAXVALUE;

--------------------------Students--------------------------
CREATE OR REPLACE TRIGGER generate_students_id 
    BEFORE INSERT ON Students FOR EACH ROW
BEGIN
    SELECT  id_auto_increment_for_students.NEXTVAL 
        INTO :NEW.id FROM DUAL;
END;

--------------------------Groups--------------------------
CREATE OR REPLACE TRIGGER generate_groups_id 
    BEFORE INSERT ON Groups FOR EACH ROW
BEGIN
    SELECT id_auto_increment_for_groups.NEXTVAL 
        INTO :NEW.id FROM DUAL;
END;

--------------------------Integrity check (id uniqueness check)--------------------------
CREATE OR REPLACE TRIGGER check_unique_students_id 
    BEFORE INSERT ON Students FOR EACH ROW
DECLARE 
    is_exists NUMBER;
    not_unique_value EXCEPTION;
BEGIN
    SELECT COUNT(id) INTO is_exists FROM Students
        WHERE id=:NEW.id;
        
    IF is_exists != 0 THEN
        RAISE not_unique_value;
    END IF;
        
    EXCEPTION
        WHEN not_unique_value THEN
            DBMS_OUTPUT.PUT_LINE('This id=' || TO_CHAR(:NEW.id)
                || 'already exists in table Students!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('something wrong!');
END;


CREATE OR REPLACE TRIGGER check_unique_gorup_id 
    BEFORE INSERT ON Groups FOR EACH ROW
DECLARE 
    is_exists NUMBER;
    not_unique_value EXCEPTION;
BEGIN
    SELECT COUNT(id) INTO is_exists FROM Groups
        WHERE id=:NEW.id;
        
    IF is_exists != 0 THEN
        RAISE not_unique_value;
    END IF;

    EXCEPTION
        WHEN not_unique_value THEN
            DBMS_OUTPUT.PUT_LINE('This id=' || TO_CHAR(:NEW.id)
                || 'already exists in table Groups!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('something wrong!');
END;

--------------------------Uniqueness check (field: GROUP.name)--------------------------
CREATE OR REPLACE TRIGGER check_unique_group_name 
    BEFORE INSERT OR UPDATE OF NAME ON Groups FOR EACH ROW 
DECLARE 
    is_exists NUMBER;
    not_unique_value EXCEPTION;
BEGIN
    SELECT COUNT(name) INTO is_exists FROM Groups
        WHERE name=:NEW.name;
        
    IF is_exists != 0 THEN
        RAISE not_unique_value;
    END IF;
        
    EXCEPTION
        WHEN not_unique_value THEN
            DBMS_OUTPUT.PUT_LINE('This name=' || TO_CHAR(:NEW.name)
                || 'already exists in table Groups!');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('something wrong!');
END;

-- 3) Foreign Key - trigger implementation
CREATE OR REPLACE TRIGGER cascade_delete 
    BEFORE DELETE ON Groups FOR EACH ROW 
BEGIN
    DELETE FROM Students WHERE group_id = :OLD.id;
END;

 -- 4) Implementation of trigger that logs all actions (table : Students)
DROP TABLE Students_table_logs;

CREATE TABLE Students_table_logs ( 
    id NUMBER PRIMARY KEY NOT NULL, 
    date_time TIMESTAMP NOT NULL, 
    description VARCHAR2(100) NOT NULL,
    new_id NUMBER, 
    old_id NUMBER, 
    new_name VARCHAR2(20), 
    old_name VARCHAR2(20), 
    new_group_id NUMBER, 
    old_group_id NUMBER
);

CREATE OR REPLACE TRIGGER students_logger 
    AFTER INSERT OR UPDATE OR DELETE ON Students FOR EACH ROW 
DECLARE 
    id NUMBER;
BEGIN
    SELECT COUNT(*) INTO id FROM Students_table_logs;
    
    CASE
        WHEN INSERTING THEN
            INSERT INTO Students_table_logs VALUES (
                id + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING',
                :NEW.id, NULL, :NEW.name, NULL, :NEW.group_id, NULL);
        WHEN UPDATING THEN
            INSERT INTO Students_table_logs VALUES (
                id + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING',
                :NEW.id, :OLD.id, :NEW.name, :OLD.name, :NEW.group_id, :OLD.group_id);
        WHEN DELETING THEN
            INSERT INTO Students_table_logs VALUES (
                id + 1, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING',
                NULL, :OLD.id, NULL, :OLD.name, NULL, :OLD.group_id);
    END CASE;
END;

 -- 5) Procedure for task 4
CREATE OR REPLACE PROCEDURE restore_data(time TIMESTAMP) IS
BEGIN
    FOR action IN (SELECT * FROM Students_table_logs WHERE time < data_time ORDER BY id DESC)
    LOOP
        CASE
            WHEN action.description == 'INSERTING' THEN
                DELETE FROM Students WHERE id = action.new_id;
            WHEN action.description == 'UPDATING' THEN
                UPDATE Students SET id = action.old_id,
                        name = action.old_name,
                        group_id = action.old_group_id
                    WHERE id = action.new_id;
            WHEN action.description == 'DELETING' THEN
                INSERT INTO Students VALUES (
                    action.old_id, action.old_name, action.old_group_id);
        END CASE;
    END LOOP;
END restore_data;

--------------------------interval--------------------------
CREATE OR REPLACE PROCEDURE restore_data_by_time_interval(time_interval INTERVAL DAY TO SECOND) IS
BEGIN
    restore_data(TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')) - time_interval);
END restore_data_by_time_interval;

 -- 6) Implementation of trigger that update c_val in Groups
CREATE OR REPLACE TRIGGER update_students_value_in_groups 
    AFTER INSERT OR UPDATE OR DELETE ON Students FOR EACH ROW
BEGIN
    CASE
        WHEN INSERTING THEN
            UPDATE Groups SET c_val = c_val + 1 WHERE id = :NEW.group_id;
        WHEN UPDATING THEN
            UPDATE Groups SET c_val = c_val - 1 WHERE id = :OLD.group_id;
            UPDATE Groups SET c_val = c_val + 1 WHERE id = :NEW.group_id;
        WHEN DELETING THEN
            UPDATE Groups SET c_val = c_val - 1 WHERE id = :OLD.group_id;
    END CASE;
END;