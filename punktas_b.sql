DECLARE
    TYPE invalid_record_type IS
        RECORD ( student_id NUMBER, subject_id NUMBER, reason VARCHAR2(200) );
    TYPE invalid_records_table_type IS
        TABLE OF invalid_record_type;
    invalid_records_table invalid_records_table_type;
    CURSOR c_invalid_records IS
        SELECT
            cs.student_id,
            cs.subject_id,
            CASE
                WHEN s.semester != sub.semester THEN
                    'Semester mismatch'
                WHEN l.faculty_id != s.faculty_id THEN
                    'Lecturer faculty mismatch'
                ELSE
                    'Student has chosen the subject only once'
            END AS reason
        FROM
            choosen_subject cs
            JOIN student s
            ON cs.student_id = s.id JOIN subject sub
            ON cs.subject_id = sub.id
            JOIN lecturer l
            ON sub.lecturer_id = l.id
        WHERE
            s.semester != sub.semester
            OR l.faculty_id != s.faculty_id
            OR (
                SELECT
                    COUNT(*)
                FROM
                    choosen_subject cs2
                WHERE
                    cs2.student_id = cs.student_id
                    AND cs2.subject_id = cs.subject_id
            ) = 1;
BEGIN
    OPEN c_invalid_records;
    FETCH c_invalid_records BULK COLLECT INTO invalid_records_table;
    CLOSE c_invalid_records;
    FORALL i IN 1..invalid_records_table.count
        INSERT INTO invalid_records (
            student_id,
            subject_id,
            reason
        ) VALUES (
            invalid_records_table(i).student_id,
            invalid_records_table(i).subject_id,
            invalid_records_table(i).reason
        );
END;
/