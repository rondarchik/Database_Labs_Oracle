ALTER SESSION SET "_ORACLE_SCRIPT"=true;

-- TASK 1
DROP TABLE Table1;
DROP TABLE Table2;
DROP TABLE Table3;

CREATE TABLE Table2 (
    id NUMBER PRIMARY KEY,
    str_column VARCHAR2(50) NOT NULL,
    number_column NUMBER,
    date_time_column DATE
);

CREATE TABLE Table3 (
    id NUMBER PRIMARY KEY,
    str_column VARCHAR2(50) NOT NULL,
    number_column NUMBER,
    date_time_column DATE
);

CREATE TABLE Table1 (
    id NUMBER PRIMARY KEY,
    str_column VARCHAR2(50) NOT NULL,
    number_column NUMBER,
    date_time_column DATE,
    table2_id NUMBER,
    table3_id NUMBER,

    CONSTRAINT fk_t1_to_t2 FOREIGN KEY(table2_id) REFERENCES Table2(id),
    CONSTRAINT fk_t1_to_t3 FOREIGN KEY(table3_id) REFERENCES Table3(id)
);
