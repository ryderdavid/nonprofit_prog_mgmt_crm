-- Stored Procedure for Adding Data to Person-Employee Entity ---------------------------------

CREATE OR REPLACE FUNCTION add_employee_func(
    person_id IN DECIMAL, first_name IN VARCHAR, last_name IN VARCHAR,
    email IN VARCHAR, phone IN DECIMAL, hire_date IN DATE
) RETURNS VOID
AS
    $proc$
        BEGIN
            INSERT INTO person(person_id, first_name, last_name, email, phone,
                               first_entered, is_employee, is_expert)
            VALUES (person_id, first_name, last_name, email, phone, current_date, TRUE, FALSE);

            INSERT INTO employee(employee_id, hire_date)
            VALUES (person_id, CAST(hire_date AS DATE));
        END;
    $proc$ LANGUAGE plpgsql

CREATE OR REPLACE FUNCTION add_expert_func(
    person_id IN DECIMAL, first_name IN VARCHAR, last_name IN VARCHAR,
    email IN VARCHAR, phone IN DECIMAL, address_id
) RETURNS VOID
AS
    $proc$
        BEGIN
            INSERT INTO person(person_id, first_name, last_name, email, phone,
                               first_entered, is_employee, is_expert)
            VALUES (person_id, first_name, last_name, email, phone, current_date, TRUE, FALSE);

            INSERT INTO employee(employee_id, hire_date)
            VALUES (person_id, CAST(hire_date AS DATE));
        END;
    $proc$ LANGUAGE plpgsql


-- Execute Stored Procedure for Adding to Person - Employee Entity
START TRANSACTION;
DO
    $$BEGIN
            EXECUTE public.add_employee_func(
                999999999, 'Ryder', 'Cobean', 'ryder@americanbar.org', 15554451111, CAST('1-Jul-2014' AS pg_catalog.DATE)
            );
    END$$;
COMMIT TRANSACTION;



SELECT
       person_id,
       first_name || ' ' || last_name AS employee_name,
       email,
       phone
FROM person
JOIN employee e ON person.person_id = e.employee_id;