SET SERVEROUTPUT ON;

DECLARE
    TYPE invalid_record_type IS RECORD (
        student_id NUMBER,
        subject_id NUMBER,
        reason VARCHAR2(200)
    );
    TYPE invalid_records_table_type IS TABLE OF invalid_record_type;
    invalid_records_table invalid_records_table_type;

    -- Kursorius be parametru
    CURSOR c_invalid_records IS
        SELECT cs.student_id, cs.subject_id,
               validate_choice(cs.student_id, cs.subject_id) AS reason
        FROM choosen_subject cs;

BEGIN
    -- Naudojame kursoriu tam, kad gauti visus neteisingu irasus
    OPEN c_invalid_records;
    FETCH c_invalid_records BULK COLLECT INTO invalid_records_table;
    CLOSE c_invalid_records;

        -- Tikriname ar buvo rasta neteisingu irasu
    IF invalid_records_table.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No invalid records found.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid records found: ' || invalid_records_table.COUNT);
    END IF;

    -- Spausdiname neteisingus irasus (tiesiog sau)
    FOR i IN 1..invalid_records_table.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Student ID: ' || invalid_records_table(i).student_id ||
                             ', Subject ID: ' || invalid_records_table(i).subject_id ||
                             ', Reason: ' || invalid_records_table(i).reason);
    END LOOP;

    -- Iteruojame per visus neteisingus irasus ir juos iterpiame i invalid_records lentele
    FORALL i IN 1..invalid_records_table.COUNT
        INSERT INTO invalid_records (student_id, subject_id, reason)
        VALUES (invalid_records_table(i).student_id, invalid_records_table(i).subject_id, invalid_records_table(i).reason);
END;
/
