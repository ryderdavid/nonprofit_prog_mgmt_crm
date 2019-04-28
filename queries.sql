/*EXPERT OVERVIEW RECORDS:
  The query below pulls relevant records from expert, gets their names from person supertype,
  gets their focal themes from expert_categorization, then left joins this query on the counts
  of all engagements performed experts grouped by those experts and their average ratings.
  Useful query to see history of existing experts and their performance. Satisfies the following
  requirements in the spec:
  Group 1: Joins of two or more tables, order by statement
  Group 2: Aggregate functions, left join, subqueries*/
SELECT person_id, expert_name, focal_themes, num_engagements, avg_rating, email, phone, address
FROM
    (SELECT
        person_id,
        first_name || ' ' || last_name AS expert_name,
        email,
        string_agg(theme_code, ', ') AS focal_themes,
        phone,
        concat(street_num, ' ', street_name, ', ', city, ', ', (subnational_div || ', '),
            address_country, ', ', postal_code) AS address -- using concat allows statement to omit NULL values for state/prov/region
    FROM person
    JOIN expert ON person.person_id = expert.expert_id
    JOIN address ON expert.address_id = address.address_id
    JOIN expert_categorization ec ON expert.expert_id = ec.expert_id
    GROUP BY person_id, address) t1
LEFT JOIN
    (SELECT
        expert_id,
        count(DISTINCT (engagement_id)) AS num_engagements,
        round(avg(performance_rating), 2) AS avg_rating
    FROM engagement
    GROUP BY expert_id) t2
ON t1.person_id = t2.expert_id
ORDER BY avg_rating DESC NULLS LAST;



/*PROGRAMS OVERVIEW QUERY:
  A Query that pulls and aggregates all relevant information from the program table and its relevant relations
  (themes, countries, current manager) and left joins this table with records from our history table, such that
  this query presents a 'dashboard-level' master register of our grants, what they focus on, where they are implemented,
  and who manages them and who used to manage them. This query output actually very closely mimics a production spreadsheet
  our organization uses, except also tracks budgets of grants (that is an extension of my own I will build into the design later)
  This query meets the following requirements from the spec:
  Group 1: Order by statement
  Group 2: Joins of at least four tables, subqueries, left joins.*/
SELECT
progs.program_id, program_name, start_date, end_date, program_themes, program_countries, current_manager, past_managers
FROM
    (SELECT
       program.program_id,
       program_name,
       start_date,
       end_date,
       concat(first_name, ' ', last_name) AS current_manager,
       string_agg(DISTINCT(theme_code), ', ') AS program_themes, -- this seems to work casting this as distinct but don't know if there's a better way here
       string_agg(DISTINCT(country_code), ', ') AS program_countries -- i don't know if there is a better way than executing distinct here.
       FROM program
          JOIN employee e ON program.manager_id = e.employee_id
          JOIN person p ON e.employee_id = p.person_id
          JOIN program_categorization pc ON program.program_id = pc.program_id
          JOIN program_location pl ON program.program_id = pl.program_id
    GROUP BY (program.program_id, program_name, start_date, end_date, p.first_name, p.last_name)
    ORDER BY (start_date)) progs
LEFT JOIN
    (SELECT
        program.program_id,
        string_agg((first_name || ' ' || last_name), ', ') AS past_managers
    FROM program_manager_change_history
        JOIN person ON old_manager_id = person_id
        JOIN program ON program_manager_change_history.program_id = program.program_id
    GROUP BY program.program_id) hist
ON
    progs.program_id = hist.program_id;



/*LOW PERFORMING ENGAGEMENTS QUERY:
  This pulls relevant info from the engagements, including its id, the expert involved, whether it was paid or volunteer,
  the rating, the longer explanation of the issue, the location of the engagement, and contact info of the current program
  manager responsible for the project they performed.
  For the project spec this satisfies:
  Group 1: Joins of more than one table, and order by statements
  Group 2: aggregate functions, subqueries, having clause, joins of 4+ tables.*/
SELECT engagement_id, expert_name, performance_rating,
       engagement_summary, engagement_locations, for_more_info
FROM
    (SELECT engagement.engagement_id,
        concat(first_name, ' ', last_name) AS expert_name,
        CASE WHEN is_paid = TRUE THEN 'Paid'
           ELSE 'Volunteer' END AS engagement_type,
        performance_rating,
        engagement_summary,
        program.program_id,
        string_agg(country_name_short, ', ') AS engagement_locations


    FROM engagement
    JOIN engagement_location el ON engagement.engagement_id = el.engagement_id
    JOIN country c ON el.country_code = c.country_code
    JOIN person p ON engagement.expert_id = p.person_id
    JOIN engagement_program ep ON engagement.engagement_id = ep.engagement_id
    JOIN program ON ep.program_id = program.program_id
    GROUP BY engagement_summary, performance_rating, first_name, last_name, program.program_id, engagement.engagement_id
    HAVING performance_rating <= 6) t1
JOIN
    (SELECT program_id,
       concat(first_name, ' ', last_name, ' (', email, ')') AS for_more_info
    FROM program
    JOIN employee e ON program.manager_id = e.employee_id
    JOIN person p ON e.employee_id = p.person_id) t2
ON t1.program_id = t2.program_id;


