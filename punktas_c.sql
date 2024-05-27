CREATE OR REPLACE FUNCTION save_valid_choice(
    p_student_id NUMBER,
    p_subject_id NUMBER
) RETURN VARCHAR2 IS
    v_student_semester    NUMBER;
    v_student_faculty_id  NUMBER;
    v_subject_semester    NUMBER;
    v_lecturer_faculty_id NUMBER;
    v_choice_count        NUMBER;
    v_lecturer_id         NUMBER;
BEGIN
 -- Get student information
    SELECT
        semester,
        faculty_id INTO v_student_semester,
        v_student_faculty_id
    FROM
        student
    WHERE
        id = p_student_id;
 -- Get subject and lecturer information
    SELECT
        sub.semester,
        l.faculty_id,
        sub.lecturer_id INTO v_subject_semester,
        v_lecturer_faculty_id,
        v_lecturer_id
    FROM
        subject  sub
        JOIN lecturer l
        ON sub.lecturer_id = l.id
    WHERE
        sub.id = p_subject_id;
 -- Check if the student has chosen this subject more than once
    SELECT
        COUNT(*) INTO v_choice_count
    FROM
        choosen_subject
    WHERE
        student_id = p_student_id
        AND subject_id = p_subject_id;
 -- Validation
    IF v_student_semester != v_subject_semester THEN
        RETURN 'Semester mismatch';
    ELSIF v_student_faculty_id != v_lecturer_faculty_id THEN
        RETURN 'Lecturer faculty mismatch';
    ELSIF v_choice_count > 0 THEN
        RETURN 'Student has already chosen this subject';
    ELSE
 -- Insert the valid choice
        INSERT INTO choosen_subject (
            subject_id,
            student_id,
            created_at
        ) VALUES (
            p_subject_id,
            p_student_id,
            sysdate
        );
        RETURN 'Choice saved successfully';
    END IF;
EXCEPTION
    WHEN no_data_found THEN
        RETURN 'Student or subject not found';
    WHEN OTHERS THEN
        RETURN 'An error occurred: '
            || sqlerrm;
END save_valid_choice;
/

DECLARE
    v_result VARCHAR2(100);
BEGIN
    FOR i IN 1..100 LOOP
        v_result := save_valid_choice(i, 10);
        dbms_output.put_line(v_result);
    END LOOP;
END;
/