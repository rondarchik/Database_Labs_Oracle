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

--SELECT * FROM MyTable;
--SELECT COUNT(id) FROM MyTable;

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
            dbms_output.put_line('id=' || TO_CHAR(new_id) || 
                    ' already exists in the MyTable!');
            RETURN NULL;
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');
            RETURN NULL;

END insert_command_output;

BEGIN
    dbms_output.put_line(insert_command_output(99999));
END;

-- 5) Create procedures that implement DML-operations
--------------------------INSERT--------------------------
CREATE OR REPLACE PROCEDURE insert_proc (new_id NUMBER, val NUMBER) IS
    is_exists NUMBER;
BEGIN
    SELECT COUNT(id) INTO is_exists FROM MyTable WHERE id=new_id;

    IF is_exists = 1 THEN
        RAISE DUP_VAL_ON_INDEX;
    ELSE
        INSERT INTO MyTable VALUES(new_id, val);
    END IF;
    
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            dbms_output.put_line('id=' || TO_CHAR(new_id) || 
                    ' already exists in the MyTable!');
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');

END insert_proc;

BEGIN
    insert_proc(10001, 0);
END;

--SELECT * FROM MyTable WHERE id=10001;

--------------------------UPDATE--------------------------
CREATE OR REPLACE PROCEDURE update_proc (need_id NUMBER, new_val NUMBER) IS
    is_exists NUMBER;
BEGIN
    SELECT COUNT(id) INTO is_exists FROM MyTable WHERE id=need_id;

    IF is_exists = 1 THEN
        UPDATE MyTable SET val=new_val WHERE id=need_id;
    ELSE        
        RAISE NO_DATA_FOUND;
    END IF;    
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('id=' || TO_CHAR(need_id) || 
                    ' does not exists in the MyTable!');
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');
            
END update_proc;

BEGIN
    update_proc(10001, 10);
END;

--SELECT * FROM MyTable WHERE id=101;

--------------------------DELETE--------------------------
CREATE OR REPLACE PROCEDURE delete_proc (need_id NUMBER) IS
    is_exists NUMBER;
BEGIN
    SELECT COUNT(id) INTO is_exists FROM MyTable WHERE id=need_id;

    IF is_exists = 1 THEN
        DELETE FROM MyTable WHERE id=need_id;
    ELSE        
        RAISE NO_DATA_FOUND;
    END IF;    
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('id=' || TO_CHAR(need_id) || 
                    ' does not exists in the MyTable!');
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');
            
END delete_proc;

BEGIN
    delete_proc(10000);
END;

-- 6) Create function of salary sum per year   
CREATE OR REPLACE FUNCTION year_revenue (salary IN VARCHAR2, 
        premium_percent IN VARCHAR2) RETURN NUMBER IS
    result NUMBER;
    frac_percent FLOAT;
    incorrect_percent_value EXCEPTION;
    incorrect_type EXCEPTION;
BEGIN
    IF NOT(REGEXP_LIKE(salary, '^[0-9]+$')) OR 
            NOT(REGEXP_LIKE(premium_percent, '^[0-9]+$')) THEN
        RAISE incorrect_type;
    ELSIF TO_NUMBER(premium_percent) < 0 OR TO_NUMBER(premium_percent) > 100 THEN
        RAISE incorrect_percent_value;    
    END IF;    

    frac_percent := TO_NUMBER(premium_percent) / 100;
    result := (1 + frac_percent) * 12 * TO_NUMBER(salary);
    
    RETURN result;
    
    EXCEPTION 
        WHEN incorrect_percent_value THEN
            dbms_output.put_line('Premium percent must be in range of [0, 100]!'
                    || CHR(10) || 'You entered: ' || TO_CHAR(premium_percent));
            RETURN NULL;
        WHEN incorrect_type THEN
            dbms_output.put_line('An integer is required!');
            RETURN NULL;
        WHEN OTHERS THEN             
            dbms_output.put_line('something wrong!');
            RETURN NULL;
    
END year_revenue; 

BEGIN
    dbms_output.put_line(year_revenue(100, 30));
END;
