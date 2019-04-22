-- CREATE DATABASE ROLI_Experts_Clearinghouse;

DROP TABLE
    person,
    program_categorization,
    expert_categorization,
    program_engagement,
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
    country
CASCADE;


-- Table Creation -------------------------------------------

CREATE TABLE person (
    person_id       DECIMAL(9) PRIMARY KEY,
    first_name      VARCHAR(255) NOT NULL,
    last_name       VARCHAR(255) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    phone           DECIMAL(16) NOT NULL,
    first_entered   DATE NOT NULL,
    last_updated    DATE NOT NULL,
    is_employee     BOOLEAN,
    is_expert       BOOLEAN
);

CREATE TABLE employee (
    employee_id         DECIMAL(9) PRIMARY KEY,
    hire_date           DATE NOT NULL,
    termination_date    DATE NULL,
    FOREIGN KEY (employee_id) REFERENCES person(person_id)
);

CREATE TABLE program (
    program_id      DECIMAL(7) PRIMARY KEY,
    program_name    VARCHAR(255) NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    manager_id      DECIMAL(9),
    FOREIGN KEY (manager_id) REFERENCES employee(employee_id)
);

CREATE TABLE focal_theme (
    theme_code      VARCHAR(3) PRIMARY KEY,
    theme_name      VARCHAR(255) NOT NULL,
    theme_active    BOOLEAN NOT NULL
);

CREATE TABLE expert (
    expert_id       DECIMAL(6) PRIMARY KEY,
    first_name      VARCHAR(255) NOT NULL,
    last_name       VARCHAR(255) NOT NULL,
    street_num      VARCHAR(255),
    street_name     VARCHAR(255),
    city            VARCHAR(64),
    subnational_div VARCHAR(64),
    address_country VARCHAR(64),
    postal_code     VARCHAR(16),
    email           VARCHAR(255) NOT NULL,
    phone           DECIMAL(16),
    resume_text     TEXT,
    num_engagements DECIMAL(4),  -- to be procedurally populated
    average_rating  DECIMAL(2,1), -- to be procedurally populated
    is_aba_member   BOOLEAN
);

CREATE TABLE aba_member (
    expert_id       DECIMAL(6) NOT NULL,
    aba_member_id   DECIMAL(9) NOT NULL,
    FOREIGN KEY (expert_id) REFERENCES expert(expert_id)
);


CREATE TABLE engagement (
    engagement_id       DECIMAL(8) PRIMARY KEY,
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    engagement_summary  TEXT,
    performance_rating  DECIMAL(1),
    is_paid             BOOLEAN NOT NULL,
    is_volunteer        BOOLEAN NOT NULL
);

CREATE TABLE paid_engagement (
    engagement_id       DECIMAL(8) NOT NULL,
    fee_rate            DECIMAL(9,2) NOT NULL,
    fee_type            VARCHAR(8) CHECK (fee_type IN ('Daily', 'Hourly', 'Lump sum')) NOT NULL,
    work_time           DECIMAL(4),
    FOREIGN KEY (engagement_id) REFERENCES engagement(engagement_id)
);

CREATE TABLE vol_engagement (
    engagement_id       DECIMAL(8) NOT NULL,
    in_kind_rate        DECIMAL(6,2),
    work_days           DECIMAL(4)
);

CREATE TABLE country (
    country_code        CHAR(2) PRIMARY KEY,
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
    expert_id   DECIMAL(6) NOT NULL,
    FOREIGN KEY (theme_code) REFERENCES focal_theme(theme_code),
    FOREIGN KEY (expert_id) REFERENCES expert(expert_id)
);

CREATE TABLE program_engagement (
    program_id      DECIMAL(7) NOT NULL,
    engagement_id   DECIMAL(8) NOT NULL,
    FOREIGN KEY (program_id) REFERENCES program(program_id),
    FOREIGN KEY (engagement_id) REFERENCES engagement(engagement_id)
);

CREATE TABLE engagement_location (
    engagement_id   DECIMAL(8) NOT NULL,
    country_code    CHAR(2) NOT NULL,
    FOREIGN KEY (engagement_id) REFERENCES engagement(engagement_id),
    FOREIGN KEY (country_code) REFERENCES country(country_code)
);

CREATE TABLE program_location (
    program_id      DECIMAL(7) NOT NULL,
    country_code    CHAR(2) NOT NULL,
    FOREIGN KEY (program_id) REFERENCES program(program_id),
    FOREIGN KEY (country_code) REFERENCES country(country_code)
);



-- Indexes ---------------------------------------------------
CREATE INDEX        program_pm_id_fk                        ON program(pm_id);
CREATE INDEX        program_categorization_theme_code_fk    ON program_categorization(theme_code);
CREATE INDEX        program_categorization_program_id_fk    ON program_categorization(program_id);
CREATE INDEX        expert_categorization_theme_code_fk     ON expert_categorization(theme_code);
CREATE INDEX        expert_categorization_expert_id_fk      ON expert_categorization(expert_id);
CREATE UNIQUE INDEX aba_member_expert_id_fk                 ON aba_member(expert_id);
CREATE UNIQUE INDEX paid_engagement_engagement_id_fk        ON paid_engagement(engagement_id);
CREATE UNIQUE INDEX vol_engagement_engagement_id_fk         ON vol_engagement(engagement_id);
CREATE INDEX        engagement_location_engagement_id_fk    ON engagement_location(engagement_id);
CREATE INDEX        engagement_location_country_code_fk     ON engagement_location(country_code);
CREATE INDEX        program_location_program_id_fk          ON program_location(program_id);
CREATE INDEX        program_location_country_code_fk        ON program_location(country_code);
CREATE INDEX        program_engagement_program_id_fk        ON program_engagement(program_id);
CREATE INDEX        program_engagement_engagement_id        ON program_engagement(engagement_id);
CREATE INDEX        focal_theme_theme_active_idx            ON focal_theme(theme_active);
CREATE UNIQUE INDEX aba_member_aba_member_id_idx            ON aba_member(aba_member_id);
CREATE INDEX        expert_average_rating_idx               ON expert(average_rating);
CREATE INDEX        expert_email_idx                        ON expert(email);