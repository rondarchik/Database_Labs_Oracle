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
    is_table_exists BOOLEAN;
    is_columns_exists BOOLEAN;
    is_loops_exists BOOLEAN := FALSE;
BEGIN
    -- get list of tables in dev-schema
    FOR dev_table IN (SELECT table_name FROM all_tables WHERE owner = dev_schema_name)
    LOOP
        is_table_exists := FALSE;
        is_columns_exists := TRUE;

        -- table is exists in prod-schema?
        FOR prod_table IN (SELECT table_name FROM all_tables WHERE owner = prod_schema_name)
        LOOP
            IF dev_table.table_name = prod_table.table_name THEN
                is_table_exists := TRUE;

                -- is table structure identical?
            END IF;
        END LOOP;
    END LOOP;
END;