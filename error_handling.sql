CREATE TABLE ERROR_LOG_TABLE (
    ERROR_CODE INTEGER,
    ERROR_MESSAGE VARCHAR2(4000),
    BACKTRACE CLOB,
    USERNAME VARCHAR2(256),
    TIMESTAMP TIMESTAMP
);

--Lentelę error mesages įmesti gali ir keisas būti. Surišimas tarp error mesage ir num turi būti tik per funkciją sql errm
--DMS_OUTPUT.paduodam kalaidos visus stuff
--When not innitialized lala - su tuo jei nėra array

CREATE OR REPLACE PACKAGE G_ERROR_HANDLING IS
    NEGATIVE_ARRAY_EXCEPTION EXCEPTION;
    TARGET_NOT_FOUND_EXCEPTION EXCEPTION;
    SEARCH_TYPE_IS_EMPTY_EXCEPTION EXCEPTION;
 --
    PRAGMA EXCEPTION_INIT(NEGATIVE_ARRAY_EXCEPTION, -20008); --Elsas neatpažįstant - selektini iš lentelės tada, jei nerandi, tada standartinė klaisa su standartiniu error message
    PRAGMA EXCEPTION_INIT(TARGET_NOT_FOUND_EXCEPTION, -20009);
    PRAGMA EXCEPTION_INIT(SEARCH_TYPE_IS_EMPTY_EXCEPTION, -20010); --Error messages funkcijos get error message būtinai
 --
    PROCEDURE LOG_ERROR;
END G_ERROR_HANDLING;
/

CREATE OR REPLACE PACKAGE BODY G_ERROR_HANDLING IS
 -- Funkcija tam, kad gauti error message
    FUNCTION GET_ERROR_MESSAGE RETURN VARCHAR2 IS
        ERROR_CODE  NUMBER := SQLCODE;
        ERR_MESSAGE VARCHAR2(250);
    BEGIN
        IF ERROR_CODE < -21000 OR ERROR_CODE > -20000 THEN
 -- Kai nera custom erroras, paemame is SQLERRM
            RETURN SQLERRM;
        END IF;
        CASE ERROR_CODE
            WHEN -20008 THEN
                ERR_MESSAGE := 'The array cannot be of negative length'; --Pervadinti
            WHEN -20009 THEN
                ERR_MESSAGE := 'Target is not found';
            WHEN -20010 THEN
                ERR_MESSAGE := 'Search type is empty';
            ELSE
                ERR_MESSAGE := 'unknown';
        END CASE;
        RETURN ERR_MESSAGE;
    END; --
 -- Procedura tam, kad islogginti error message
    PROCEDURE LOG_ERROR IS
        ERROR_CODE    VARCHAR2(20) := TO_CHAR(SQLCODE);
        ERROR_MESSAGE VARCHAR2(250) := GET_ERROR_MESSAGE();
        BACKTRACE     CLOB := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        USERNAME      VARCHAR2(256) := USER;
 --Prag autonomous tranzaction čia atsidaryti.
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO ERROR_LOG_TABLE (
            ERROR_CODE,
            ERROR_MESSAGE,
            BACKTRACE,
            USERNAME,
            TIMESTAMP
        ) VALUES (
            ERROR_CODE,
            ERROR_MESSAGE,
            BACKTRACE,
            USERNAME,
            SYSTIMESTAMP
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Error happened: '
            || TO_CHAR(ERROR_CODE)
            || ', error message: '
            || ERROR_MESSAGE
            || ', made by user: '
            || USERNAME);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error is not custom defined: '
                || SQLERRM);
            RAISE;
    END LOG_ERROR; -- Funkcija kad gauti error message
END G_ERROR_HANDLING;
/
