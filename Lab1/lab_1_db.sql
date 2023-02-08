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
    SELECT COUNT(id) INTO counter FROM MyTable;
    
    FOR i IN 1..10000
    LOOP
        INSERT INTO MyTable VALUES ((counter + i), dbms_random.RANDOM());
    END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('something wrong!');
END;

SELECT * FROM MyTable;
SELECT COUNT(id) FROM MyTable;

-- 3) Create function that returns TRUE, FALSE or EQUAL
CREATE OR REPLACE FUNCTION check_parity RETURN VARCHAR2 IS
    even NUMBER;
    odd NUMBER;
    result VARCHAR2(5);
    unknown_result EXCEPTION;
BEGIN
    -- REMAINDER(num2, num1) - returns the remainder of n2 divided by n1 
    SELECT COUNT(val) INTO even FROM MyTable WHERE REMAINDER(val, 2) = 0;
    SELECT COUNT(val) INTO odd  FROM MyTable WHERE REMAINDER(val, 2) = 1;

    IF even > odd THEN
        result := 'TRUE';
    ELSIF even < odd THEN
        result := 'FALSE';
    ELSIF even = odd THEN
        result := 'EQUAL';
    ELSE 
        RAISE unknown_result;
    END IF;    
        
    RETURN result;
    
    EXCEPTION 
        WHEN unknown_result THEN
            dbms_output.put_line('strange result ?_?');
            RETURN NULL;
        WHEN OTHERS THEN    
            dbms_output.put_line('something wrong!');
            RETURN NULL;

END check_parity;

BEGIN
    dbms_output.put_line(check_parity());
END;

-- 4) Create function that output INSERT-command
CREATE OR REPLACE FUNCTION insert_command_output (new_id IN NUMBER) RETURN VARCHAR2 IS
    result VARCHAR2(100);
    is_exists NUMBER;
BEGIN
    SELECT COUNT(id) INTO is_exists FROM MyTable WHERE id=new_id;
    
    IF is_exists = 1 THEN
        RAISE DUP_VAL_ON_INDEX;
    ELSE    
        result := 'INSERT INTO MyTable VALUES(' || TO_CHAR(new_id) || ',' 
                            || TO_CHAR(dbms_random.RANDOM()) || ');';
    END IF;
    
    RETURN result;
    
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            dbms_output.put_line('such id already exists in the MyTable!');
            RETURN NULL;
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');
            RETURN NULL;

END insert_command_output;

BEGIN
    dbms_output.put_line(insert_command_output(999));
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
