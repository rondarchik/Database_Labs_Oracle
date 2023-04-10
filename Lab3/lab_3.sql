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

CREATE OR REPLACE PROCEDURE compare_schemas(
    dev_schema_name IN VARCHAR2,
    prod_schema_name IN VARCHAR2
)
IS 
    tables_count NUMBER;
    is_table_exists BOOLEAN;
    is_structure_diff BOOLEAN;
    is_cycle_detected BOOLEAN := FALSE;
BEGIN
    -- get number of tables in Dev-schema
    SELECT COUNT(*) INTO tables_count FROM ALL_TABLES WHERE OWNER = dev_schema_name;

    -- if there are no tables in Dev-schema -> STOP
    IF tables_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Schema ' || dev_schema_name || ' does not contain tables.');
    END IF;

     -- get list of tables in dev-schema
    FOR dev_table IN (SELECT table_name FROM all_tables WHERE owner = dev_schema_name)
    LOOP
        is_table_exists := FALSE;
        is_structure_diff := TRUE;

        -- table is exists in prod-schema?
        FOR prod_table IN (SELECT table_name FROM all_tables WHERE owner = prod_schema_name)
        LOOP
            IF dev_table.table_name = prod_table.table_name THEN
                is_table_exists := TRUE;

                -- is table structure different?
                FOR dev_column IN (SELECT column_name, data_type, data_length, nullable FROM ALL_TAB_COLUMNS
                                        WHERE owner = dev_schema_name AND table_name = dev_table.table_name)
                LOOP
                    is_structure_diff := FALSE;

                    FOR prod_column IN (SELECT column_name, data_type, data_length, nullable FROM ALL_TAB_COLUMNS
                                            WHERE owner = prod_schema_name AND table_name = prod_table.table_name)
                    LOOP
                        IF dev_column.column_name = prod_column.column_name AND
                            dev_column.data_type = prod_column.data_type AND
                            dev_column.data_length = prod_column.data_length AND
                            dev_column.nullable = prod_column.nullable THEN

                            is_structure_diff := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;

                    EXIT WHEN is_structure_diff = FALSE;
                END LOOP;

                EXIT;
            END IF;
        END LOOP;

        -- check cycles
        FOR record IN (SELECT * FROM all_constraints WHERE owner = dev_schema_name AND constraint_type = 'R')
        LOOP
            IF record.R_OWNER = dev_schema_name THEN
                is_cycle_detected := TRUE;
                EXIT;
            END IF;
        END LOOP;

        -- tables output (if there are)
        IF is_cycle_detected THEN
            dbms_output.put_line('Cycle dependence is detected in table: ' || dev_table.table_name);
        ELSIF NOT is_table_exists THEN
            dbms_output.put_line('Table ' || dev_table.table_name || ' does not exist in Prod schema');
        ELSIF NOT is_structure_diff THEN
            dbms_output.put_line('Structure of the table ' || dev_table.table_name || ' is different from table in Prod schema');
        -- ELSE
        --     dbms_output.put_line('All OK');
        END IF;

    END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('ERROR | ' || SQLERRM);

END compare_schemas;
