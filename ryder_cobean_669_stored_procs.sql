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
CREATE OR REPLACE FUNCTION add_program_func(
    program_id IN DECIMAL, program_name IN VARCHAR, start_date IN DATE, end_date IN DATE, manager_id IN INTEGER,
    themes IN VARCHAR, countries IN VARCHAR
) RETURNS VOID
AS
    $proc$
        DECLARE
            v_themes VARCHAR[] := string_to_array(themes, ',');
            t VARCHAR;

            v_countries VARCHAR[] := string_to_array(countries, ',');
            c VARCHAR;

        BEGIN
            INSERT INTO program(program_id, program_name, start_date, end_date, manager_id)
            VALUES (program_id, program_name, CAST(start_date AS DATE), CAST(end_date AS DATE), manager_id);

            FOREACH t IN ARRAY v_themes
                LOOP
                    INSERT INTO program_categorization(program_id, theme_code)
                    VALUES (program_id, t);
                END LOOP;

            FOREACH c IN ARRAY v_countries
                LOOP
                    INSERT INTO program_location(program_id, country_code)
                    VALUES (program_id, c);
                END LOOP;
        END;
    $proc$ LANGUAGE plpgsql;

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
    rating IN DECIMAL, summary IN TEXT, fee_rate in DECIMAL, fee_type IN VARCHAR, work_time IN DECIMAL
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
            VALUES (DEFAULT, expert_id, s_date, e_date, rating, summary, TRUE, FALSE);

            INSERT INTO paid_engagement (engagement_id, fee_rate, fee_type, work_time)
            VALUES (currval('engagement_engagement_id_seq'), fee_rate, fee_type, work_time);

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













