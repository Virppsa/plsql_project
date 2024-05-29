SET SERVEROUTPUT ON;

DECLARE
    -- Variables to hold new record data
    v_student_id NUMBER := 1; -- Example student ID
    v_subject_id NUMBER := 14; -- Example subject ID
    v_validation_result VARCHAR2(100);

BEGIN
    -- Validate the new record
    v_validation_result := validate_choice(v_student_id, v_subject_id);

    -- Check validation result
    IF v_validation_result = 'Valid' THEN
        -- Insert the valid record
        INSERT INTO choosen_subject (subject_id, student_id, created_at)
        VALUES (v_subject_id, v_student_id, SYSDATE);
        DBMS_OUTPUT.PUT_LINE('Record inserted successfully');
    ELSE
        -- Print rejection reason
        DBMS_OUTPUT.PUT_LINE('Record rejected: ' || v_validation_result);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
