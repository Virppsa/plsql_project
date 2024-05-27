CREATE OR REPLACE FUNCTION remove_invalid_choices RETURN VARCHAR2 IS
    v_deleted_count NUMBER := 0;
BEGIN
 -- Delete invalid records and count them
 -- Condition 1: Semester mismatch
    DELETE FROM choosen_subject cs
    WHERE
        EXISTS (
            SELECT
                1
            FROM
                student  s,
                subject  sub
            WHERE
                cs.student_id = s.id
                AND cs.subject_id = sub.id
                AND s.semester != sub.semester
        );
    v_deleted_count := v_deleted_count + sql%rowcount;
 -- Condition 2: Lecturer faculty mismatch
    DELETE FROM choosen_subject cs
    WHERE
        EXISTS (
            SELECT
                1
            FROM
                student  s,
                subject  sub,
                lecturer l
            WHERE
                cs.student_id = s.id
                AND cs.subject_id = sub.id
                AND sub.lecturer_id = l.id
                AND s.faculty_id != l.faculty_id
        );
    v_deleted_count := v_deleted_count + sql%rowcount;
 -- Condition 3: Student has chosen the subject only once
    DELETE FROM choosen_subject cs
    WHERE
        (
            SELECT
                COUNT(*)
            FROM
                choosen_subject cs2
            WHERE
                cs2.student_id = cs.student_id
                AND cs2.subject_id = cs.subject_id
        ) = 1;
    v_deleted_count := v_deleted_count + sql%rowcount;
    RETURN 'Total invalid records deleted: '
        || v_deleted_count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'An error occurred: '
            || sqlerrm;
END remove_invalid_choices;
/