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

DROP TABLE Groups CASCADE CONSTRAINT;
CREATE TABLE Groups (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(20) NOT NULL
);

INSERT INTO Groups(name) VALUES('001');
INSERT INTO Groups(name) VALUES('002');
INSERT INTO Groups(name) VALUES('003');
SELECT * FROM Groups;

DROP TABLE Students;
CREATE TABLE Students (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(20) NOT NULL,
    group_id NUMBER,

    CONSTRAINT fk_student_to_group FOREIGN KEY(group_id) REFERENCES Groups(id)
);

INSERT INTO Students(name, group_id) VALUES('A', 1);
INSERT INTO Students(name, group_id) VALUES('B', 2);
INSERT INTO Students(name, group_id) VALUES('C', 2);
INSERT INTO Students(name, group_id) VALUES('D', 1);
INSERT INTO Students(name, group_id) VALUES('E', 2);
INSERT INTO Students(name, group_id) VALUES('F', 1);
INSERT INTO Students(name, group_id) VALUES('G', 1);
INSERT INTO Students(name, group_id) VALUES('R', 3);
SELECT * FROM Students;

DROP TABLE Classes;
CREATE TABLE Classes (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(20) NOT NULL,
    class_date TIMESTAMP DEFAULT SYSDATE,
    group_id NUMBER,

    CONSTRAINT fk_class_to_group FOREIGN KEY(group_id) REFERENCES Groups(id)
);

INSERT INTO Classes(name, group_id) VALUES('Math', 2);
INSERT INTO Classes(name, group_id) VALUES('Programming', 1);
INSERT INTO Classes(name, group_id) VALUES('Data Bases', 3);
SELECT * FROM Classes;

-- TASK 2
DROP TABLE Students_table_logs;

CREATE TABLE Students_table_logs ( 
    id NUMBER  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_time TIMESTAMP NOT NULL, 
    description VARCHAR2(10) NOT NULL,
    new_name VARCHAR2(20), 
    old_name VARCHAR2(20), 
    new_group_id NUMBER, 
    old_group_id NUMBER
);

CREATE OR REPLACE TRIGGER students_logger 
    AFTER INSERT OR UPDATE OR DELETE ON Students FOR EACH ROW 
BEGIN
    CASE
        WHEN INSERTING THEN
            INSERT INTO Students_table_logs(date_time, description, new_name, old_name, new_group_id, old_group_id)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING',
                        :NEW.name, NULL, :NEW.group_id, NULL);
        WHEN UPDATING THEN
            INSERT INTO Students_table_logs(date_time, description, new_name, old_name, new_group_id, old_group_id)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING',
                        :NEW.name, :OLD.name, :NEW.group_id, :OLD.group_id);
        WHEN DELETING THEN
            INSERT INTO Students_table_logs(date_time, description, new_name, old_name, new_group_id, old_group_id)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING',
                        NULL, :OLD.name, NULL, :OLD.group_id);
    END CASE;
END;

DROP TABLE Classes_table_logs;

CREATE TABLE Classes_table_logs ( 
    id NUMBER  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_time TIMESTAMP NOT NULL, 
    description VARCHAR2(10) NOT NULL,
    new_name VARCHAR2(20), 
    old_name VARCHAR2(20), 
    new_class_date TIMESTAMP, 
    old_class_date TIMESTAMP, 
    new_group_id NUMBER, 
    old_group_id NUMBER
);

CREATE OR REPLACE TRIGGER classes_logger 
    AFTER INSERT OR UPDATE OR DELETE ON Classes FOR EACH ROW 
BEGIN
    CASE
        WHEN INSERTING THEN
            INSERT INTO Classes_table_logs(date_time, description, new_name, old_name, new_class_date, old_class_date, new_group_id, old_group_id)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING',
                        :NEW.name, NULL, :NEW.class_date, NULL, :NEW.group_id, NULL);
        WHEN UPDATING THEN
            INSERT INTO Classes_table_logs(date_time, description, new_name, old_name, new_class_date, old_class_date, new_group_id, old_group_id)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING',
                        :NEW.name, :OLD.name, :NEW.class_date, :OLD.class_date, :NEW.group_id, :OLD.group_id);
        WHEN DELETING THEN
            INSERT INTO Classes_table_logs(date_time, description, new_name, old_name, new_class_date, old_class_date, new_group_id, old_group_id)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING',
                        NULL, :OLD.name, NULL, :OLD.class_date, NULL, :OLD.group_id);
    END CASE;
END;

DROP TABLE Groups_table_logs;

CREATE TABLE Groups_table_logs ( 
    id NUMBER  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_time TIMESTAMP NOT NULL, 
    description VARCHAR2(10) NOT NULL,
    new_name VARCHAR2(20), 
    old_name VARCHAR2(20)
);

CREATE OR REPLACE TRIGGER groups_logger 
    AFTER INSERT OR UPDATE OR DELETE ON Groups FOR EACH ROW 
BEGIN
    CASE
        WHEN INSERTING THEN
            INSERT INTO Groups_table_logs(date_time, description, new_name, old_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'INSERTING',
                        :NEW.name, NULL);
        WHEN UPDATING THEN
            INSERT INTO Groups_table_logs(date_time, description, new_name, old_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'UPDATING',
                        :NEW.name, :OLD.name);
        WHEN DELETING THEN
            INSERT INTO Groups_table_logs(date_time, description, new_name, old_name)
                VALUES (TO_TIMESTAMP(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS AM')), 'DELETING',
                        NULL, :OLD.name);
    END CASE;
END;

SELECT * FROM Students_table_logs;
SELECT * FROM Classes_table_logs;
SELECT * FROM Groups_table_logs;