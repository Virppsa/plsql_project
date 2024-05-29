CREATE OR REPLACE FUNCTION save_valid_choice(
    p_student_id NUMBER,
    p_subject_id NUMBER
) RETURN VARCHAR2 IS
    v_validation_result VARCHAR2(100);
BEGIN
    -- Validate the choice
    v_validation_result := validate_choice(p_student_id, p_subject_id);

    -- Check validation result
    IF v_validation_result = 'Valid' THEN
        -- Insert the valid choice
        INSERT INTO choosen_subject (subject_id, student_id, created_at)
        VALUES (p_subject_id, p_student_id, SYSDATE);
        RETURN 'Choice saved successfully';
    ELSE
        RETURN v_validation_result;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        G_ERROR_HANDLING.LOG_ERROR();
        RETURN 'An error occurred: ' || SQLERRM;
END save_valid_choice;
/
