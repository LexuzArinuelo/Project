/*

Exploratory Data Analysis in SQL Queries

*/

SELECT *
FROM recruitment_data;

---------------------------------------------------------------------------------------------

-- Total number of applicants

SELECT COUNT(*) AS Total_Applicants
FROM recruitment_data;

-- Total number of applicants per month

SELECT 
	month_created, 
    COUNT(*) AS Total_Applicants_Per_Month
FROM recruitment_data
GROUP BY month_created
ORDER BY 2 DESC;

-- Highest number of applicants for week number

SELECT 
	weeknum_created, 
    COUNT(*) AS Highest_NumberCount_for_Weeknum
FROM recruitment_data
GROUP BY weeknum_created
ORDER BY 2 DESC
LIMIT 1;

-- Total number of applicants per day

SELECT 
	day_created, 
    COUNT(*) AS Total_Applicants_Per_Day
FROM recruitment_data
GROUP BY day_created
ORDER BY 2 DESC;

---------------------------------------------------------------------------------------------

-- Total number of different job titles

SELECT COUNT(DISTINCT job_title) AS Total_Job_Titles
FROM recruitment_data;

-- Total number of applicants per job titles

SELECT 
	job_title, 
    COUNT(*) AS Total_Applicants_Per_Day
FROM recruitment_data
GROUP BY job_title
ORDER BY 2 DESC;

---------------------------------------------------------------------------------------------

-- Hired, Rejected, and In Process Applicants Percentage

SELECT 
	COUNT(*) AS Total_Applicants,
    COUNT(rejected_at) AS Rejected_Applicants,
    COUNT(hired_at) AS Hired_Applicants,
    SUM(CASE WHEN hired_at IS NULL AND rejected_at IS NULL THEN 1 ELSE 0 END) AS In_Process_Applicants,
    (COUNT(hired_at)/COUNT(*))*100 AS Hired_Percentage,
    (COUNT(rejected_at)/COUNT(*))*100 AS Rejected_Percentage,
    (SUM(CASE WHEN hired_at IS NULL AND rejected_at IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS In_Process_Percentage
FROM recruitment_data;

-- Daily Application Count

SELECT 
	created AS application_date, 
	COUNT(*) AS daily_applications
FROM recruitment_data
GROUP BY created;


-- Daily Application Average

SELECT AVG(daily_applications) AS daily_applications_average
FROM (
    SELECT 
        COUNT(*) AS daily_applications
    FROM recruitment_data
    GROUP BY created
) AS daily_counts;

-- Maximum number of applications in a single day 

WITH daily_counts AS
	(SELECT 
		created AS application_date, 
        COUNT(*) AS daily_applications
	FROM recruitment_data
	GROUP BY created
    ) 
SELECT 
	application_date, 
    daily_applications
FROM daily_counts
WHERE daily_applications = (
	SELECT MAX(daily_applications)
	FROM daily_counts);

---------------------------------------------------------------------------------------------

-- Frequency of Each Rejection Reason

SELECT reject_reason, COUNT(reject_reason)
FROM recruitment_data
GROUP BY reject_reason
ORDER BY 2 DESC;

---------------------------------------------------------------------------------------------

-- Count of Applicants per Referring Site

SELECT referring_site, COUNT(referring_site) AS Applicants_Count
FROM recruitment_data
GROUP BY referring_site;

-- Count of Referring Sites for Hired Applicants

SELECT referring_site, COUNT(referring_site)
FROM recruitment_data
WHERE hired_at IS NOT NULL
GROUP BY referring_site;

---------------------------------------------------------------------------------------------






