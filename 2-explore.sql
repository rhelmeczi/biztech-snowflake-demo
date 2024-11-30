/**
  * In this file, we do some data exploration. We'll look at the data we just generated.
  * We'll also do some aggregations to pick out overall trends in the data, and finally
  * we'll make a plot to visually inspect the distributions.
  */

-- You don't always need this, it just helps ensure repeatability if you run the whole file.
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
  * 
  * In snowflake, running this query won't immediately show you a plot. You'll need to change to the
  * chart view after running it. Then make it a scatter plot.
  * 
  * In our example, we plot time spent studying on the X axis, previous grades on the y axis, and then
  * exam performance becomes the colours. You should be able to visually see the different performances tend
  * to cluster around different places.
  */
SELECT
    EXAM_PERFORMANCE,
    TIME_SPENT_STUDYING,
    PREVIOUS_GRADES,
FROM
    BIZTECH_DEMO.CLF.STUDENT_GRADES;