-- CREATE DATABASE ROLI_Experts_Clearinghouse;  -- create the DB -- commented out

-- Table Dropping Commands ----------------------------------
DROP TABLE
    person,
    program_categorization,
    expert_categorization,
    engagement_program,
    engagement_location,
    program_location,
    employee,
    program,
    focal_theme,
    expert,
    aba_member,
    engagement,
    paid_engagement,
    vol_engagement,
    country,
    address,
    program_manager_change_history
CASCADE;

-- Table Creation -------------------------------------------
CREATE TABLE person (
    person_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(255) NOT NULL,
    last_name       VARCHAR(255) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    phone           DECIMAL(16) NOT NULL,
    first_entered   DATE NOT NULL,
    is_employee     BOOLEAN,
    is_expert       BOOLEAN
);

CREATE TABLE address(
    address_id      SERIAL PRIMARY KEY,
    street_num      VARCHAR(16) NOT NULL,
    street_name     VARCHAR(255) NOT NULL,
    city            VARCHAR(64) NOT NULL,
    subnational_div VARCHAR(64),
    address_country VARCHAR(64) NOT NULL,
    postal_code     VARCHAR(16) NOT NULL
);

CREATE TABLE employee (
    employee_id         INTEGER PRIMARY KEY,
    hire_date           DATE NOT NULL,
    termination_date    DATE,
    FOREIGN KEY (employee_id) REFERENCES person(person_id)
);

CREATE TABLE program (
    program_id      DECIMAL(7) PRIMARY KEY,
    program_name    VARCHAR(255) NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    manager_id      INTEGER,
    FOREIGN KEY (manager_id) REFERENCES employee(employee_id)
);

CREATE TABLE focal_theme (
    theme_code      VARCHAR(3) PRIMARY KEY,
    theme_name      VARCHAR(64) NOT NULL,
    theme_active    BOOLEAN NOT NULL
);

CREATE TABLE expert (
    expert_id       INTEGER PRIMARY KEY,
    address_id      INTEGER NOT NULL,
    resume_text     TEXT,
    is_aba_member   BOOLEAN,
    FOREIGN KEY (expert_id) REFERENCES person(person_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE aba_member (
    expert_id       INTEGER NOT NULL,
    aba_member_id   DECIMAL(9) UNIQUE NOT NULL,
    FOREIGN KEY (expert_id) REFERENCES expert(expert_id)
);


CREATE TABLE engagement (
    engagement_id       SERIAL PRIMARY KEY,
    expert_id           INTEGER NOT NULL,
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    engagement_summary  TEXT,
    performance_rating  DECIMAL(1),
    is_paid             BOOLEAN NOT NULL,
    is_volunteer        BOOLEAN NOT NULL,
    FOREIGN KEY (expert_id) REFERENCES expert(expert_id)
);

CREATE TABLE paid_engagement (
    engagement_id       INTEGER PRIMARY KEY,
--     fee_rate            DECIMAL(9,2) NOT NULL,
--     fee_type            VARCHAR(8) CHECK (fee_type IN ('Daily', 'Hourly', 'Lump sum')) NOT NULL,
--     work_time           DECIMAL(4),
    daily_rate          DECIMAL(9,2) NOT NULL,
    work_days           DECIMAL(4) NOT NULL,
    FOREIGN KEY (engagement_id) REFERENCES engagement(engagement_id)
);

CREATE TABLE vol_engagement (
    engagement_id       INTEGER PRIMARY KEY,
    in_kind_rate        DECIMAL(6,2),
    work_days           DECIMAL(4),
    FOREIGN KEY (engagement_id) REFERENCES engagement(engagement_id)
);

CREATE TABLE country (
    country_code        CHAR(3) PRIMARY KEY,
    country_name_iso    VARCHAR(64),
    country_name_usg    VARCHAR(64),
    country_name_short  VARCHAR(64),
    country_name_ext    VARCHAR(64)
);

CREATE TABLE program_categorization (
    theme_code  VARCHAR(3) NOT NULL,
    program_id  DECIMAL(7) NOT NULL,
    FOREIGN KEY (theme_code) REFERENCES focal_theme(theme_code),
    FOREIGN KEY (program_id) REFERENCES program(program_id)
);

CREATE TABLE expert_categorization (
    theme_code  VARCHAR(3) NOT NULL,
    expert_id   INTEGER NOT NULL,
    FOREIGN KEY (theme_code) REFERENCES focal_theme(theme_code),
    FOREIGN KEY (expert_id) REFERENCES expert(expert_id)
);

CREATE TABLE engagement_program (
    program_id      DECIMAL(7) NOT NULL,
    engagement_id   INTEGER NOT NULL,
    FOREIGN KEY (program_id) REFERENCES program(program_id),
    FOREIGN KEY (engagement_id) REFERENCES engagement(engagement_id)
);

CREATE TABLE engagement_location (
    engagement_id   INTEGER NOT NULL,
    country_code    CHAR(3) NOT NULL,
    FOREIGN KEY (engagement_id) REFERENCES engagement(engagement_id),
    FOREIGN KEY (country_code) REFERENCES country(country_code)
);

CREATE TABLE program_location (
    program_id      DECIMAL(7) NOT NULL,
    country_code    CHAR(3) NOT NULL,
    FOREIGN KEY (program_id) REFERENCES program(program_id),
    FOREIGN KEY (country_code) REFERENCES country(country_code)
);



-- Indexes for Foreign Keys -----------------------------------------------------------------
CREATE INDEX        engagement_expert_id_fkey                       ON engagement(expert_id);
CREATE INDEX        program_manager_id_fkey                         ON program(manager_id);
CREATE INDEX        program_categorization_theme_code_fkey          ON program_categorization(theme_code);
CREATE INDEX        program_categorization_program_id_fkey          ON program_categorization(program_id);
CREATE INDEX        expert_categorization_theme_code_fkey           ON expert_categorization(theme_code);
CREATE INDEX        expert_categorization_expert_id_fkey            ON expert_categorization(expert_id);
CREATE UNIQUE INDEX aba_member_expert_id_fkey                       ON aba_member(expert_id);
CREATE UNIQUE INDEX paid_engagement_engagement_id_fkey              ON paid_engagement(engagement_id);
CREATE UNIQUE INDEX vol_engagement_engagement_id_fkey               ON vol_engagement(engagement_id);
CREATE INDEX        engagement_location_engagement_id_fkey          ON engagement_location(engagement_id);
CREATE INDEX        engagement_location_country_code_fkey           ON engagement_location(country_code);
CREATE INDEX        program_location_program_id_fkey                ON program_location(program_id);
CREATE INDEX        program_location_country_code_fkey              ON program_location(country_code);
CREATE INDEX        engagement_program_program_id_fkey              ON engagement_program(program_id);
CREATE INDEX        engagement_engagement_program_id_fkey           ON engagement_program(engagement_id);
CREATE INDEX        expert_address_id_fkey                          ON expert(address_id);
CREATE UNIQUE INDEX expert_expert_id_fkey                           ON expert(expert_id);
CREATE UNIQUE INDEX employee_employee_id_fkey                       ON employee(employee_id);
CREATE INDEX        program_manager_change_history_program_id_fkey  ON program_manager_change_history(program_id);

-- Indexes for Common Queries ---------------------------------------------------------------
CREATE INDEX        focal_theme_theme_active_idx            ON focal_theme(theme_active);
CREATE UNIQUE INDEX aba_member_aba_member_id_idx            ON aba_member(aba_member_id);
CREATE INDEX        engagement_rating_idx                   ON engagement(performance_rating);
CREATE INDEX        person_email_idx                        ON person(email);

