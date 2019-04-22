



SELECT
       person_id,
       first_name || ' ' || last_name AS employee_name,
       email,
       phone
FROM person
JOIN employee e ON person.person_id = e.employee_id;



SELECT * FROM program