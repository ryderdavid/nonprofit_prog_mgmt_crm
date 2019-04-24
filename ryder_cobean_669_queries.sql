



SELECT
       person_id,
       first_name || ' ' || last_name AS employee_name,
       email,
       phone
FROM person
JOIN employee e ON person.person_id = e.employee_id;



SELECT
       person_id,
       first_name || ' ' || last_name AS expert_name,
       email,
       string_agg(theme_code, ', '),
       phone,
       concat(street_num, ' ', street_name, ', ', city, ', ', (subnational_div || ', '), address_country, ', ', postal_code) AS address,
       first_entered
FROM person
JOIN expert ON person.person_id = expert.expert_id
JOIN address ON expert.address_id = address.address_id
JOIN expert_categorization ec ON expert.expert_id = ec.expert_id
GROUP BY person_id, address;

SELECT engagement.engagement_id,
--        concat(person.first_name, person.last_name, ' ') AS expert_name,
       concat(first_name, ' ', last_name) AS expert_name,
       engagement_summary,
       performance_rating,
       string_agg(country_name_short, ', ')


FROM engagement
JOIN engagement_location el ON engagement.engagement_id = el.engagement_id
JOIN country c ON el.country_code = c.country_code
JOIN person p ON engagement.expert_id = p.person_id
GROUP BY engagement.engagement_id, engagement_summary, performance_rating, first_name, last_name;

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
ORDER BY (start_date)


SELECT expert_id,
       count(pe.engagement_id) AS num_engagements,
       round(avg(performance_rating), 2) AS average_rating,
       CASE WHEN fee_type = 'Daily' THEN fee_rate
           WHEN fee_type = 'Hourly' THEN fee_rate * 8
           ELSE fee_rate / DateDiff(day, engagement.end_date, engagement.start_date)
           END AS fee_rate,

      /* avg(fee_rate) AS average_fee,*/
       sum(fee_rate * work_time)

FROM engagement
JOIN paid_engagement pe ON engagement.engagement_id = pe.engagement_id
WHERE is_paid = TRUE
GROUP BY (expert_id)


