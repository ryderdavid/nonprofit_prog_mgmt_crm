-- Stored Procedure for Adding Data to Person-Employee Entity ---------------------------------

CREATE OR REPLACE FUNCTION add_employee_func(
    first_name IN VARCHAR, last_name IN VARCHAR, email IN VARCHAR, phone IN DECIMAL, hire_date IN DATE
) RETURNS VOID
AS
    $proc$
        BEGIN
            INSERT INTO person(person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
            VALUES (DEFAULT, first_name, last_name, email, phone, current_date, TRUE, FALSE);

            INSERT INTO employee(employee_id, hire_date)
            VALUES (currval('person_person_id_seq'), CAST(hire_date AS DATE));
        END;
    $proc$ LANGUAGE plpgsql;



-- Stored Procedure for Adding Data to Person-Employee Entity with THemes---------------------------------
CREATE OR REPLACE FUNCTION add_expert_with_themes_func(
    first_name IN VARCHAR, last_name IN VARCHAR, email IN VARCHAR, phone IN DECIMAL,
    street_num IN VARCHAR, street_name IN VARCHAR, city IN VARCHAR, subnational_div IN VARCHAR,
    address_country IN VARCHAR, postal_code IN VARCHAR, themes IN VARCHAR
) RETURNS VOID
AS
    $proc$
        DECLARE
            v_themes VARCHAR[] := string_to_array(themes, ',');
            t VARCHAR;

        BEGIN
            INSERT INTO person(person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
            VALUES (DEFAULT, first_name, last_name, email, phone, current_date, FALSE, TRUE);

            INSERT INTO address (address_id, street_num, street_name, city, subnational_div, address_country, postal_code)
            VALUES (DEFAULT, street_num, street_name, city, subnational_div, address_country, postal_code);

            INSERT INTO expert(expert_id, address_id)
            VALUES (currval('person_person_id_seq'), currval('address_address_id_seq'));

            FOREACH t IN ARRAY v_themes
                LOOP
                    INSERT INTO expert_categorization(expert_id, theme_code)
                    VALUES (currval('person_person_id_seq'), t);
                END LOOP;
        END;
    $proc$ LANGUAGE plpgsql;



-- Stored Procedure for Adding Data to Program Entity with Themes ---------------------------------
CREATE OR REPLACE FUNCTION add_program_with_themes_func(
    
) RETURNS VOID
AS
    $proc$
        DECLARE
            v_themes VARCHAR[] := string_to_array(themes, ',');
            t VARCHAR;

        BEGIN
            INSERT INTO person(person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
            VALUES (DEFAULT, first_name, last_name, email, phone, current_date, FALSE, TRUE);

            INSERT INTO address (address_id, street_num, street_name, city, subnational_div, address_country, postal_code)
            VALUES (DEFAULT, street_num, street_name, city, subnational_div, address_country, postal_code);

            INSERT INTO expert(expert_id, address_id)
            VALUES (currval('person_person_id_seq'), currval('address_address_id_seq'));

            FOREACH t IN ARRAY v_themes
                LOOP
                    INSERT INTO expert_categorization(expert_id, theme_code)
                    VALUES (currval('person_person_id_seq'), t);
                END LOOP;
        END;
    $proc$ LANGUAGE plpgsql;




















-- Execute Stored Procedure for Adding to Person - Employee Entity
START TRANSACTION;
DO
    $$BEGIN
            EXECUTE public.add_employee_func(
                'Ryder', 'Cobean', 'ryder@americanbar.org', 15554451111, CAST('1-Jul-2014' AS DATE)
            );
    END$$;
COMMIT TRANSACTION;

-- Execute Stored Procedure for Adding Expert to Person - Expert and Address
START TRANSACTION;
DO
    $$BEGIN
            EXECUTE public.add_expert_with_themes_func(
                'Berg', 'Dunberg', 'berg@Dunberglaw.org', 15551166666611, '97087', 'Balthergreen Street', 'Sprogfold', 'California', 'USA', '90219', 'A2J,COM,HR,HE'
            );
    END$$;
COMMIT TRANSACTION;















DELETE FROM person;

ROLLBACK TRANSACTION;












