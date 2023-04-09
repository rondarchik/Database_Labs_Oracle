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
    is_column_exists BOOLEAN;
    is_loop_exists BOOLEAN := FALSE;
BEGIN
    -- get list of tables in dev-schema
    FOR dev_table IN (SELECT table_name FROM all_tables WHERE owner = dev_schema_name)
    LOOP
        is_table_exists := FALSE;
        is_column_exists := TRUE;

        -- table is exists in prod-schema?
        FOR prod_table IN (SELECT table_name FROM all_tables WHERE owner = prod_schema_name)
        LOOP
            IF dev_table.table_name = prod_table.table_name THEN
                is_table_exists := TRUE;

                -- is table structure identical?
                FOR dev_column IN (SELECT column_name, data_type, data_length, nullable FROM ALL_TAB_COLUMNS
                                        WHERE owner = dev_schema_name AND table_name = dev_table.table_name)
                LOOP
                    is_column_exists := FALSE;

                    FOR prod_column IN (SELECT column_name, data_type, data_length, nullable FROM ALL_TAB_COLUMNS
                                            WHERE owner = prod_schema_name AND table_name = prod_table.table_name)
                    LOOP
                        IF dev_column.column_name = prod_column.column_name AND
                            dev_column.data_type = prod_column.data_type AND
                            dev_column.data_length = prod_column.data_length AND
                            dev_column.nullable = prod_column.nullable THEN

                            is_column_exists := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;

                    EXIT WHEN is_column_exists = FALSE;
                END LOOP;

                EXIT;
            END IF;
        END LOOP;

        
    END LOOP;
END;