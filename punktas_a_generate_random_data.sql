-- Punktas A

DECLARE
    v_faculty_count  NUMBER := 10;
    v_student_count  NUMBER := 100;
    v_lecturer_count NUMBER := 20;
    v_subject_count  NUMBER := 50;
    v_choice_count   NUMBER := 200;
BEGIN
 -- Insert random faculties
    FOR i IN 1..v_faculty_count LOOP
        INSERT INTO faculty (
            faculty_name
        ) VALUES (
            'Faculty '
                || i
        );
    END LOOP;
 -- Insert random students
    FOR i IN 1..v_student_count LOOP
        INSERT INTO student (
            first_name,
            last_name,
            address,
            semester,
            faculty_id
        ) VALUES (
            'FirstName'
                || i,
            'LastName'
                || i,
            'Address '
                || i,
            trunc(dbms_random.value(1, 8)),
            trunc(dbms_random.value(1, v_faculty_count))
        );
    END LOOP;
 -- Insert random lecturers
    FOR i IN 1..v_lecturer_count LOOP
        INSERT INTO lecturer (
            first_name,
            last_name,
            faculty_id
        ) VALUES (
            'FirstName'
                || i,
            'LastName'
                || i,
            trunc(dbms_random.value(1, v_faculty_count))
        );
    END LOOP;
 -- Insert random subjects
    FOR i IN 1..v_subject_count LOOP
        INSERT INTO subject (
            lecturer_id,
            name,
            description,
            semester
        ) VALUES (
            trunc(dbms_random.value(1, v_lecturer_count)),
            'Subject '
                || i,
            'Description of Subject '
                || i,
            trunc(dbms_random.value(1, 8))
        );
    END LOOP;
 -- Insert random choices
    FOR i IN 1..v_choice_count LOOP
        INSERT INTO choosen_subject (
            subject_id,
            student_id,
            created_at
        ) VALUES (
            trunc(dbms_random.value(1, v_subject_count)),
            trunc(dbms_random.value(1, v_student_count)),
            sysdate - trunc(dbms_random.value(0, 365))
        );
    END LOOP;
END;
/
