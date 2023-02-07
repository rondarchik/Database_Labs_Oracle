DROP TABLE MyTable;

-- 1) Create table
CREATE TABLE MyTable (
    id NUMBER UNIQUE NOT NULL,
    val NUMBER
);

-- 2) Create anonymous block
DECLARE 
    counter NUMBER;
BEGIN
    counter := 1;
    
    WHILE counter <= 10000
    LOOP
        INSERT INTO MyTable VALUES (counter, dbms_random.RANDOM());
        counter := counter + 1;
    END LOOP;
    
END;

SELECT * FROM MyTable;

-- 3) Create function that returns TRUE, FALSE or EQUAL
CREATE OR REPLACE FUNCTION check_parity RETURN VARCHAR2 IS
    even NUMBER;
    odd NUMBER;
    result VARCHAR2(20);
BEGIN
    SELECT COUNT(val) INTO even FROM MyTable WHERE REMAINDER(val, 2) = 0;
    SELECT COUNT(val) INTO odd FROM MyTable WHERE REMAINDER(val, 2) = 1;

    IF even > odd THEN
        result := 'TRUE';
    ELSIF even < odd THEN
        result := 'FALSE';
    ELSE
        result := 'EQUAL';
    END IF;    
        
    RETURN result;
END check_parity;

BEGIN
    dbms_output.put_line(check_parity());
END;

-- 4) Create function that output INSERT-command
CREATE OR REPLACE FUNCTION insert_command_output (id IN NUMBER) RETURN VARCHAR2 IS
    result VARCHAR2(100);
BEGIN
    result := 'INSERT INTO MyTable VALUES(' || TO_CHAR(id) || ',' 
                        || TO_CHAR(dbms_random.RANDOM()) || ');';
    RETURN result;
END insert_command_output;

BEGIN
    dbms_output.put_line(insert_command_output(9999));
END;

-- 5) Create procedures that implement DML-operations
--------------------------INSERT--------------------------
CREATE OR REPLACE PROCEDURE insert_proc (id NUMBER, val NUMBER) IS
BEGIN
    INSERT INTO MyTable VALUES(id, val);
END insert_proc;

--DELETE FROM MyTable WHERE id=10001;

BEGIN
    insert_proc(10001, 0);
END;

--SELECT * FROM MyTable WHERE id=10001;

--------------------------UPDATE--------------------------
CREATE OR REPLACE PROCEDURE update_proc (id NUMBER, new_val NUMBER) IS
BEGIN
    UPDATE MyTable SET val=new_val WHERE id=id;
END update_proc;

BEGIN
    update_proc(10001, 10);
END;

SELECT * FROM MyTable WHERE id=10001;

--------------------------DELETE--------------------------
CREATE OR REPLACE PROCEDURE delete_proc (id NUMBER) IS
BEGIN
    DELETE FROM MyTable WHERE id=id;
END delete_proc;

BEGIN
    delete_proc(10001);
END;

SELECT * FROM MyTable ORDER BY id DESC;

-- 6) Create function of salary sum per year
--DECLARE 
--    salary NUMBER;
--    premium NUMBER;
--    
--CREATE OR REPLACE FUNCTION year_revenue (salary IN NUMBER, premium IN NUMBER)
--        RETURN NUMBER IS
--    result NUMBER;
--BEGIN
--    
--    RETURN result;
--END year_revenue;    