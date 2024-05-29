CREATE OR REPLACE FUNCTION validate_choice(
    p_student_id NUMBER,
    p_subject_id NUMBER
) RETURN VARCHAR2 IS
    v_student_semester    NUMBER;
    v_student_faculty_id  NUMBER;
    v_subject_semester    NUMBER;
    v_lecturer_faculty_id NUMBER;
    v_choice_count        NUMBER;
    v_lecturer_id         NUMBER;
    
    -- Parametrized cursor for student information
    CURSOR c_student_info(p_student_id NUMBER) IS
        SELECT semester, faculty_id
        FROM student
        WHERE id = p_student_id;
    
    -- Parametrized cursor for subject and lecturer information
    CURSOR c_subject_info(p_subject_id NUMBER) IS
        SELECT sub.semester, l.faculty_id, sub.lecturer_id
        FROM subject sub
        JOIN lecturer l ON sub.lecturer_id = l.id
        WHERE sub.id = p_subject_id;
    
    -- Parametrized cursor for choice count
    CURSOR c_choice_count(p_student_id NUMBER, p_subject_id NUMBER) IS
        SELECT COUNT(*)
        FROM choosen_subject
        WHERE student_id = p_student_id AND subject_id = p_subject_id;

BEGIN
    -- Get student information
    OPEN c_student_info(p_student_id);
    FETCH c_student_info INTO v_student_semester, v_student_faculty_id;
    CLOSE c_student_info;
    
    -- Get subject and lecturer information
    OPEN c_subject_info(p_subject_id);
    FETCH c_subject_info INTO v_subject_semester, v_lecturer_faculty_id, v_lecturer_id;
    CLOSE c_subject_info;
    
    -- Check if the student has chosen this subject more than once
    OPEN c_choice_count(p_student_id, p_subject_id);
    FETCH c_choice_count INTO v_choice_count;
    CLOSE c_choice_count;

    -- Validation
    IF v_student_semester != v_subject_semester THEN
        RETURN 'Semester mismatch';
    ELSIF v_student_faculty_id != v_lecturer_faculty_id THEN
        RETURN 'Lecturer faculty mismatch';
    ELSIF v_choice_count > 1 THEN  -- Note: Changed from > 0 to > 1
        RETURN 'Student has already chosen this subject';
    ELSE
        RETURN 'Valid';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Student or subject not found';
    WHEN OTHERS THEN
        G_ERROR_HANDLING.LOG_ERROR();
        RETURN 'An error occurred: ' || SQLERRM;
END validate_choice;
/
