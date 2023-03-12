-- test task 2 & task 6
ALTER TABLE Groups DISABLE ALL TRIGGERS;
ALTER TABLE Students DISABLE ALL TRIGGERS;

ALTER TRIGGER generate_groups_id ENABLE;
ALTER TRIGGER check_unique_gorup_id ENABLE;
ALTER TRIGGER check_unique_group_name ENABLE; 

INSERT INTO Groups(name) VALUES('001');
INSERT INTO Groups(name) VALUES('002');
INSERT INTO Groups(name) VALUES('003');

SELECT * FROM Groups;

-- try insert not unique name
INSERT INTO Groups(name) VALUES('003');

-- try insert not unique id
ALTER TRIGGER generate_groups_id DISABLE;
INSERT INTO Groups(id, name) VALUES(1, '004');

ALTER TRIGGER generate_students_id ENABLE;
ALTER TRIGGER check_unique_students_id ENABLE;
ALTER TRIGGER update_students_value_in_groups ENABLE;
ALTER TABLE Groups DISABLE ALL TRIGGERS;

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

-- test task 3
ALTER TABLE Groups DISABLE ALL TRIGGERS;
ALTER TABLE Students DISABLE ALL TRIGGERS;
ALTER TRIGGER cascade_delete ENABLE;

SELECT * FROM Students;
SELECT * FROM Groups;

DELETE FROM Groups WHERE id = 3;

SELECT * FROM Students;
SELECT * FROM Groups;

-- test task 4
ALTER TABLE Groups DISABLE ALL TRIGGERS;
ALTER TABLE Students DISABLE ALL TRIGGERS;
ALTER TRIGGER students_logger ENABLE;
ALTER TRIGGER update_students_value_in_groups ENABLE;

UPDATE Students SET group_id = 2 WHERE name = 'A';

SELECT * FROM Students;
SELECT * FROM Groups;
SELECT * FROM Students_table_logs;

-- test task 5
BEGIN
    restore_data(TO_TIMESTAMP('13-MAR-23 01.00.00.000000000 AM'));
END;

BEGIN
    restore_data(TO_TIMESTAMP(CURRENT_TIMESTAMP - 10));
END;

BEGIN
    restore_data_by_time_interval(INTERVAL '1' DAY);
END;

SELECT * FROM Students;
SELECT * FROM Groups;
SELECT * FROM Students_table_logs;

