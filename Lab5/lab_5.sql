CONNECT sys/password@localhost/xepdb1 as sysdba;
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

DROP USER Lab5 CASCADE;

CREATE USER Lab5 IDENTIFIED by 111;
GRANT ALL PRIVILEGES TO Lab5;
CONNECT Lab5/111@localhost/xepdb1;

-- TASK 1
DROP TABLE Groups CASCADE CONSTRAINT;
DROP TABLE Students;
DROP TABLE Classes;

CREATE TABLE Groups (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(20) NOT NULL
);

CREATE TABLE Students (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(20) NOT NULL,
    group_id NUMBER,

    CONSTRAINT fk_student_to_group FOREIGN KEY(group_id) REFERENCES Groups(id)
);

CREATE TABLE Classes (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(20) NOT NULL,
    class_date TIMESTAMP DEFAULT SYSDATE,
    group_id NUMBER,

    CONSTRAINT fk_class_to_group FOREIGN KEY(group_id) REFERENCES Groups(id)
);

INSERT INTO Groups(name) VALUES('001');
INSERT INTO Groups(name) VALUES('002');
INSERT INTO Groups(name) VALUES('003');
SELECT * FROM Groups;

INSERT INTO Students(name, group_id) VALUES('A', 1);
INSERT INTO Students(name, group_id) VALUES('B', 2);
INSERT INTO Students(name, group_id) VALUES('C', 2);
INSERT INTO Students(name, group_id) VALUES('D', 1);
INSERT INTO Students(name, group_id) VALUES('E', 2);
INSERT INTO Students(name, group_id) VALUES('F', 1);
INSERT INTO Students(name, group_id) VALUES('G', 1);
INSERT INTO Students(name, group_id) VALUES('R', 3);
SELECT * FROM Students;

INSERT INTO Classes(name, group_id) VALUES('Math', 2);
INSERT INTO Classes(name, group_id) VALUES('Programming', 1);
INSERT INTO Classes(name, group_id) VALUES('Data Bases', 3);
SELECT * FROM Classes;

-- TASK 2
DROP TABLE History;

CREATE TABLE History ( 
    id NUMBER  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_time TIMESTAMP NOT NULL, 
    description VARCHAR2(10) NOT NULL,
    table_name VARCHAR2(10) NOT NULL,

    -- students
    new_st_name VARCHAR2(20), 
    old_st_name VARCHAR2(20), 
    new_st_group_id NUMBER, 
    old_st_group_id NUMBER,

    -- classes
    new_class_name VARCHAR2(20), 
    old_class_name VARCHAR2(20), 
    new_class_date TIMESTAMP, 
    old_class_date TIMESTAMP, 
    new_class_group_id NUMBER, 
    old_class_group_id NUMBER,

    -- groups
    new_group_name VARCHAR2(20), 
    old_group_name VARCHAR2(20)
);

CREATE OR REPLACE TRIGGER students_logger 
    AFTER INSERT OR UPDATE OR DELETE ON Students FOR EACH ROW 
BEGIN
    CASE
        WHEN INSERTING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING', 'STUDENTS',
                        :NEW.name, NULL, :NEW.group_id, NULL, 
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        WHEN UPDATING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING', 'STUDENTS',
                        :NEW.name, :OLD.name, :NEW.group_id, :OLD.group_id, 
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        WHEN DELETING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING', 'STUDENTS',
                        NULL, :OLD.name, NULL, :OLD.group_id, 
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    END CASE;
END;

CREATE OR REPLACE TRIGGER classes_logger 
    AFTER INSERT OR UPDATE OR DELETE ON Classes FOR EACH ROW 
BEGIN
    CASE
        WHEN INSERTING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING', 'CLASSES', NULL, NULL, NULL, NULL,
                        :NEW.name, NULL, :NEW.class_date, NULL, :NEW.group_id, NULL, 
                        NULL, NULL);
        WHEN UPDATING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING', 'CLASSES', NULL, NULL, NULL, NULL,
                        :NEW.name, :OLD.name, :NEW.class_date, :OLD.class_date, :NEW.group_id, :OLD.group_id,
                        NULL, NULL);
        WHEN DELETING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING', 'CLASSES', NULL, NULL, NULL, NULL,
                        NULL, :OLD.name, NULL, :OLD.class_date, NULL, :OLD.group_id,
                        NULL, NULL);
    END CASE;
END;

CREATE OR REPLACE TRIGGER groups_logger 
    AFTER INSERT OR UPDATE OR DELETE ON Groups FOR EACH ROW 
BEGIN
    CASE
        WHEN INSERTING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING', 'GROUPS',
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                        :NEW.name, NULL);
        WHEN UPDATING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING', 'GROUPS',
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                        :NEW.name, :OLD.name);
        WHEN DELETING THEN
            INSERT INTO History(date_time, description, table_name, new_st_name, old_st_name, new_st_group_id, old_st_group_id,
                                new_class_name, old_class_name, new_class_date, old_class_date, new_class_group_id, old_class_group_id,
                                new_group_name, old_group_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING', 'GROUPS',
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
                        NULL, :OLD.name);
    END CASE;
END;

SELECT * FROM History;

-- TASK 3
ALTER TRIGGER students_logger DISABLE;
ALTER TRIGGER classes_logger DISABLE;
ALTER TRIGGER groups_logger DISABLE;

CREATE OR REPLACE PACKAGE rollback_package
AS
    PROCEDURE rollback_changes (rollback_time IN TIMESTAMP);
    PROCEDURE rollback_changes (rollback_interval IN NUMBER);
END rollback_package;

CREATE OR REPLACE PACKAGE BODY rollback_package
AS
    PROCEDURE restore_students (rec IN History%rowtype)
    IS
    BEGIN
        IF rec.description = 'INSERTING' AND rec.table_name = 'STUDENTS' 
        THEN
            DELETE FROM Students WHERE name=rec.new_st_name;
        ELSIF rec.description = 'UPDATING' AND rec.table_name = 'STUDENTS'  
        THEN
            UPDATE Students SET name=rec.old_st_name, group_id=rec.old_st_group_id
                WHERE name=rec.new_st_name;
        ELSIF rec.description = 'DELETING' AND rec.table_name = 'STUDENTS' 
        THEN
            INSERT INTO Students(name, group_id) VALUES(rec.old_st_name, rec.old_st_group_id);
        END IF;
    END restore_students;

    PROCEDURE restore_classes (rec IN History%rowtype)
    IS
    BEGIN
        IF rec.description = 'INSERTING' AND rec.table_name = 'CLASSES' 
        THEN
            DELETE FROM Classes WHERE name=rec.new_class_name;
        ELSIF rec.description = 'UPDATING' AND rec.table_name = 'CLASSES'  
        THEN
            UPDATE Classes SET name=rec.old_class_name, class_date=rec.old_class_date, group_id=rec.old_class_group_id
                WHERE name=rec.new_class_name;
        ELSIF rec.description = 'DELETING' AND rec.table_name = 'CLASSES' 
        THEN
            INSERT INTO Classes(name, class_date, group_id) VALUES(rec.old_class_name, rec.old_class_date, rec.old_class_group_id);
        END IF;
    END restore_classes;

    PROCEDURE restore_groups (rec IN History%rowtype)
    IS
    BEGIN
        IF rec.description = 'INSERTING' AND rec.table_name = 'GROUPS' 
        THEN
            DELETE FROM Groups WHERE name=rec.new_group_name;
        ELSIF rec.description = 'UPDATING' AND rec.table_name = 'GROUPS'  
        THEN
            UPDATE Groups SET name=rec.old_group_name
                WHERE name=rec.new_group_name;
        ELSIF rec.description = 'DELETING' AND rec.table_name = 'GROUPS' 
        THEN
            INSERT INTO Groups(name) VALUES(rec.old_group_name);
        END IF;
    END restore_groups;

    PROCEDURE rollback_changes (rollback_time IN TIMESTAMP)
    IS
        CURSOR hist(h_date History.date_time%TYPE)
        IS
        SELECT * FROM History
        WHERE date_time >= h_date
        ORDER BY id DESC;
    BEGIN
        FOR rec IN hist(rollback_time) 
        LOOP
            IF rec.table_name = 'STUDENTS'
            THEN
                restore_students(rec);
            ELSIF rec.table_name = 'CLASSES'
            THEN
                restore_classes(rec);
            ELSIF rec.table_name = 'GROUPS'
            THEN
                restore_groups(rec);
            END IF;
            
            DELETE FROM History WHERE id=rec.id;
        END LOOP;
    END rollback_changes;

    PROCEDURE rollback_changes (rollback_interval IN NUMBER)
    IS
    BEGIN
        rollback_changes(SYSDATE - NUMTODSINTERVAL(rollback_interval / 1000, 'SECOND'));
    END rollback_changes;
END rollback_package;

BEGIN
    rollback_package.rollback_changes (TO_TIMESTAMP('08-MAY-23 04.07.38.000000000 AM'));
END;

-- TASK 4
CREATE OR REPLACE DIRECTORY dir AS '/my/directory/path';
CONNECT sys/password@localhost/xepdb1 as sysdba;
GRANT WRITE ON DIRECTORY dir TO Lab5;
CONNECT Lab5/111@localhost/xepdb1;

DECLARE
    file UTL_FILE.FILE_TYPE;
BEGIN
    file := UTL_FILE.fopen('DIR', 'report.html', 'W');
END;

CREATE OR REPLACE PROCEDURE generate_report (desired_date TIMESTAMP)
IS
    file UTL_FILE.file_type;
    buff VARCHAR(1000);

    students_insert_count number;
    students_delete_count number;
    students_update_count number;

    classes_insert_count number;
    classes_delete_count number;
    classes_update_count number;

    groups_insert_count number;
    groups_delete_count number;
    groups_update_count number;
BEGIN
    file := UTL_FILE.fopen('DIR', 'report.html', 'W');

    IF NOT UTL_FILE.IS_OPEN(file) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: File report.html does not open!');
    END IF;

    buff := HTF.HTMLOPEN || CHR(10) || HTF.headopen || CHR(10) || HTF.title('Report')
        || CHR(10) || HTF.headclose || CHR(10) ||HTF.bodyopen || CHR(10);

    SELECT COUNT(*) INTO students_insert_count FROM History
        WHERE description = 'INSERTING' AND table_name = 'STUDENTS' AND date_time >= desired_date;

    SELECT COUNT(*) INTO students_update_count FROM History
        WHERE description = 'UPDATING' AND table_name = 'STUDENTS' AND date_time >= desired_date;

    SELECT COUNT(*) INTO students_delete_count FROM History
        WHERE description = 'DELETING' AND table_name = 'STUDENTS' AND date_time >= desired_date;

    SELECT COUNT(*) INTO classes_insert_count FROM History
        WHERE description = 'INSERTING' AND table_name = 'CLASSES' AND date_time >= desired_date;

    SELECT COUNT(*) INTO classes_update_count FROM History
        WHERE description = 'UPDATING' AND table_name = 'CLASSES' AND date_time >= desired_date;

    SELECT COUNT(*) INTO classes_delete_count FROM History
        WHERE description = 'DELETING' AND table_name = 'CLASSES' AND date_time >= desired_date;

    SELECT COUNT(*) INTO groups_insert_count FROM History
        WHERE description = 'INSERTING' AND table_name = 'GROUPS' AND date_time >= desired_date;

    SELECT COUNT(*) INTO groups_update_count FROM History
        WHERE description = 'UPDATING' AND table_name = 'GROUPS' AND date_time >= desired_date;

    SELECT COUNT(*) INTO groups_delete_count FROM History
        WHERE description = 'DELETING' AND table_name = 'GROUPS' AND date_time >= desired_date;

    buff := buff || HTF.TABLEOPEN || CHR(10) || HTF.TABLEROWOPEN || CHR(10) || HTF.TABLEHEADER('') || CHR(10) || HTF.TABLEHEADER('STUDENTS') || CHR(10) ||
    HTF.TABLEHEADER('CLASSES') || CHR(10) || HTF.TABLEHEADER('GROUPS') || CHR(10) || HTF.TABLEROWCLOSE || CHR(10);

    buff := buff || HTF.TABLEROWOPEN || CHR(10) || HTF.TABLEHEADER('INSERTING') || CHR(10) || HTF.TABLEDATA(students_insert_count) || CHR(10) ||
    HTF.TABLEDATA(classes_insert_count) || CHR(10) || HTF.TABLEDATA(groups_insert_count) || CHR(10) || HTF.TABLEROWCLOSE || CHR(10);

    buff := buff || HTF.TABLEROWOPEN || CHR(10) || HTF.TABLEHEADER('UPDATING') || CHR(10) || HTF.TABLEDATA(students_update_count) || CHR(10) ||
    HTF.TABLEDATA(classes_update_count) || CHR(10) || HTF.TABLEDATA(groups_update_count) || CHR(10) || HTF.TABLEROWCLOSE || CHR(10);

    buff := buff || HTF.TABLEROWOPEN || CHR(10) || HTF.TABLEHEADER('DELETING') || CHR(10) || HTF.TABLEDATA(students_delete_count) || CHR(10) ||
    HTF.TABLEDATA(classes_delete_count) || CHR(10) || HTF.TABLEDATA(groups_delete_count) || CHR(10) || HTF.TABLEROWCLOSE || CHR(10);

    buff := buff || HTF.TABLECLOSE || CHR(10) || HTF.bodyclose || CHR(10) || HTF.htmlclose;

    UTL_FILE.put_line (file, buff);
    UTL_FILE.fclose(file);

    EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error in generate_report(). NO_DATA_FOUND');

END generate_report;

BEGIN
    generate_report(TO_TIMESTAMP('08-MAY-23 04.07.38.000000000 AM'));
END;
