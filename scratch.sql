

-- Query to summarize our programs, with
SELECT program.program_id,
       program_name,
       start_date,
       end_date,
       concat(first_name, ' ', last_name) AS manager_name,
       string_agg(DISTINCT(theme_code), ', ') AS program_themes,
       string_agg(DISTINCT(country_code), ', ') AS program_countries -- i don't know if there is a better way than executing distinct here.

FROM program
JOIN employee e ON program.manager_id = e.employee_id
JOIN person p ON e.employee_id = p.person_id
JOIN program_categorization pc ON program.program_id = pc.program_id
JOIN program_location pl ON program.program_id = pl.program_id
GROUP BY (program.program_id, program_name, start_date, end_date, p.first_name, p.last_name)
ORDER BY (start_date);


SELECT expert_id,
       count(pe.engagement_id) AS num_engagements,
       round(avg(performance_rating), 2) AS average_rating,
       date_part('day', end_date) - date_part('day', start_date) AS total_days,
/*       CASE WHEN fee_type = 'Daily' THEN fee_rate
           WHEN fee_type = 'Hourly' THEN fee_rate * 8
           ELSE fee_rate / DateDiff(day, engagement.end_date, engagement.start_date)
           END AS fee_rate,*/

      /* avg(fee_rate) AS average_fee,*/
       sum(fee_rate * work_time)

FROM engagement
JOIN paid_engagement pe ON engagement.engagement_id = pe.engagement_id
WHERE is_paid = TRUE
GROUP BY (expert_id, engagement.end_date, engagement.start_date)



SELECT
       person_id,
       first_name || ' ' || last_name AS employee_name,
       email,
       phone
FROM person
JOIN employee e ON person.person_id = e.employee_id;





SELECT
ep.program_id,
count(DISTINCT (ep.engagement_id))
FROM engagement
join engagement_program ep ON engagement.engagement_id = ep.engagement_id
GROUP BY (ep.program_id);

-- ROLLBACK TRANSACTION ;




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







ROLLBACK TRANSACTION;