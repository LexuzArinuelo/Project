/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM recruitment_data;

---------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH duplicates AS (
    SELECT 
        id, ROW_NUMBER() OVER (PARTITION BY created, applicant, job_title ORDER BY id) AS row_num
    FROM recruitment_data
) 
SELECT *
FROM duplicates
	WHERE row_num > 1;

WITH duplicates AS (
    SELECT 
        id, ROW_NUMBER() OVER (PARTITION BY created, applicant, job_title ORDER BY id) AS row_num
    FROM recruitment_data
)
DELETE FROM recruitment_data
WHERE id IN (
    SELECT id
    FROM duplicates
    WHERE row_num > 1
);

---------------------------------------------------------------------------------------------

-- Standarize created date Format into ('%Y-%m-%d')

SELECT LEFT(created, 10)
FROM recruitment_data;

UPDATE recruitment_data
SET Created = LEFT(created, 10);

---------------------------------------------------------------------------------------------

-- Create columns for month, week number, and day

ALTER TABLE recruitment_data
	ADD COLUMN month_created VARCHAR(9) AFTER Created,
    ADD COLUMN weeknum_created INT AFTER month_created,
    ADD COLUMN day_created VARCHAR(9) AFTER weeknum_created;

-- Extract month, week number, and day from created column

UPDATE recruitment_data
SET
    month_created = DATE_FORMAT(STR_TO_DATE(SUBSTRING_INDEX(Created, 'T', 1), '%Y-%m-%d'), '%M'),
    weeknum_created = WEEK(STR_TO_DATE(SUBSTRING_INDEX(Created, 'T', 1), '%Y-%m-%d'), 1),
    day_created = DAYNAME(STR_TO_DATE(SUBSTRING_INDEX(Created, 'T', 1), '%Y-%m-%d'));

---------------------------------------------------------------------------------------------

-- Standardize Applicant Names Format into Proper Casing

SELECT CONCAT(
    UPPER(SUBSTRING(applicant, 1, 1)), 
    LOWER(SUBSTRING(applicant, 2, LOCATE(' ', applicant) - 1)),
    ' ',
    UPPER(SUBSTRING(applicant, LOCATE(' ', applicant) + 1, 1)),
    LOWER(SUBSTRING(applicant, LOCATE(' ', applicant) + 2))
) AS ProperCase
FROM recruitment_data;

UPDATE recruitment_data
SET applicant = CONCAT(
    UPPER(SUBSTRING(applicant, 1, 1)), 
    LOWER(SUBSTRING(applicant, 2, LOCATE(' ', applicant) - 1)),
    ' ',
    UPPER(SUBSTRING(applicant, LOCATE(' ', applicant) + 1, 1)),
    LOWER(SUBSTRING(applicant, LOCATE(' ', applicant) + 2)));
    
---------------------------------------------------------------------------------------------

-- Standardizing Job Title Format

SELECT DISTINCT job_title
FROM recruitment_data;

-- Removing unnecessary parts with indeed in the job title

SELECT 
    job_title,
    SUBSTRING_INDEX(job_title, '-', 1) AS indeed_part,
    SUBSTRING_INDEX(SUBSTRING_INDEX(job_title, '-', 2), '-', -1) AS job_title
FROM recruitment_data
WHERE job_title LIKE '%Indeed%';

UPDATE recruitment_data
SET job_title = SUBSTRING_INDEX(SUBSTRING_INDEX(job_title, '-', 2), '-', -1)
	WHERE job_title LIKE '%Indeed%';

-- Removing unnecessary parts with time in the job title such as Full-Time and Part-Time

SELECT DISTINCT job_title, SUBSTRING_INDEX(job_title, '-', -1)
FROM recruitment_data
	WHERE job_title LIKE '%time%';

UPDATE recruitment_data
SET job_title = CASE
        WHEN job_title LIKE '%Dental Hygienist%' THEN 'Dental Hygienist'
        WHEN job_title LIKE '%Hygienist%' THEN 'Hygienist'
        ELSE job_title
    END
WHERE job_title LIKE '%time%';

-- Leaving job titles only by removing unnecessary parts

SELECT 
    job_title,
    SUBSTRING_INDEX(job_title, '-', 1) AS cleaned_job_title
FROM recruitment_data;

UPDATE recruitment_data
SET job_title = SUBSTRING_INDEX(job_title, '-', 1);

-- Standardizing Spanish job titles

SELECT DISTINCT job_title
FROM recruitment_data
WHERE job_title LIKE '%Asistente%';

UPDATE recruitment_data
SET job_title = CASE
        WHEN job_title LIKE '%Asistente De Silla%' THEN 'Chairside Assistant'
        WHEN job_title LIKE '%Asistente Dental En el Sill%' THEN 'Chairside Dental Assistant'
        ELSE job_title
    END
WHERE job_title LIKE '%asistente%';

-- More Standardizing

UPDATE recruitment_data
SET job_title = CASE
        WHEN job_title LIKE 'Indeed Applicants Dental Office Manager' THEN 'Dental Office Manager'
        ELSE job_title
    END;

-- Trim job title

UPDATE recruitment_data
SET job_title = TRIM(job_title);

---------------------------------------------------------------------------------------------

-- Standardize rejected_at and hired_at date into ('%Y-%m-%d')

SELECT LEFT(rejected_at, 10)
FROM recruitment_data;

UPDATE recruitment_data
SET rejected_at = LEFT(rejected_at, 10);

SELECT LEFT(hired_at, 10)
FROM recruitment_data;

UPDATE recruitment_data
SET hired_at = LEFT(hired_at, 10);

---------------------------------------------------------------------------------------------

-- Set blank values to null

UPDATE recruitment_data
SET reject_reason = NULLIF(reject_reason, ''),
	rejected_at = NULLIF(rejected_at, ''),
    hired_at = NULLIF(hired_at, ''),
	referring_site = NULLIF(referring_site, '');

---------------------------------------------------------------------------------------------

-- Standardize Referring Site

SELECT DISTINCT referring_site
FROM recruitment_data;

UPDATE recruitment_data
SET referring_site = CASE 
    WHEN referring_site = 'Indeed Direct Apply' THEN 'Indeed'
    WHEN referring_site = 'com.google.android.gm' THEN 'Gmail'
    WHEN referring_site = 'ZipRecruiter United States' THEN 'ZipRecruiter'
    WHEN referring_site = 'Monster United States' THEN 'Monster'
    WHEN referring_site = 'New_job' THEN 'New Job'
    WHEN referring_site = 'jooble.org' THEN 'Jooble'
    WHEN referring_site = 'instagram.com' THEN 'Instagram'
    WHEN referring_site = 'salary.com' THEN 'Salary'
    WHEN referring_site = 'www.salary.com' THEN 'Salary'
    WHEN referring_site = 'talent.com' THEN 'Talent'
    WHEN referring_site = 'www.talent.com' THEN 'Talent'
    ELSE referring_site
END;

---------------------------------------------------------------------------------------------

-- Drop unnecessary column

ALTER TABLE recruitment_data
DROP COLUMN stage_name;

---------------------------------------------------------------------------------------------

