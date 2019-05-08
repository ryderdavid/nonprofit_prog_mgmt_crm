-- Stored Procedure for Adding Employee Entity ------------------------------------------------

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



-- Stored Procedure for Adding Expert ----------------------------------------------------------
CREATE OR REPLACE FUNCTION add_expert_with_themes_func( -- create or replace a parameterized function with the below arguments to pass to the function
    first_name IN VARCHAR, last_name IN VARCHAR, email IN VARCHAR, phone IN DECIMAL,
    street_num IN VARCHAR, street_name IN VARCHAR, city IN VARCHAR, subnational_div IN VARCHAR,
    address_country IN VARCHAR, postal_code IN VARCHAR, themes IN VARCHAR
) RETURNS VOID -- required by plpgsql syntax
AS -- required syntax
    $proc$ -- starts the procedure block
        DECLARE  -- starts a variable declaration section
            v_themes VARCHAR[] := string_to_array(themes, ',');  -- array variable for taking parsed comma-sep theme codes 'A2J,AC,COM' -- like that
            t VARCHAR;  -- a counter variable

        BEGIN  -- begin procedure block
            INSERT INTO person(person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)  -- insert into the person table
            VALUES (DEFAULT, first_name, last_name, email, phone, current_date, FALSE, TRUE);  -- as these passed and set values

            INSERT INTO address (address_id, street_num, street_name, city, subnational_div, address_country, postal_code)  -- insert into address table
            VALUES (DEFAULT, street_num, street_name, city, subnational_div, address_country, postal_code);  -- as these passed and set values

            INSERT INTO expert(expert_id, address_id)  -- insert into expert table
            VALUES (currval('person_person_id_seq'), currval('address_address_id_seq'));  -- the same incrementation of the serial in person_id using the currval function

            FOREACH t IN ARRAY v_themes  -- iterate over the array of passed themes
                LOOP
                    INSERT INTO expert_categorization(expert_id, theme_code) -- insert into expert categorization
                    VALUES (currval('person_person_id_seq'), t);  -- the current value of the person_id that expert inherits, and the next theme code
                END LOOP;
        END;  -- end function
    $proc$ LANGUAGE plpgsql;  -- end code block and identify as plpgsql



-- Stored Procedure for Adding Data to Program Entity with Themes ---------------------------------
CREATE OR REPLACE FUNCTION add_program_func(
    program_id IN DECIMAL, program_name IN VARCHAR, start_date IN DATE, end_date IN DATE, budget IN DECIMAL,
    manager_id IN INTEGER, themes IN VARCHAR, countries IN VARCHAR  -- create parameterized procedure with arguments to pass
) RETURNS VOID  -- part of plpgsql syntax
AS  -- plpgsql syntax
    $proc$  -- start procedure block
        DECLARE  -- declare variables
            v_themes VARCHAR[] := string_to_array(themes, ',');  -- declare an array to parse theme codes
            t VARCHAR;  -- counting variable token

            v_countries VARCHAR[] := string_to_array(countries, ',');  -- declare array var to hold parsed country codes
            c VARCHAR;  -- counting variable token

        BEGIN  -- begin procedure block
            INSERT INTO program(program_id, program_name, start_date, end_date, budget, manager_id)  -- insert into program's attributes
            VALUES (program_id, program_name, CAST(start_date AS DATE), CAST(end_date AS DATE), budget, manager_id);  -- the following params from procedure call

            FOREACH t IN ARRAY v_themes  -- iterate over the theme code array
                LOOP
                    INSERT INTO program_categorization(program_id, theme_code)  -- insert into the program categorization bridge table
                    VALUES (program_id, t);  -- the program ID in proc call, and the next up theme code in the array
                END LOOP;

            FOREACH c IN ARRAY v_countries  -- iterate over countries array
                LOOP
                    INSERT INTO program_location(program_id, country_code)  -- insert into program location bridge table
                    VALUES (program_id, c);  -- the program id in proc call, and the next country code
                END LOOP;
        END;  -- end procedure code
    $proc$ LANGUAGE plpgsql;  -- close code block and identify code language

-- STORED Procedure to Add a Volunteer Engagement -----------------------------------------------
CREATE OR REPLACE FUNCTION add_vol_engagement_func(
    expert_id IN INTEGER, program_ids IN VARCHAR, country_codes IN VARCHAR, s_date IN DATE, e_date IN DATE,
    rating IN DECIMAL, summary IN TEXT, in_kind_rate IN DECIMAL, work_days IN DECIMAL
 ) RETURNS VOID
AS
    $proc$
        DECLARE
            v_programs VARCHAR[] := string_to_array(program_ids, ',');
            p VARCHAR;

            v_countries VARCHAR[] := string_to_array(country_codes, ',');
            c VARCHAR;

        BEGIN
            INSERT INTO engagement (engagement_id, expert_id, start_date, end_date,
                                    performance_rating, engagement_summary, is_paid, is_volunteer)
            VALUES (DEFAULT, expert_id, s_date, e_date, rating, summary, FALSE, TRUE);

            INSERT INTO vol_engagement(engagement_id, in_kind_rate, work_days)
            VALUES (currval('engagement_engagement_id_seq'), in_kind_rate, work_days);

            FOREACH p IN ARRAY v_programs
                LOOP
                    INSERT INTO engagement_program (engagement_id, program_id)
                    VALUES (currval('engagement_engagement_id_seq'), CAST(p AS DECIMAL));
                END LOOP;

            FOREACH c IN ARRAY v_countries
                LOOP
                   INSERT INTO engagement_location (engagement_id, country_code)
                   VALUES (currval('engagement_engagement_id_seq'), c);
                END LOOP;
        END;
    $proc$ LANGUAGE plpgsql;


-- Stored Procedure to create paid engagement -------------------------------------------------
CREATE OR REPLACE FUNCTION add_paid_engagement_func(
    expert_id IN INTEGER, program_ids IN VARCHAR, country_codes IN VARCHAR, s_date IN DATE, e_date IN DATE,
    rating IN DECIMAL, summary IN TEXT,
    fee_rate IN DECIMAL, fee_type IN VARCHAR, work_time IN DECIMAL  -- create parameterized function with passed arguments
 ) RETURNS VOID  -- plpgsql syntax
AS
    $proc$  -- begin procedure block
        DECLARE  -- declare variables
            v_programs VARCHAR[] := string_to_array(program_ids, ',');  -- declare an array to parse program ids
            p VARCHAR;  -- counting token var

            v_countries VARCHAR[] := string_to_array(country_codes, ',');  -- declare an array to parse country codes
            c VARCHAR;  -- counting token var

        BEGIN  -- begin procedure code
            INSERT INTO engagement (engagement_id, expert_id, start_date, end_date,  -- insert in the following attributes of engagement
                                    performance_rating, engagement_summary, is_paid, is_volunteer)
            VALUES (DEFAULT, expert_id, s_date, e_date, rating, summary, TRUE, FALSE);  -- the next serial, the passed arguments, and TRUE to paid and FALSE to volunteer (subtype discriminators)

            INSERT INTO paid_engagement (engagement_id, fee_rate, fee_type, work_time)  -- insert into paid_engagement subtype table attributes:
            VALUES (currval('engagement_engagement_id_seq'), fee_rate, fee_type, work_time);  -- the currently iterated value of engagement id via currval(), and passed params from proc call

            FOREACH p IN ARRAY v_programs  -- iterate over program ids array
                LOOP
                    INSERT INTO engagement_program (engagement_id, program_id)  -- in this bridge table's attributes:
                    VALUES (currval('engagement_engagement_id_seq'), CAST(p AS DECIMAL));  -- insert the current engagement id serial, and insert current program id from array as decimal
                END LOOP;

            FOREACH c IN ARRAY v_countries  -- iterate over countries
                LOOP
                   INSERT INTO engagement_location (engagement_id, country_code)  -- in this bridge table's attributes:
                   VALUES (currval('engagement_engagement_id_seq'), c);  -- insert the current engagement id serial via currval(), then the current iteration of country code from array var
                END LOOP;
        END;
    $proc$ LANGUAGE plpgsql;  -- close procedure block and identify language

-- FUNCTION FOR PROGRAM MANAGER CHANGES HISTORY TABLE --------------------------------------
CREATE OR REPLACE FUNCTION program_manager_changes_func()  -- create a function to be run when the trigger is activated
RETURNS TRIGGER LANGUAGE plpgsql  -- establish that it runs whenever the trigger fires and that it is plpgsql language
AS $$  -- syntax for starting the code block
    BEGIN
        IF OLD.manager_id <> NEW.manager_id THEN  -- condition for function making entry after it is triggered (it triggers before every update to table)
            INSERT INTO program_manager_change_history (program_id, old_manager_id, new_manager_id, change_date)  -- insert into history table's attributes:
            VALUES(OLD.program_id, OLD.manager_id, NEW.manager_id, CURRENT_DATE);  -- the program ID, the OLD manager ID, the NEW manager ID and the timestamp
        END IF;
        RETURN NEW;  -- following three lines end the function definition
    END;
$$;


CREATE TRIGGER item_history_trg  -- this creates the trigger that activates under a given condition:
BEFORE UPDATE ON program  -- condition: every time (actually right before commit) of an update on program table
FOR EACH ROW  -- runs for each row updated
EXECUTE PROCEDURE program_manager_changes_func();  -- then execute the above function (remember there's logic in the func as to whether it does anything)





