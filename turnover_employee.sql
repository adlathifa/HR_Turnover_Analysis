CREATE DATABASE hr_analysis;

-- Step 1: Clean the data ensure there is no duplicate
SELECT * FROM turnover_employee;

SELECT Emp_ID, COUNT(*) AS Amount
FROM turnover_employee
GROUP BY Emp_ID
HAVING COUNT(*) >1;

-- Step 2: Convert datetime values to date only 
ALTER TABLE turnover_employee
ADD COLUMN DOB_cleaned DATE;

UPDATE turnover_employee
SET DOB_cleaned = DATE(DOB);

ALTER TABLE turnover_employee
DROP COLUMN DOB_cleaned;
ALTER TABLE turnover_employee
RENAME COLUMN DOB_cleaned TO DOB;

-- Step 3: Calculate the total number of employees hired
SELECT COUNT(*) Emp_ID
FROM turnover_employee;

-- Step 4: Calculate the number of currently active employees
SELECT COUNT(*) as total_active_employee
FROM turnover_employee
WHERE EmploymentStatus = "Active";

-- Step 5: Calculate the number of employees who have resigned (turnover)
SELECT COUNT(*) as total_turnover_employee
FROM turnover_employee
WHERE NOT EmploymentStatus = "Active";

-- Step 6: Calculate the average number of employee absences
SELECT FLOOR(AVG(Absences)) as avg_absences
FROM turnover_employee;

-- Analysis Section
-- Q1: What is the turnover rate for each department?
SELECT Department,
	ROUND(
    COUNT(CASE WHEN EmploymentStatus != "Active" THEN 1 END) * 100.0 / COUNT(*), 1
    ) AS turnover_rate
FROM turnover_employee
GROUP BY Department
ORDER BY turnover_rate DESC;

-- Q2: What is the turnover rate by age group, and how many people are in each group?
WITH employee_age_group AS (
  SELECT *,
    CASE 
      WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 30 AND 50 THEN '30-50'
      WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) > 50 THEN 'Above 50'
    END AS age_group
  FROM turnover_employee
)
SELECT 
  age_group,
  COUNT(CASE WHEN EmploymentStatus != 'Active' THEN 1 END) AS total_turnover,
  ROUND(
    COUNT(CASE WHEN EmploymentStatus != 'Active' THEN 1 END) * 100.0 / COUNT(*), 1
  ) AS turnover_rate
FROM employee_age_group
WHERE age_group IS NOT NULL
GROUP BY age_group;

-- Q3: What is the turnover rate based on employee performance?
SELECT PerformanceScore,
	ROUND(
    COUNT(CASE WHEN EmploymentStatus != "Active" THEN 1 END) * 100.0 / COUNT(*), 1
    ) AS turnover_rate
FROM turnover_employee
GROUP BY PerformanceScore
ORDER BY turnover_rate DESC;

-- Q4: What are the main reasons employees give for resigning?
SELECT TermReason, COUNT(CASE WHEN TermReason NOT LIKE '%StillEmployed%' THEN 1 END) AS reason
FROM turnover_employee
GROUP BY TermReason
ORDER BY reason DESC;

-- Q5: What is the level of employee satisfaction per department?
SELECT Department, ROUND(AVG(EmpSatisfaction), 1) AS emp_satisfaction
FROM turnover_employee
GROUP BY Department
ORDER BY emp_satisfaction DESC;

-- Q6: What is the average number of absences per department?
SELECT Department, ROUND(AVG(Absences)) AS avg_absences
FROM turnover_employee
GROUP BY Department
ORDER BY avg_absences DESC;
