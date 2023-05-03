-- Task 1
-- Написать процедуру/функцию на вход которой подаются 
-- два текстовых параметра (dev_schema_name, prod_schema_name), 
-- которые являются названиями схем баз данных 
-- (условно схема для разработки(Dev) и промышленная схема(Prod)), 
-- на выход процедура должна предоставить перечень таблиц, 
-- которые есть в схеме Dev, но нет в Prod, либо в которых различается 
-- структура таблиц. Наименования таблиц должны быть отсортированы в 
-- соответствии с очередностью их возможного создания в схеме prod 
-- (необходимо учитывать foreign key в схеме). 
-- В случае закольцованных связей выводить соответствующее сообщение

DROP TABLE diff_tables;
DROP TABLE out_tables;

-- store 'list' of tables with differences in schemas
CREATE TABLE diff_tables (
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(100)
);

-- store 'list' of tables without differences
CREATE TABLE out_tables (
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(100)
);

CREATE OR REPLACE PROCEDURE compare_schemas(
    dev_schema_name IN VARCHAR2,
    prod_schema_name IN VARCHAR2
)
IS 
    tables_count NUMBER;
    columns_count NUMBER;

    ref_table VARCHAR2(100);
    ref_constraint VARCHAR2(100);
    ref_tables_count NUMBER;

    is_ref BOOLEAN := TRUE;
BEGIN
    -- get number of tables in Dev-schema
    SELECT COUNT(*) INTO tables_count FROM ALL_TABLES WHERE OWNER = dev_schema_name;

    -- if there are no tables in Dev-schema -> STOP
    IF tables_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Schema ' || dev_schema_name || ' does not contain tables.');
    END IF;

     -- get list of tables in dev-schema
    FOR tab IN (SELECT * FROM all_tables WHERE owner = dev_schema_name)
    LOOP
        -- get number of tables with same name in Prod-schema
        SELECT COUNT(*) INTO tables_count FROM all_tables WHERE owner=prod_schema_name AND table_name=tab.table_name;
        
        -- table is exists in prod-schema?
        IF tables_count = 1 THEN
            FOR col IN (SELECT * FROM all_tab_columns WHERE table_name=tab.table_name AND owner=dev_schema_name)
            LOOP
                SELECT COUNT(*) INTO columns_count FROM all_tab_columns WHERE owner=prod_schema_name AND
                                                                              column_name=col.column_name AND
                                                                              data_type=col.data_type AND
                                                                              data_length=col.data_length AND
                                                                              nullable=col.nullable;

                IF columns_count = 0 THEN
                -- -> tables structure is different
                    INSERT INTO diff_tables VALUES(tab.table_name, 'structure');
                END IF;
                EXIT WHEN columns_count=0;
            END LOOP;
        ELSE
            INSERT INTO diff_tables VALUES (tab.table_name, 'not exists');
        END IF;
    END LOOP;

    -- check fk & cycle 
    SELECT COUNT(*) INTO tables_count FROM diff_tables;

    WHILE tables_count != 0
    LOOP
        FOR tab IN (SELECT * FROM diff_tables) LOOP
            FOR fk IN (SELECT * FROM all_constraints WHERE owner=dev_schema_name AND 
                                        table_name=tab.name AND constraint_type='R')
            LOOP
                check_cycle(fk.r_constraint_name, dev_schema_name, fk.table_name);
                
                SELECT table_name INTO ref_table FROM all_constraints 
                    WHERE constraint_name=fk.r_constraint_name;
                
                SELECT COUNT(*) INTO ref_tables_count FROM out_tables WHERE name=ref_table;

                IF ref_tables_count = 0 THEN
                    is_ref := FALSE;
                END IF;
            END LOOP;

            IF is_ref THEN
                DELETE FROM diff_tables WHERE name=tab.name;
                INSERT INTO out_tables VALUES(tab.name, tab.description);
            END IF;

            is_ref := TRUE;

        END LOOP;

        SELECT COUNT(*) INTO tables_count FROM diff_tables;

    END LOOP;

    SELECT COUNT(*) INTO tables_count FROM out_tables;
    
    IF tables_count = 0 THEN
        dbms_output.put_line('There are no differences!');
    ELSE
        FOR tab IN (SELECT * FROM out_tables) LOOP
            dbms_output.put_line(tab.name);
        END LOOP;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('ERROR | ' || SQLERRM);

END compare_schemas;

CREATE OR REPLACE PROCEDURE check_cycle (
    ref_constraint_name IN VARCHAR2,
    dev_schema_name IN VARCHAR2,
    start_table_name IN VARCHAR2,
    cur_table_name IN VARCHAR2 DEFAULT NULL
)
IS 
    ref_table_name VARCHAR2(100);
BEGIN
    IF cur_table_name IS NULL THEN
        SELECT table_name INTO ref_table_name FROM all_constraints 
            WHERE constraint_name=ref_constraint_name;
    ELSE
        SELECT table_name INTO ref_table_name FROM all_constraints 
            WHERE constraint_name=ref_constraint_name AND table_name!=cur_table_name;
    END IF;

    IF ref_table_name = start_table_name THEN
        RAISE_APPLICATION_ERROR(-20003, 'Loop detected in foreign keys for table ' || dev_schema_name ||
                '.' || start_table_name || '!');
    ELSE
        FOR fk IN (SELECT * FROM all_constraints WHERE owner=dev_schema_name AND table_name=ref_table_name AND constraint_type='R')
        LOOP
            check_cycle(fk.r_constraint_name, dev_schema_name, start_table_name, ref_table_name);
        END LOOP;
    END IF;
END check_cycle;
