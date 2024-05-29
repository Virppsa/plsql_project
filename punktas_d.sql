CREATE OR REPLACE FUNCTION remove_invalid_choices RETURN VARCHAR2 IS
    v_deleted_count NUMBER := 0;
    v_reason VARCHAR2(200);
BEGIN
    -- Loop through all records in choosen_subject
    FOR rec IN (SELECT student_id, subject_id FROM choosen_subject) LOOP
        -- Validate each record using validate_choice function
        v_reason := validate_choice(rec.student_id, rec.subject_id);
        
        -- Check the validation result and delete the record if invalid
        IF v_reason != 'Valid' THEN
            DELETE FROM choosen_subject cs
            WHERE cs.student_id = rec.student_id AND cs.subject_id = rec.subject_id;
            v_deleted_count := v_deleted_count + SQL%ROWCOUNT;
            
            -- Optionally, insert the invalid record and reason into invalid_records table
            -- Assuming you have an invalid_records table to store these details
            INSERT INTO invalid_records (student_id, subject_id, reason)
            VALUES (rec.student_id, rec.subject_id, v_reason);
        END IF;
    END LOOP;

    RETURN 'Total invalid records deleted: ' || v_deleted_count;
EXCEPTION
    WHEN OTHERS THEN
        -- Assuming G_ERROR_HANDLING.LOG_ERROR() is a custom procedure to log errors
        G_ERROR_HANDLING.LOG_ERROR();
        RETURN 'An error occurred: ' || SQLERRM;
END remove_invalid_choices;
/


SET SERVEROUTPUT ON

DECLARE
    v_result VARCHAR2(200);
BEGIN
    v_result := remove_invalid_choices;
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
