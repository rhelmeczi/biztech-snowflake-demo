-- You don't always need this, it just helps ensure repeatability.
USE ROLE ACCOUNTADMIN;

/** 
  * Let's just take a peek at the first 20 rows of the data.
  */ 
SELECT
    * 
FROM
    BIZTECH_DEMO.CLF.STUDENT_GRADES 
LIMIT
    20;

/**
  * Now let's look at the aggregated statistics (i.e., average, minimum, etc...) values
  */
SELECT
    EXAM_PERFORMANCE,
    AVG(TIME_SPENT_STUDYING),
    AVG(PREVIOUS_GRADES),
    MIN(TIME_SPENT_STUDYING),
    MIN(PREVIOUS_GRADES)
FROM
    BIZTECH_DEMO.CLF.STUDENT_GRADES
GROUP BY
    EXAM_PERFORMANCE;

/**
  * Finally, let's make a plot of the data.
  */
SELECT
    EXAM_PERFORMANCE,           -- Performance level (Low, Medium, High)
    TIME_SPENT_STUDYING,        -- Time spent studying (X-axis)
    PREVIOUS_GRADES,            -- Previous grades (Y-axis)
    -- You can include additional columns if needed (like individual student ID for example)
FROM
    BIZTECH_DEMO.CLF.STUDENT_GRADES;