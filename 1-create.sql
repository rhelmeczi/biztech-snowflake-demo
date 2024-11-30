-- You don't always need this, it just helps ensure repeatability.
USE ROLE ACCOUNTADMIN;

-- Create the database for our schema
CREATE DATABASE IF NOT EXISTS BIZTECH_DEMO;

-- The schema will store the data for us
CREATE SCHEMA IF NOT EXISTS BIZTECH_DEMO.CLF;

/**
  * Here we make up some data to train a model on. Our goal is to predict
  * a student's performance on an exam based on how much they studied, how they
  * did on previous exams, and the study method they chose to use.
  */
CREATE OR REPLACE TABLE BIZTECH_DEMO.CLF.STUDENT_GRADES AS 
    SELECT
        ROW_NUMBER() OVER (ORDER BY RANDOM()) AS STUDENT_ID,
        *
    FROM
        (
            SELECT
                -- Time Spent Studying (hours), modeled with mean=3 and stddev=1
                3 + ROUND(NORMAL(3, 1, RANDOM()), 2) AS time_spent_studying,
                
                -- Previous Grades (out of 100), modeled with mean=75 and stddev=10
                ROUND(NORMAL(70, 5, RANDOM()), 2) AS previous_grades,
                
                -- Study Method (categorical)
                CASE 
                    WHEN RANDOM() < 0.4 THEN 'Self-Study'
                    WHEN RANDOM() < 0.8 THEN 'Group Study'
                    ELSE 'Tutoring'
                END AS study_method,
                               
                -- Performance Label (Low Performance)
                'Low Performance' AS exam_performance
            
            FROM TABLE(GENERATOR(ROWCOUNT => 1000)) 
            UNION ALL
            SELECT
                3 + ROUND(NORMAL(7, 2, RANDOM()), 2) AS time_spent_studying,
                ROUND(NORMAL(75, 10, RANDOM()), 2) AS previous_grades,
                CASE 
                    WHEN RANDOM() < 0.4 THEN 'Self-Study'
                    WHEN RANDOM() < 0.8 THEN 'Group Study'
                    ELSE 'Tutoring'
                END AS study_method,
                'Medium Performance' AS exam_performance
            
            FROM TABLE(GENERATOR(ROWCOUNT => 1000)) 
            
            UNION ALL

            SELECT
                3 + ROUND(NORMAL(15, 3, RANDOM()), 2) AS time_spent_studying,
                ROUND(NORMAL(85, 5, RANDOM()), 2) AS previous_grades,
                CASE 
                    WHEN RANDOM() < 0.4 THEN 'Self-Study'
                    WHEN RANDOM() < 0.8 THEN 'Group Study'
                    ELSE 'Tutoring'
                END AS study_method,
                'High Performance' AS exam_performance
            
            FROM TABLE(GENERATOR(ROWCOUNT => 1000))
            order by Random()
        );


-- Next let's create some other tables that we'll need when we train our machine learning model

-- This table is our training data for the ML model.
-- This data is passed to the model to help it learn
CREATE OR REPLACE TABLE
    BIZTECH_DEMO.CLF.TRAINING_DATA
AS
    SELECT
        TIME_SPENT_STUDYING,
        PREVIOUS_GRADES,
        STUDY_METHOD,
        EXAM_PERFORMANCE
    FROM
        BIZTECH_DEMO.CLF.STUDENT_GRADES
    WHERE
        STUDENT_ID < 2000;

-- This is the test data. Our ML model will be used on this data
-- after training so we can see how good it is
CREATE OR REPLACE TABLE
    BIZTECH_DEMO.CLF.TEST_DATA
AS
    SELECT
        *
    FROM
        BIZTECH_DEMO.CLF.STUDENT_GRADES
    WHERE
        STUDENT_ID > 2000;

-- This helps us when we evaluate the model later on.
-- "Support" here is just a fancy way of saying "Count"
-- 
-- This data will just count up the students for each exam performance
-- category. 
CREATE OR REPLACE VIEW
    BIZTECH_DEMO.CLF.TEST_DATA_SUPPORT
AS
    SELECT
        EXAM_PERFORMANCE,
        COUNT(*) AS NUM_STUDENTS
    FROM
        BIZTECH_DEMO.CLF.TEST_DATA
    GROUP BY
        EXAM_PERFORMANCE;

        