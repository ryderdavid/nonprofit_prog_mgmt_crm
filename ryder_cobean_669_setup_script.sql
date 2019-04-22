-- CREATE DATABASE ROLI_Experts_Clearinghouse;  -- create the DB -- commented out

-- Table Dropping Commands ----------------------------------
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
    country,
    address
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
    num_engagements DECIMAL(4),  -- to be procedurally populated
    average_rating  DECIMAL(2,1), -- to be procedurally populated
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
    fee_rate            DECIMAL(9,2) NOT NULL,
    fee_type            VARCHAR(8) CHECK (fee_type IN ('Daily', 'Hourly', 'Lump sum')) NOT NULL,
    work_time           DECIMAL(4),
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

CREATE TABLE program_engagement (
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
CREATE UNIQUE INDEX engagement_expert_id_fkey               ON engagement(expert_id);
CREATE INDEX        program_manager_id_fkey                 ON program(manager_id);
CREATE INDEX        program_categorization_theme_code_fkey  ON program_categorization(theme_code);
CREATE INDEX        program_categorization_program_id_fkey  ON program_categorization(program_id);
CREATE INDEX        expert_categorization_theme_code_fkey   ON expert_categorization(theme_code);
CREATE INDEX        expert_categorization_expert_id_fkey    ON expert_categorization(expert_id);
CREATE UNIQUE INDEX aba_member_expert_id_fkey               ON aba_member(expert_id);
CREATE UNIQUE INDEX paid_engagement_engagement_id_fkey      ON paid_engagement(engagement_id);
CREATE UNIQUE INDEX vol_engagement_engagement_id_fkey       ON vol_engagement(engagement_id);
CREATE INDEX        engagement_location_engagement_id_fkey  ON engagement_location(engagement_id);
CREATE INDEX        engagement_location_country_code_fkey   ON engagement_location(country_code);
CREATE INDEX        program_location_program_id_fkey        ON program_location(program_id);
CREATE INDEX        program_location_country_code_fkey      ON program_location(country_code);
CREATE INDEX        program_engagement_program_id_fkey      ON program_engagement(program_id);
CREATE INDEX        program_engagement_engagement_id_fkey   ON program_engagement(engagement_id);
CREATE INDEX        expert_address_id_fkey                  ON expert(address_id);
CREATE UNIQUE INDEX expert_expert_id_fkey                   ON expert(expert_id);
CREATE UNIQUE INDEX employee_employee_id_fkey               ON employee(employee_id);

-- Indexes for Common Queries ---------------------------------------------------------------
CREATE INDEX        focal_theme_theme_active_idx            ON focal_theme(theme_active);
CREATE UNIQUE INDEX aba_member_aba_member_id_idx            ON aba_member(aba_member_id);
CREATE INDEX        expert_average_rating_idx               ON expert(average_rating);
CREATE INDEX        person_email_idx                        ON person(email);


-- Populate the Focus Themes with Current Themes -------------------------------------------
INSERT INTO focal_theme (theme_code, theme_name, theme_active)
VALUES      ('A2J', 'Access to Justice', TRUE),
            ('HE', 'Health & Environment', TRUE),
            ('HR', 'Human Rights', TRUE),
            ('AC', 'Anti-Corruption', TRUE),
            ('COM', 'Commercial Law Reform', TRUE),
            ('CJ', 'Criminal Justice', TRUE),
            ('JSS', 'Justice Sector Strengthening', TRUE),
            ('LED', 'Legal Education Reform', TRUE),
            ('LP', 'Legal Profession', TRUE),
            ('TIP', 'Trafficking in Persons', TRUE),
            ('GEN', 'Gender', TRUE),
            ('GOV', 'Governance', TRUE);


-- Populate the Countries ------------------------------------------------------------------
INSERT INTO country (country_code, country_name_iso, country_name_usg, country_name_short, country_name_ext)
VALUES
('ABW', 'Aruba', 'ARUBA', 'ARUBA', 'ARUBA'),
('AFG', 'Afghanistan', 'AFGHANISTAN', 'AFGHANISTAN', 'AFGHANISTAN'),
('AGO', 'Angola', 'ANGOLA', 'ANGOLA', 'ANGOLA'),
('AIA', 'Anguilla', 'ANGUILLA', 'ANGUILLA', 'ANGUILLA'),
('ALB', 'Albania', 'ALBANIA', 'ALBANIA', 'ALBANIA'),
('AND', 'Andorra', 'ANDORRA', 'ANDORRA', 'ANDORRA'),
('ARE', 'United Arab Emirates (the)', 'UNITED ARAB EMIRATES', 'UNITED ARAB EMIRATES', 'UNITED ARAB EMIRATES'),
('ARG', 'Argentina', 'ARGENTINA', 'ARGENTINA', 'ARGENTINA'),
('ARM', 'Armenia', 'ARMENIA', 'ARMENIA', 'ARMENIA'),
('ASM', 'American Samoa', 'AMERICAN SAMOA', 'AMERICAN SAMOA', 'AMERICAN SAMOA'),
('ATA', 'Antarctica', 'ANTARCTICA', 'ANTARCTICA', 'ANTARCTICA'),
('ATF', 'French Southern Territories (the)', 'FRENCH SOUTHERN AND ANTARCTIC LANDS', 'FRENCH SOUTHERN AND ANTARCTIC LANDS', 'FRENCH SOUTHERN AND ANTARCTIC LANDS'),
('ATG', 'Antigua and Barbuda', 'ANTIGUA AND BARBUDA', 'ANTIGUA AND BARBUDA', 'ANTIGUA AND BARBUDA'),
('AUS', 'Australia', 'AUSTRALIA', 'AUSTRALIA', 'AUSTRALIA'),
('AUT', 'Austria', 'AUSTRIA', 'AUSTRIA', 'AUSTRIA'),
('AZE', 'Azerbaijan', 'AZERBAIJAN', 'AZERBAIJAN', 'AZERBAIJAN'),
('BDI', 'Burundi', 'BURUNDI', 'BURUNDI', 'BURUNDI'),
('BEL', 'Belgium', 'BELGIUM', 'BELGIUM', 'BELGIUM'),
('BEN', 'Benin', 'BENIN', 'BENIN', 'BENIN'),
('BES', 'Bonaire, Sint Eustatius and Saba', 'BONAIRE, SINT EUSTATIUS, AND SABA', 'BONAIRE, SINT EUSTATIUS, AND SABA', 'BONAIRE, SINT EUSTATIUS, AND SABA'),
('BFA', 'Burkina Faso', 'BURKINA FASO', 'BURKINA FASO', 'BURKINA FASO'),
('BGD', 'Bangladesh', 'BANGLADESH', 'BANGLADESH', 'BANGLADESH'),
('BGR', 'Bulgaria', 'BULGARIA', 'BULGARIA', 'BULGARIA'),
('BHR', 'Bahrain', 'BAHRAIN', 'BAHRAIN', 'BAHRAIN'),
('BHS', 'Bahamas (the)', 'BAHAMAS, THE', 'BAHAMAS, THE', 'BAHAMAS, THE'),
('BIH', 'Bosnia and Herzegovina', 'BOSNIA AND HERZEGOVINA', 'BOSNIA AND HERZEGOVINA', 'BOSNIA AND HERZEGOVINA'),
('BLM', 'Saint Barthélemy', 'SAINT BARTHELEMY', 'SAINT BARTHELEMY', 'SAINT BARTHELEMY'),
('BLR', 'Belarus', 'BELARUS', 'BELARUS', 'BELARUS'),
('BLZ', 'Belize', 'BELIZE', 'BELIZE', 'BELIZE'),
('BMU', 'Bermuda', 'BERMUDA', 'BERMUDA', 'BERMUDA'),
('BOL', 'Bolivia (Plurinational State of)', 'BOLIVIA', 'BOLIVIA', 'BOLIVIA'),
('BRA', 'Brazil', 'BRAZIL', 'BRAZIL', 'BRAZIL'),
('BRB', 'Barbados', 'BARBADOS', 'BARBADOS', 'BARBADOS'),
('BRN', 'Brunei Darussalam', 'BRUNEI', 'BRUNEI', 'BRUNEI'),
('BTN', 'Bhutan', 'BHUTAN', 'BHUTAN', 'BHUTAN'),
('BVT', 'Bouvet Island', 'BOUVET ISLAND', 'BOUVET ISLAND', 'BOUVET ISLAND'),
('BWA', 'Botswana', 'BOTSWANA', 'BOTSWANA', 'BOTSWANA'),
('CAF', 'Central African Republic (the)', 'CENTRAL AFRICAN REPUBLIC', 'CENTRAL AFRICAN REPUBLIC', 'CENTRAL AFRICAN REPUBLIC'),
('CAN', 'Canada', 'CANADA', 'CANADA', 'CANADA'),
('CCK', 'Cocos (Keeling) Islands (the)', 'COCOS (KEELING) ISLANDS', 'COCOS (KEELING) ISLANDS', 'COCOS (KEELING) ISLANDS'),
('CHE', 'Switzerland', 'SWITZERLAND', 'SWITZERLAND', 'SWITZERLAND'),
('CHL', 'Chile', 'CHILE', 'CHILE', 'CHILE'),
('CHN', 'China', 'CHINA', 'CHINA', 'CHINA'),
('CIV', 'Côte d''Ivoire', 'CÔTE D’IVOIRE', 'CÔTE D’IVOIRE', 'CÔTE D’IVOIRE'),
('CMR', 'Cameroon', 'CAMEROON', 'CAMEROON', 'CAMEROON'),
('COD', 'Congo (the Democratic Republic of the)', 'CONGO (KINSHASA)', 'CONGO (KINSHASA)', 'CONGO (KINSHASA)'),
('COG', 'Congo (the)', 'CONGO (BRAZZAVILLE)', 'CONGO (BRAZZAVILLE)', 'CONGO (BRAZZAVILLE)'),
('COK', 'Cook Islands (the)', 'COOK ISLANDS', 'COOK ISLANDS', 'COOK ISLANDS'),
('COL', 'Colombia', 'COLOMBIA', 'COLOMBIA', 'COLOMBIA'),
('COM', 'Comoros (the)', 'COMOROS', 'COMOROS', 'COMOROS'),
('CPV', 'Cabo Verde', 'CABO VERDE', 'CABO VERDE', 'CABO VERDE'),
('CRI', 'Costa Rica', 'COSTA RICA', 'COSTA RICA', 'COSTA RICA'),
('CUB', 'Cuba', 'CUBA', 'CUBA', 'CUBA'),
('CUW', 'Curaçao', 'CURAÇAO', 'CURAÇAO', 'CURAÇAO'),
('CXR', 'Christmas Island', 'CHRISTMAS ISLAND', 'CHRISTMAS ISLAND', 'CHRISTMAS ISLAND'),
('CYM', 'Cayman Islands (the)', 'CAYMAN ISLANDS', 'CAYMAN ISLANDS', 'CAYMAN ISLANDS'),
('CYP', 'Cyprus', 'CYPRUS', 'CYPRUS', 'CYPRUS'),
('CZE', 'Czechia', 'CZECHIA', 'CZECHIA', 'CZECHIA'),
('DEU', 'Germany', 'GERMANY', 'GERMANY', 'GERMANY'),
('DJI', 'Djibouti', 'DJIBOUTI', 'DJIBOUTI', 'DJIBOUTI'),
('DMA', 'Dominica', 'DOMINICA', 'DOMINICA', 'DOMINICA'),
('DNK', 'Denmark', 'DENMARK', 'DENMARK', 'DENMARK'),
('DOM', 'Dominican Republic (the)', 'DOMINICAN REPUBLIC', 'DOMINICAN REPUBLIC', 'DOMINICAN REPUBLIC'),
('DZA', 'Algeria', 'ALGERIA', 'ALGERIA', 'ALGERIA'),
('ECU', 'Ecuador', 'ECUADOR', 'ECUADOR', 'ECUADOR'),
('EGY', 'Egypt', 'EGYPT', 'EGYPT', 'EGYPT'),
('ERI', 'Eritrea', 'ERITREA', 'ERITREA', 'ERITREA'),
('ESH', 'Western Sahara*', 'WESTERN SAHARA', 'WESTERN SAHARA', 'WESTERN SAHARA'),
('ESP', 'Spain', 'SPAIN', 'SPAIN', 'SPAIN'),
('EST', 'Estonia', 'ESTONIA', 'ESTONIA', 'ESTONIA'),
('ETH', 'Ethiopia', 'ETHIOPIA', 'ETHIOPIA', 'ETHIOPIA'),
('FIN', 'Finland', 'FINLAND', 'FINLAND', 'FINLAND'),
('FJI', 'Fiji', 'FIJI', 'FIJI', 'FIJI'),
('FLK', 'Falkland Islands (the) [Malvinas]', 'FALKLAND ISLANDS (ISLAS MALVINAS)', 'FALKLAND ISLANDS (ISLAS MALVINAS)', 'FALKLAND ISLANDS (ISLAS MALVINAS)'),
('FRA', 'France', 'FRANCE', 'FRANCE', 'FRANCE'),
('FRO', 'Faroe Islands (the)', 'FAROE ISLANDS', 'FAROE ISLANDS', 'FAROE ISLANDS'),
('GAB', 'Gabon', 'GABON', 'GABON', 'GABON'),
('GBR', 'United Kingdom of Great Britain and Northern Ireland (the)', 'UNITED KINGDOM', 'UNITED KINGDOM', 'UNITED KINGDOM'),
('GEO', 'Georgia', 'GEORGIA', 'GEORGIA', 'GEORGIA'),
('GGY', 'Guernsey', 'GUERNSEY', 'GUERNSEY', 'GUERNSEY'),
('GHA', 'Ghana', 'GHANA', 'GHANA', 'GHANA'),
('GIB', 'Gibraltar', 'GIBRALTAR', 'GIBRALTAR', 'GIBRALTAR'),
('GIN', 'Guinea', 'GUINEA', 'GUINEA', 'GUINEA'),
('GLP', 'Guadeloupe', 'GUADELOUPE', 'GUADELOUPE', 'GUADELOUPE'),
('GMB', 'Gambia (the)', 'GAMBIA, THE', 'GAMBIA, THE', 'GAMBIA, THE'),
('GNB', 'Guinea-Bissau', 'GUINEA-BISSAU', 'GUINEA-BISSAU', 'GUINEA-BISSAU'),
('GNQ', 'Equatorial Guinea', 'EQUATORIAL GUINEA', 'EQUATORIAL GUINEA', 'EQUATORIAL GUINEA'),
('GRC', 'Greece', 'GREECE', 'GREECE', 'GREECE'),
('GRD', 'Grenada', 'GRENADA', 'GRENADA', 'GRENADA'),
('GRL', 'Greenland', 'GREENLAND', 'GREENLAND', 'GREENLAND'),
('GTM', 'Guatemala', 'GUATEMALA', 'GUATEMALA', 'GUATEMALA'),
('GUF', 'French Guiana', 'FRENCH GUIANA', 'FRENCH GUIANA', 'FRENCH GUIANA'),
('GUM', 'Guam', 'GUAM', 'GUAM', 'GUAM'),
('GUY', 'Guyana', 'GUYANA', 'GUYANA', 'GUYANA'),
('HKG', 'Hong Kong', 'HONG KONG', 'HONG KONG', 'HONG KONG'),
('HMD', 'Heard Island and McDonald Islands', 'HEARD ISLAND AND MCDONALD ISLANDS', 'HEARD ISLAND AND MCDONALD ISLANDS', 'HEARD ISLAND AND MCDONALD ISLANDS'),
('HND', 'Honduras', 'HONDURAS', 'HONDURAS', 'HONDURAS'),
('HRV', 'Croatia', 'CROATIA', 'CROATIA', 'CROATIA'),
('HTI', 'Haiti', 'HAITI', 'HAITI', 'HAITI'),
('HUN', 'Hungary', 'HUNGARY', 'HUNGARY', 'HUNGARY'),
('IDN', 'Indonesia', 'INDONESIA', 'INDONESIA', 'INDONESIA'),
('IMN', 'Isle of Man', 'ISLE OF MAN', 'ISLE OF MAN', 'ISLE OF MAN'),
('IND', 'India', 'INDIA', 'INDIA', 'INDIA'),
('IOT', 'British Indian Ocean Territory (the)', 'BRITISH INDIAN OCEAN TERRITORY', 'BRITISH INDIAN OCEAN TERRITORY', 'BRITISH INDIAN OCEAN TERRITORY'),
('IRL', 'Ireland', 'IRELAND', 'IRELAND', 'IRELAND'),
('IRN', 'Iran (Islamic Republic of)', 'IRAN', 'IRAN', 'IRAN'),
('IRQ', 'Iraq', 'IRAQ', 'IRAQ', 'IRAQ'),
('ISL', 'Iceland', 'ICELAND', 'ICELAND', 'ICELAND'),
('ISR', 'Israel', 'ISRAEL', 'ISRAEL', 'ISRAEL'),
('ITA', 'Italy', 'ITALY', 'ITALY', 'ITALY'),
('JAM', 'Jamaica', 'JAMAICA', 'JAMAICA', 'JAMAICA'),
('JEY', 'Jersey', 'JERSEY', 'JERSEY', 'JERSEY'),
('JOR', 'Jordan', 'JORDAN', 'JORDAN', 'JORDAN'),
('JPN', 'Japan', 'JAPAN', 'JAPAN', 'JAPAN'),
('KAZ', 'Kazakhstan', 'KAZAKHSTAN', 'KAZAKHSTAN', 'KAZAKHSTAN'),
('KEN', 'Kenya', 'KENYA', 'KENYA', 'KENYA'),
('KGZ', 'Kyrgyzstan', 'KYRGYZSTAN', 'KYRGYZSTAN', 'KYRGYZSTAN'),
('KHM', 'Cambodia', 'CAMBODIA', 'CAMBODIA', 'CAMBODIA'),
('KIR', 'Kiribati', 'KIRIBATI', 'KIRIBATI', 'KIRIBATI'),
('KNA', 'Saint Kitts and Nevis', 'SAINT KITTS AND NEVIS', 'SAINT KITTS AND NEVIS', 'SAINT KITTS AND NEVIS'),
('KOR', 'Korea (the Republic of)', 'KOREA, SOUTH', 'KOREA, SOUTH', 'KOREA, SOUTH'),
('KWT', 'Kuwait', 'KUWAIT', 'KUWAIT', 'KUWAIT'),
('LAO', 'Lao People''s Democratic Republic (the)', 'LAOS', 'LAOS', 'LAOS'),
('LBN', 'Lebanon', 'LEBANON', 'LEBANON', 'LEBANON'),
('LBR', 'Liberia', 'LIBERIA', 'LIBERIA', 'LIBERIA'),
('LBY', 'Libya', 'LIBYA', 'LIBYA', 'LIBYA'),
('LCA', 'Saint Lucia', 'SAINT LUCIA', 'SAINT LUCIA', 'SAINT LUCIA'),
('LIE', 'Liechtenstein', 'LIECHTENSTEIN', 'LIECHTENSTEIN', 'LIECHTENSTEIN'),
('LKA', 'Sri Lanka', 'SRI LANKA', 'SRI LANKA', 'SRI LANKA'),
('LSO', 'Lesotho', 'LESOTHO', 'LESOTHO', 'LESOTHO'),
('LTU', 'Lithuania', 'LITHUANIA', 'LITHUANIA', 'LITHUANIA'),
('LUX', 'Luxembourg', 'LUXEMBOURG', 'LUXEMBOURG', 'LUXEMBOURG'),
('LVA', 'Latvia', 'LATVIA', 'LATVIA', 'LATVIA'),
('MAC', 'Macao', 'MACAU', 'MACAU', 'MACAU'),
('MAR', 'Morocco', 'MOROCCO', 'MOROCCO', 'MOROCCO'),
('MCO', 'Monaco', 'MONACO', 'MONACO', 'MONACO'),
('MDA', 'Moldova (the Republic of)', 'MOLDOVA', 'MOLDOVA', 'MOLDOVA'),
('MDG', 'Madagascar', 'MADAGASCAR', 'MADAGASCAR', 'MADAGASCAR'),
('MDV', 'Maldives', 'MALDIVES', 'MALDIVES', 'MALDIVES'),
('MEX', 'Mexico', 'MEXICO', 'MEXICO', 'MEXICO'),
('MHL', 'Marshall Islands (the)', 'MARSHALL ISLANDS', 'MARSHALL ISLANDS', 'MARSHALL ISLANDS'),
('MKD', 'Macedonia (the former Yugoslav Republic of)', 'MACEDONIA', 'MACEDONIA', 'MACEDONIA'),
('MLI', 'Mali', 'MALI', 'MALI', 'MALI'),
('MLT', 'Malta', 'MALTA', 'MALTA', 'MALTA'),
('MMR', 'Myanmar', 'BURMA', 'BURMA', 'BURMA'),
('MNE', 'Montenegro', 'MONTENEGRO', 'MONTENEGRO', 'MONTENEGRO'),
('MNG', 'Mongolia', 'MONGOLIA', 'MONGOLIA', 'MONGOLIA'),
('MNP', 'Northern Mariana Islands (the)', 'NORTHERN MARIANA ISLANDS', 'NORTHERN MARIANA ISLANDS', 'NORTHERN MARIANA ISLANDS'),
('MOZ', 'Mozambique', 'MOZAMBIQUE', 'MOZAMBIQUE', 'MOZAMBIQUE'),
('MRT', 'Mauritania', 'MAURITANIA', 'MAURITANIA', 'MAURITANIA'),
('MSR', 'Montserrat', 'MONTSERRAT', 'MONTSERRAT', 'MONTSERRAT'),
('MTQ', 'Martinique', 'MARTINIQUE', 'MARTINIQUE', 'MARTINIQUE'),
('MUS', 'Mauritius', 'MAURITIUS', 'MAURITIUS', 'MAURITIUS'),
('MWI', 'Malawi', 'MALAWI', 'MALAWI', 'MALAWI'),
('MYS', 'Malaysia', 'MALAYSIA', 'MALAYSIA', 'MALAYSIA'),
('MYT', 'Mayotte', 'MAYOTTE', 'MAYOTTE', 'MAYOTTE'),
('NAM', 'Namibia', 'NAMIBIA', 'NAMIBIA', 'NAMIBIA'),
('NCL', 'New Caledonia', 'NEW CALEDONIA', 'NEW CALEDONIA', 'NEW CALEDONIA'),
('NER', 'Niger (the)', 'NIGER', 'NIGER', 'NIGER'),
('NFK', 'Norfolk Island', 'NORFOLK ISLAND', 'NORFOLK ISLAND', 'NORFOLK ISLAND'),
('NGA', 'Nigeria', 'NIGERIA', 'NIGERIA', 'NIGERIA'),
('NIC', 'Nicaragua', 'NICARAGUA', 'NICARAGUA', 'NICARAGUA'),
('NIU', 'Niue', 'NIUE', 'NIUE', 'NIUE'),
('NLD', 'Netherlands (the)', 'NETHERLANDS', 'NETHERLANDS', 'NETHERLANDS'),
('NOR', 'Norway', 'NORWAY', 'NORWAY', 'NORWAY'),
('NPL', 'Nepal', 'NEPAL', 'NEPAL', 'NEPAL'),
('NRU', 'Nauru', 'NAURU', 'NAURU', 'NAURU'),
('NZL', 'New Zealand', 'NEW ZEALAND', 'NEW ZEALAND', 'NEW ZEALAND'),
('OMN', 'Oman', 'OMAN', 'OMAN', 'OMAN'),
('PAK', 'Pakistan', 'PAKISTAN', 'PAKISTAN', 'PAKISTAN'),
('PAN', 'Panama', 'PANAMA', 'PANAMA', 'PANAMA'),
('PCN', 'Pitcairn', 'PITCAIRN ISLANDS', 'PITCAIRN ISLANDS', 'PITCAIRN ISLANDS'),
('PER', 'Peru', 'PERU', 'PERU', 'PERU'),
('PHL', 'Philippines (the)', 'PHILIPPINES', 'PHILIPPINES', 'PHILIPPINES'),
('PLW', 'Palau', 'PALAU', 'PALAU', 'PALAU'),
('PNG', 'Papua New Guinea', 'PAPUA NEW GUINEA', 'PAPUA NEW GUINEA', 'PAPUA NEW GUINEA'),
('POL', 'Poland', 'POLAND', 'POLAND', 'POLAND'),
('PRI', 'Puerto Rico', 'PUERTO RICO', 'PUERTO RICO', 'PUERTO RICO'),
('PRK', 'Korea (the Democratic People''s Republic of)', 'NORTH KOREA', 'NORTH KOREA', 'NORTH KOREA'),
('PRT', 'Portugal', 'PORTUGAL', 'PORTUGAL', 'PORTUGAL'),
('PRY', 'Paraguay', 'PARAGUAY', 'PARAGUAY', 'PARAGUAY'),
('PSE', 'Palestine, State of', 'WEST BANK', 'WEST BANK', 'WEST BANK'),
('PYF', 'French Polynesia', 'FRENCH POLYNESIA', 'FRENCH POLYNESIA', 'FRENCH POLYNESIA'),
('QAT', 'Qatar', 'QATAR', 'QATAR', 'QATAR'),
('REU', 'Réunion', 'REUNION', 'REUNION', 'REUNION'),
('ROU', 'Romania', 'ROMANIA', 'ROMANIA', 'ROMANIA'),
('RUS', 'Russian Federation (the)', 'RUSSIA', 'RUSSIA', 'RUSSIA'),
('RWA', 'Rwanda', 'RWANDA', 'RWANDA', 'RWANDA'),
('SAU', 'Saudi Arabia', 'SAUDI ARABIA', 'SAUDI ARABIA', 'SAUDI ARABIA'),
('SDN', 'Sudan (the)', 'SUDAN', 'SUDAN', 'SUDAN'),
('SEN', 'Senegal', 'SENEGAL', 'SENEGAL', 'SENEGAL'),
('SGP', 'Singapore', 'SINGAPORE', 'SINGAPORE', 'SINGAPORE'),
('SGS', 'South Georgia and the South Sandwich Islands', 'SOUTH GEORGIA AND SOUTH SANDWICH ISLANDS', 'SOUTH GEORGIA AND SOUTH SANDWICH ISLANDS', 'SOUTH GEORGIA AND SOUTH SANDWICH ISLANDS'),
('SHN', 'Saint Helena, Ascension and Tristan da Cunha', 'SAINT HELENA, ASCENSION, AND TRISTAN DA CUNHA', 'SAINT HELENA, ASCENSION, AND TRISTAN DA CUNHA', 'SAINT HELENA, ASCENSION, AND TRISTAN DA CUNHA'),
('SJM', 'Svalbard and Jan Mayen', 'SVALBARD', 'SVALBARD', 'SVALBARD'),
('SLB', 'Solomon Islands', 'SOLOMON ISLANDS', 'SOLOMON ISLANDS', 'SOLOMON ISLANDS'),
('SLE', 'Sierra Leone', 'SIERRA LEONE', 'SIERRA LEONE', 'SIERRA LEONE'),
('SLV', 'El Salvador', 'EL SALVADOR', 'EL SALVADOR', 'EL SALVADOR'),
('SMR', 'San Marino', 'SAN MARINO', 'SAN MARINO', 'SAN MARINO'),
('SOM', 'Somalia', 'SOMALIA', 'SOMALIA', 'SOMALIA'),
('SPM', 'Saint Pierre and Miquelon', 'SAINT PIERRE AND MIQUELON', 'SAINT PIERRE AND MIQUELON', 'SAINT PIERRE AND MIQUELON'),
('SRB', 'Serbia', 'SERBIA', 'SERBIA', 'SERBIA'),
('SSD', 'South Sudan', 'SOUTH SUDAN', 'SOUTH SUDAN', 'SOUTH SUDAN'),
('STP', 'Sao Tome and Principe', 'SAO TOME AND PRINCIPE', 'SAO TOME AND PRINCIPE', 'SAO TOME AND PRINCIPE'),
('SUR', 'Suriname', 'SURINAME', 'SURINAME', 'SURINAME'),
('SVK', 'Slovakia', 'SLOVAKIA', 'SLOVAKIA', 'SLOVAKIA'),
('SVN', 'Slovenia', 'SLOVENIA', 'SLOVENIA', 'SLOVENIA'),
('SWE', 'Sweden', 'SWEDEN', 'SWEDEN', 'SWEDEN'),
('SWZ', 'Swaziland', 'SWAZILAND', 'SWAZILAND', 'SWAZILAND'),
('SXM', 'Sint Maarten (Dutch part)', 'SINT MAARTEN', 'SINT MAARTEN', 'SINT MAARTEN'),
('SYC', 'Seychelles', 'SEYCHELLES', 'SEYCHELLES', 'SEYCHELLES'),
('SYR', 'Syrian Arab Republic', 'SYRIA', 'SYRIA', 'SYRIA'),
('TCA', 'Turks and Caicos Islands (the)', 'TURKS AND CAICOS ISLANDS', 'TURKS AND CAICOS ISLANDS', 'TURKS AND CAICOS ISLANDS'),
('TCD', 'Chad', 'CHAD', 'CHAD', 'CHAD'),
('TGO', 'Togo', 'TOGO', 'TOGO', 'TOGO'),
('THA', 'Thailand', 'THAILAND', 'THAILAND', 'THAILAND'),
('TJK', 'Tajikistan', 'TAJIKISTAN', 'TAJIKISTAN', 'TAJIKISTAN'),
('TKL', 'Tokelau', 'TOKELAU', 'TOKELAU', 'TOKELAU'),
('TKM', 'Turkmenistan', 'TURKMENISTAN', 'TURKMENISTAN', 'TURKMENISTAN'),
('TLS', 'Timor-Leste', 'TIMOR-LESTE', 'TIMOR-LESTE', 'TIMOR-LESTE'),
('TON', 'Tonga', 'TONGA', 'TONGA', 'TONGA'),
('TTO', 'Trinidad and Tobago', 'TRINIDAD AND TOBAGO', 'TRINIDAD AND TOBAGO', 'TRINIDAD AND TOBAGO'),
('TUN', 'Tunisia', 'TUNISIA', 'TUNISIA', 'TUNISIA'),
('TUR', 'Turkey', 'TURKEY', 'TURKEY', 'TURKEY'),
('TUV', 'Tuvalu', 'TUVALU', 'TUVALU', 'TUVALU'),
('TWN', 'Taiwan (Province of China)', 'TAIWAN', 'TAIWAN', 'TAIWAN'),
('TZA', 'Tanzania, United Republic of', 'TANZANIA', 'TANZANIA', 'TANZANIA'),
('UGA', 'Uganda', 'UGANDA', 'UGANDA', 'UGANDA'),
('UKR', 'Ukraine', 'UKRAINE', 'UKRAINE', 'UKRAINE'),
('URY', 'Uruguay', 'URUGUAY', 'URUGUAY', 'URUGUAY'),
('USA', 'United States of America (the)', 'UNITED STATES', 'UNITED STATES', 'UNITED STATES'),
('UZB', 'Uzbekistan', 'UZBEKISTAN', 'UZBEKISTAN', 'UZBEKISTAN'),
('VCT', 'Saint Vincent and the Grenadines', 'SAINT VINCENT AND THE GRENADINES', 'SAINT VINCENT AND THE GRENADINES', 'SAINT VINCENT AND THE GRENADINES'),
('VEN', 'Venezuela (Bolivarian Republic of)', 'VENEZUELA', 'VENEZUELA', 'VENEZUELA'),
('VGB', 'Virgin Islands (British)', 'VIRGIN ISLANDS, BRITISH', 'VIRGIN ISLANDS, BRITISH', 'VIRGIN ISLANDS, BRITISH'),
('VIR', 'Virgin Islands (U.S.)', 'VIRGIN ISLANDS, U.S.', 'VIRGIN ISLANDS, U.S.', 'VIRGIN ISLANDS, U.S.'),
('VNM', 'Viet Nam', 'VIETNAM', 'VIETNAM', 'VIETNAM'),
('VUT', 'Vanuatu', 'VANUATU', 'VANUATU', 'VANUATU'),
('WLF', 'Wallis and Futuna', 'WALLIS AND FUTUNA', 'WALLIS AND FUTUNA', 'WALLIS AND FUTUNA'),
('WSM', 'Samoa', 'SAMOA', 'SAMOA', 'SAMOA'),
('XKX', 'Kosovo (the Republic of)', 'KOSOVO', 'KOSOVO', 'KOSOVO'),
('YEM', 'Yemen', 'YEMEN', 'YEMEN', 'YEMEN'),
('ZAF', 'South Africa', 'SOUTH AFRICA', 'SOUTH AFRICA', 'SOUTH AFRICA'),
('ZMB', 'Zambia', 'ZAMBIA', 'ZAMBIA', 'ZAMBIA'),
('ZWE', 'Zimbabwe', 'ZIMBABWE', 'ZIMBABWE', 'ZIMBABWE');


-- Insert a bunch of dummy employees --------------------------------------------------------
START TRANSACTION;
INSERT INTO person (person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
VALUES (DEFAULT, 'Nonnie', 'Diehard', 'nonnie@americanbar.org','12025550000', current_date, TRUE, FALSE);

INSERT INTO employee(employee_id, hire_date)
VALUES (currval('public.person_person_id_seq'), CAST('1-FEB-2016' AS DATE));

INSERT INTO person (person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
VALUES (DEFAULT, 'Annie', 'Hewes', 'annie@americanbar.org','12025558888', current_date, TRUE, FALSE);

INSERT INTO employee(employee_id, hire_date)
VALUES (currval('public.person_person_id_seq'), CAST('1-FEB-2011' AS DATE));

INSERT INTO person (person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
VALUES (DEFAULT, 'Ashton', 'Merle', 'ashton@americanbar.org','12025558999', current_date, TRUE, FALSE);

INSERT INTO employee(employee_id, hire_date)
VALUES (currval('public.person_person_id_seq'), CAST('1-Jan-2010' AS DATE));

INSERT INTO person (person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
VALUES (DEFAULT, 'Tom', 'Moller', 'tom@americanbar.org','12025557778', current_date, TRUE, FALSE);

INSERT INTO employee(employee_id, hire_date)
VALUES (currval('public.person_person_id_seq'), CAST('1-Mar-2013' AS DATE));

INSERT INTO person (person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
VALUES (DEFAULT, 'Mandy', 'Berners', 'mandy@americanbar.org','12025556668', current_date, TRUE, FALSE);

INSERT INTO employee(employee_id, hire_date)
VALUES (currval('public.person_person_id_seq'), CAST('1-Oct-2015' AS DATE));

INSERT INTO person (person_id, first_name, last_name, email, phone, first_entered, is_employee, is_expert)
VALUES (DEFAULT, 'Kevin', 'Kowbon', 'kevin@americanbar.org','12025555588', current_date, TRUE, FALSE);

INSERT INTO employee(employee_id, hire_date)
VALUES (currval('public.person_person_id_seq'), CAST('1-FEB-2014' AS DATE));

COMMIT TRANSACTION;