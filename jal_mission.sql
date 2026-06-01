#___________________________________________Jal Jivan Mission Performance Analysi______________________________________________________# 

CREATE DATABASE jal_mission;

SHOW databases;

USE jal_mission;
#__________________________________________________________________________________________#

-- Q. 1: Check if the data is imported successfully
SELECT * FROM hgj_data LIMIT 10;

-- Q. 2: Counting total records
SELECT COUNT(*) AS Total_Districts   -- COUNT(*) counts the total number of rows in the table.
FROM hgj_data;

-- Describe the table structure
DESCRIBE hgj_data;     -- This shows you the "blueprint" of your table: column names, data types, and key constraints.

-- View the creation details
SHOW CREATE TABLE hgj_data;      -- This displays the complete 'CREATE TABLE' statement used to build this structure.

SELECT MIN(Create_Performance_Score) AS Minimum_Score 
FROM hgj_data;

SELECT AVG(Create_Performance_Score) AS Average_Score 
FROM hgj_data;

SELECT STDDEV(Create_Performance_Score) AS Standard_Deviation 
FROM hgj_data;

SELECT VARIANCE(Create_Performance_Score) AS Variance_Score 
FROM hgj_data;

SELECT COUNT(*) - COUNT(Create_Performance_Score) AS Missing_Values_Count 
FROM hgj_data;

SELECT Create_Performance_Score, COUNT(*) AS Frequency 
FROM hgj_data 
GROUP BY Create_Performance_Score 
ORDER BY Frequency DESC 
LIMIT 1;

-- Finding duplicate entries for a specific District_Name
SELECT District_Name, COUNT(*) 
FROM hgj_data 
GROUP BY District_Name 
HAVING COUNT(*) > 1;

SELECT 
    MAX(Create_Performance_Score) - MIN(Create_Performance_Score) AS Performance_Range
FROM hgj_data;

SELECT (STDDEV(Create_Performance_Score) / AVG(Create_Performance_Score)) AS Coeff_of_Variation
FROM hgj_data;

SELECT 
    AVG(Create_Performance_Score) AS Mean_Value,
    (SELECT Create_Performance_Score 
     FROM (SELECT Create_Performance_Score, ROW_NUMBER() OVER(ORDER BY Create_Performance_Score) as rn, COUNT(*) OVER() as total FROM hgj_data) sub
     WHERE rn = ROUND(total/2)) AS Median_Value
FROM hgj_data;

SELECT DISTINCT TRIM(District_Name) 
FROM hgj_data;

SELECT District_Name, COALESCE(Implementation_Efficiency, 0) AS Efficiency
FROM hgj_data;

SELECT District_Name, Create_Performance_Score 
FROM hgj_data 
WHERE Create_Performance_Score < (SELECT AVG(Create_Performance_Score) * 0.5 FROM hgj_data);

-- Q : Check unique districts
SELECT DISTINCT District_Name       -- DISTINCT removes duplicates so you can see if there are repeated district names.
FROM hgj_data;

-- Q : Filter for districts with more than 500 villages in the 'Gap'
SELECT District_Name, Village_Gap     -- WHERE filters the rows based on the condition provided.
FROM hgj_data 
WHERE Village_Gap > 500;

-- Q : Find districts starting with 'A'
SELECT District_Name               -- LIKE 'A%' matches any text that starts with 'A'.
FROM hgj_data 
WHERE District_Name LIKE 'A%';

-- Q : Check if any rows have NULL in 'Implementation_Efficiency'
SELECT * FROM hgj_data          -- IS NULL helps you identify missing information.
WHERE Implementation_Efficiency IS NULL;

-- Q : List districts with the highest Performance Score
SELECT District_Name, Create_Performance_Score      -- ORDER BY sorts the results, and DESC puts the highest values at the top.
FROM hgj_data 
ORDER BY Create_Performance_Score DESC;

DESCRIBE hgj_data;

ALTER TABLE hgj_data CHANGE `No._of_villages` `No_of_villages` INT;

SELECT SUM(No_of_villages) AS Total_Villages_Across_All_Districts 
FROM hgj_data;

-- GROUP BY categorizes the data so you can see how many districts fall into each 'gap' level
SELECT Block_Gap, COUNT(District_Name) AS Number_of_Districts 
FROM hgj_data 
GROUP BY Block_Gap 
ORDER BY Block_Gap;

-- LIMIT 5 restricts the output to the top 5 records
SELECT District_Name, Create_Performance_Score 
FROM hgj_data 
ORDER BY Create_Performance_Score DESC 
LIMIT 5;

-- Filtering with WHERE and then calculating the average
SELECT AVG(Create_Performance_Score) AS Avg_Score_of_Certified_Districts 
FROM hgj_data 
WHERE HGJ_Villages_Certified > 0;

-- 'Village Gap' represents the work still pending
SELECT District_Name, Village_Gap 
FROM hgj_data 
ORDER BY Village_Gap DESC 
LIMIT 3;

-- Using CASE to categorize districts into 'High' or 'Low' performance
SELECT District_Name, 
       CASE 
           WHEN Create_Performance_Score > 80 THEN 'High Performance'
           ELSE 'Needs Improvement'
       END AS Performance_Level
FROM hgj_data;

-- Combining CASE with GROUP BY to generate a summary report
SELECT 
    CASE 
        WHEN Create_Performance_Score > 80 THEN 'High Performance'
        ELSE 'Needs Improvement'
    END AS Performance_Level,
    COUNT(*) AS District_Count
FROM hgj_data
GROUP BY Performance_Level;

DESCRIBE hgj_data;

-- This helps you see how much work is left as a percentage
SELECT District_Name, 
       (Village_Gap / No_of_villages) * 100 AS Pending_Work_Pct 
FROM hgj_data 
ORDER BY Pending_Work_Pct DESC;

-- Using a Subquery to filter dynamically (very powerful for reports)
SELECT District_Name, Create_Performance_Score 
FROM hgj_data 
WHERE Create_Performance_Score > (SELECT AVG(Create_Performance_Score) FROM hgj_data);

-- Combining multiple metrics to find districts that need immediate attention
SELECT District_Name, Village_Gap, Implementation_Efficiency 
FROM hgj_data 
WHERE Village_Gap > 500 AND Implementation_Efficiency < 50;

-- Grouping by custom buckets
SELECT 
    CASE 
        WHEN Create_Performance_Score < 50 THEN 'Low'
        WHEN Create_Performance_Score BETWEEN 50 AND 80 THEN 'Medium'
        ELSE 'High'
    END AS Performance_Bucket,
    COUNT(District_Name) AS District_Count
FROM hgj_data 
GROUP BY Performance_Bucket;

-- Finding the 'Winner' in each category
SELECT 
    (SELECT District_Name FROM hgj_data ORDER BY Create_Performance_Score DESC LIMIT 1) AS Top_Performance_District,
    (SELECT District_Name FROM hgj_data ORDER BY Village_Gap ASC LIMIT 1) AS Best_Progress_District;

-- This categorizes districts to help management decide where to allocate budget
SELECT 
    District_Name,
    CASE 
        WHEN Create_Performance_Score > 70 AND Village_Gap < 100 THEN 'Star Performer'
        WHEN Create_Performance_Score < 50 AND Village_Gap > 500 THEN 'Urgent Intervention Needed'
        ELSE 'Monitor Progress'
    END AS Strategic_Category
FROM hgj_data;

-- Comparing Median vs Mean to identify data skewness
SELECT 
    AVG(Create_Performance_Score) AS Mean_Score,
    (SELECT Create_Performance_Score FROM (
        SELECT Create_Performance_Score, ROW_NUMBER() OVER(ORDER BY Create_Performance_Score) as rn, COUNT(*) OVER() as cnt FROM hgj_data
    ) t WHERE rn = ROUND(cnt/2)) AS Median_Score
FROM hgj_data;

-- Checking the correlation between Efficiency and Gap (Higher correlation = better policy impact)
SELECT 
    District_Name, 
    Implementation_Efficiency, 
    Village_Gap
FROM hgj_data
ORDER BY Implementation_Efficiency DESC;

SELECT 
    FLOOR(Create_Performance_Score / 10) * 10 AS Score_Range,
    COUNT(*) AS Number_of_Districts
FROM hgj_data
GROUP BY Score_Range
ORDER BY Score_Range;

SELECT District_Name, Create_Performance_Score, Village_Gap 
FROM hgj_data 
WHERE Create_Performance_Score < 50 AND Village_Gap > 100 
ORDER BY Village_Gap DESC;

SELECT District_Name, Create_Performance_Score,
       RANK() OVER(ORDER BY Create_Performance_Score DESC) as Performance_Rank
FROM hgj_data;


#_______________VIEW______________#

SELECT MAX(Create_Performance_Score) FROM hgj_data;

CREATE OR REPLACE VIEW high_perf_districts AS
SELECT District_Name, Create_Performance_Score, Village_Gap
FROM hgj_data
WHERE Create_Performance_Score > 50; 
SELECT * FROM high_perf_districts;


CREATE OR REPLACE VIEW urgent_intervention_districts AS
SELECT 
    District_Name, 
    Create_Performance_Score, 
    Village_Gap 
FROM hgj_data 
WHERE Create_Performance_Score < 50 AND Village_Gap > 100 
ORDER BY Village_Gap DESC;
SELECT * FROM urgent_intervention_districts;

-- ****************************************************
-- PROJECT SUMMARY: Jal Jivan Mission Performance Analysis
-- STATUS: Successfully Completed

-- DATA DICTIONARY:
-- District_Name: Name of the district.
-- Create_Performance_Score: Performance metric (0-100).
-- Village_Gap: Number of villages yet to be covered.
-- Implementation_Efficiency: Efficiency rate of implementation.

-- METHODOLOGY:
-- 1. Data Cleaning: Utilized TRIM and COALESCE to handle inconsistencies and NULL values.
-- 2. Statistical Profiling: Calculated Mean, Median, StdDev, and Variance to understand data dispersion.
-- 3. Distribution Analysis: Performed Binning using FLOOR functions for frequency analysis.
-- 4. Strategic Insights: Used CASE statements to categorize districts for prioritized resource allocation.

-- KEY FINDINGS:
-- 1. Identified districts with low performance (<50) and high pending work (>100) requiring urgent intervention.
-- 2. Compared Mean vs. Median to determine the skewness of the performance distribution.
-- 3. Established a classification framework (Star Performer vs. Monitor Progress) for better decision-making.
-- ****************************************************


