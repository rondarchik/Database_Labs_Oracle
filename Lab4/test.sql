CONNECT sys/password@localhost/xepdb1 as sysdba;
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

DROP USER Lab4 CASCADE;

CREATE USER Lab4 IDENTIFIED by 111;
GRANT ALL PRIVILEGES TO Lab4;

CONNECT Lab4/111@localhost/xepdb1;

DROP TABLE Students;
DROP TABLE Groups;

CREATE TABLE Groups (
    id NUMBER PRIMARY KEY NOT NULL,
    name VARCHAR2(20) NOT NULL,
    c_val NUMBER DEFAULT 0 NOT NULL -- number of Students in the group
);

CREATE TABLE Students (
    id NUMBER PRIMARY KEY NOT NULL,
    name VARCHAR2(20) NOT NULL,
    group_id NUMBER NOT NULL
);

CREATE OR REPLACE TRIGGER update_students_value_in_groups 
    AFTER INSERT OR UPDATE OR DELETE ON Students FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE Groups SET c_val = c_val + 1 WHERE id = :NEW.group_id;
    ELSIF UPDATING THEN
            UPDATE Groups SET c_val = c_val - 1 WHERE id = :OLD.group_id;
            UPDATE Groups SET c_val = c_val + 1 WHERE id = :NEW.group_id;
    ELSIF DELETING THEN
            UPDATE Groups SET c_val = c_val - 1 WHERE id = :OLD.group_id;
    END IF;
END;

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

CREATE OR REPLACE TRIGGER generate_students_id 
    BEFORE INSERT ON Students FOR EACH ROW
BEGIN
    SELECT  id_auto_increment_for_students.NEXTVAL 
        INTO :NEW.id FROM DUAL;
END;

CREATE OR REPLACE TRIGGER generate_groups_id 
    BEFORE INSERT ON Groups FOR EACH ROW
BEGIN
    SELECT id_auto_increment_for_groups.NEXTVAL 
        INTO :NEW.id FROM DUAL;
END;

INSERT INTO Groups(name) VALUES('001');
INSERT INTO Groups(name) VALUES('002');
INSERT INTO Groups(name) VALUES('003');

INSERT INTO Students(name, group_id) VALUES('A', 1);
INSERT INTO Students(name, group_id) VALUES('B', 2);
INSERT INTO Students(name, group_id) VALUES('C', 2);
INSERT INTO Students(name, group_id) VALUES('D', 1);
INSERT INTO Students(name, group_id) VALUES('E', 2);
INSERT INTO Students(name, group_id) VALUES('F', 1);
INSERT INTO Students(name, group_id) VALUES('G', 1);
INSERT INTO Students(name, group_id) VALUES('R', 3);

SELECT * FROM Students;
SELECT * FROM Groups;


-- task 1-2
DECLARE 
    cur  sys_refcursor;
BEGIN
    cur := xml_package.process_select( 
    /*XML*/
    '<Operation>
        <QueryType>SELECT</QueryType>
        <OutputColumns>
            <Column>students.id</Column>
            <Column>students.name</Column>
            <Column>groups.id</Column>
        </OutputColumns>
        <Tables>
            <Table>students</Table>
            <Table>groups</Table>
        </Tables>
        <Joins>
            <Join>
                <Type>LEFT JOIN</Type>
                <Condition>groups.id = students.group_id</Condition>
            </Join>
        </Joins>
        <Where>
            <Conditions>
                <Condition>
                    <Body>students.id = 1</Body>
                </Condition>
            </Conditions>
        </Where>
    </Operation>'
    /*XML*/
    ); 
END;
    
BEGIN
    DBMS_OUTPUT.put_line(xml_package.xml_select(read('select.xml')));
END;

SELECT students.id, students.name, groups.id FROM students LEFT JOIN groups ON
    groups.id = students.group_id WHERE students.id = 1;

SELECT name FROM groups WHERE c_val = 3;

SELECT students.id, students.name, groups.id FROM students LEFT JOIN groups ON
    groups.id = students.group_id WHERE students.id = 1 OR  groups.name IN 
        (SELECT name FROM groups WHERE c_val = 3  );

-- task 3
CREATE OR REPLACE DIRECTORY dir AS 'D:/bsuir/db/Database_Labs_Oracle/Lab4';

CREATE OR REPLACE FUNCTION read(fname VARCHAR2) 
    RETURN VARCHAR2
IS
    file UTL_FILE.FILE_TYPE;
    buff VARCHAR2(10000);
    str VARCHAR2(500);
BEGIN
    file := UTL_FILE.FOPEN('DIR', fname, 'R');

    IF NOT UTL_FILE.IS_OPEN(file) THEN
        DBMS_OUTPUT.PUT_LINE('File ' || fname || ' does not open!');
        RETURN NULL;
    END IF;

    LOOP
        BEGIN
            UTL_FILE.GET_LINE(file, str);
            buff := buff || str;
            
            EXCEPTION
                WHEN OTHERS THEN EXIT;
        END;
    END LOOP;
    
    UTL_FILE.FCLOSE(file);
    RETURN buff;
END read;

BEGIN
    DBMS_OUTPUT.put_line(xml_package.xml_insert(read('insert.xml')));
END;

INSERT INTO students(name, group_id) VALUES ('krtfds', 3);

BEGIN
    DBMS_OUTPUT.put_line(xml_package.xml_update(read('update.xml')));
END;

UPDATE students SET name='kate' WHERE students.id = 5 OR  group_id IN (SELECT id
FROM groups WHERE c_val = 3  ) ;

BEGIN
    DBMS_OUTPUT.put_line(xml_package.xml_delete(read('delete.xml')));
END;

DELETE FROM students  WHERE id = 1  ;

-- task 4-5