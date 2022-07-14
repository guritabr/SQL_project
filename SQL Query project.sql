--Dataset taken from:   -https://www.sqltutorial.org/sql-sample-database/

--select*from countries
--select*from departments
--select*from dependents
--select*from employees
--select*from jobs
--select*from locations
--select*from regions


			 --Departments' addresses
SELECT d.department_name AS Department, l.street_address AS "Address", l.city AS City, l.state_province AS "State", l.country_id AS Country 
	FROM departments AS d
	LEFT JOIN locations AS l
	ON d.location_id = l.location_id;


			 --Departments' address using wildcard
SELECT d.department_name AS Department, l.street_address AS "Address", l.city AS City, l.state_province AS "State", l.country_id AS Country 
	FROM departments AS d
	LEFT JOIN locations AS l
	ON d.location_id = l.location_id
	WHERE l.street_address LIKE '%rd';


			 --Number of employees in each department
SELECT d.department_name AS Department, COUNT (e.employee_id) AS "No. of employees" 
	FROM departments AS d
	LEFT JOIN employees AS e
		ON e.department_id = d.department_id
	GROUP BY d.department_name
	ORDER BY "No. of employees" DESC;


			 --Subordinates and superiors
SELECT CONCAT (e.first_name, ' ', e.last_name) AS Subordinate, CONCAT (m.first_name, ' ', m.last_name) AS Superior
	FROM employees AS e
	LEFT JOIN employees AS m
	ON m.employee_id = e.manager_id;


			 --Average salary for every title orderd by cuantum
SELECT job_title AS Title, FLOOR (AVG (min_salary+max_salary) /2) AS "Average salary" 
	FROM jobs
	GROUP BY job_title
	ORDER BY "Average salary" DESC;


			 --Salaries grouped by departments
SELECT d.department_name AS Department, FLOOR (SUM (e.salary)) AS Salary 
	FROM departments as d
	LEFT JOIN employees AS e 
		ON e.department_id = d.department_id
	GROUP BY d.department_name
	ORDER BY "Salary" DESC;


			 --Departments with salaries equal or under 10000 using CTE
WITH Salary (Department, Salary) AS
(
SELECT d.department_name AS Department, FLOOR (SUM (e.salary)) AS Salary 
	FROM departments as d
	LEFT JOIN employees AS e 
		ON e.department_id = d.department_id
	GROUP BY d.department_name
)

SELECT * FROM Salary
	WHERE Salary <= 10000
	ORDER BY Salary DESC;


			 --Simulating costs of a 15% increase of salaries
DROP TABLE IF EXISTS #Sim_salary_increase
CREATE TABLE #Sim_salary_increase
(
Department NVARCHAR(25),
Salary INT
)

INSERT INTO #Sim_salary_increase
SELECT COALESCE(d.department_name, 'TOTAL') AS Department, FLOOR (SUM (e.salary)) AS Salary 
	FROM departments as d
	LEFT JOIN employees AS e 
		ON e.department_id = d.department_id
		GROUP BY ROLLUP (d.department_name, e.salary)

SELECT Department, Salary, (Salary + (Salary*15/100)) AS "Simulation of salary if increased with 15%"
	FROM #Sim_salary_increase
	ORDER BY "Simulation of salary if increased with 15%" DESC;


			 --Stored procedure named <get_information_by_id> where you can enter only the employee's ID and receive useful information about him/her
			 --It can be ran by entering> <get_information_by_id> + <employee's ID> 
			 --Example:   <get_information_by_id 200>
CREATE PROCEDURE get_information_by_id
@employee_id INT
AS
BEGIN
	
	SELECT e.employee_id AS ID, 
		CONCAT (e.first_name, ' ', e.last_name) AS "Name", 
		j.job_title AS Title,
		d.department_name AS Department,
		CONCAT (m.first_name, ' ', m.last_name) AS Superior,
		e.email AS "Email", 
		e.phone_number AS "Phone",
		e.salary AS "Salary" 
	FROM employees AS e
		LEFT JOIN jobs AS j
			ON j.job_id = e.job_id
		LEFT JOIN departments AS d
			ON d.department_id = e.department_id
		LEFT JOIN employees AS m
			ON m.employee_id = e.manager_id
	
	WHERE e.employee_id = @employee_id

END;



			--Replacing values with cursors
DECLARE
@first_name NVARCHAR (50),
@last_name NVARCHAR (50)

DECLARE cursor_manager CURSOR FOR
	SELECT
		last_name
	FROM employees

OPEN cursor_manager

FETCH NEXT FROM cursor_manager INTO @last_name

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT @first_name = first_name FROM employees WHERE last_name = @last_name
	
	IF (@first_name = 'Susan')
	BEGIN
		UPDATE employees SET last_name = 'Potter' WHERE last_name = @last_name
	END

	IF (@first_name = 'Jennifer')
	BEGIN
		UPDATE employees SET last_name = 'McGonagall' WHERE last_name = @last_name
	END
	FETCH NEXT FROM cursor_manager INTO @last_name
END
CLOSE cursor_manager
DEALLOCATE cursor_manager;


			--Replacing values with case
UPDATE employees
SET last_name = 
	CASE
		WHEN first_name = 'Susan' THEN 'Al Mualim'
		WHEN first_name = 'Jennifer' THEN 'Al Harabain'
		ELSE
			last_name
	END;