/**
  * In this file, we're going to train our own machine learning model on the data we generated.
  * We can do this in just a few clicks.
  * 
  * We already created our training and test data sets in our data generation file, so here we
  * are simply going to train the model, do some predictions, and then evaluate how well our model did.
  */


-- You don't always need this, it just helps ensure repeatability if you run the whole file.
USE ROLE ACCOUNTADMIN;

/**
  * This step trains the model and stores it as a function called `BIZTECH_DEMO.CLF.PREDICT_PERFORMANCE`.
  * You can see in the code below that the training data is this table: `BIZTECH_DEMO.CLF.TRAINING_DATA`.
  * 
  * TARGET_COLNAME indicates the column we want the model to predict.  
  */
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION BIZTECH_DEMO.CLF.PREDICT_PERFORMANCE(
    INPUT_DATA => SYSTEM$REFERENCE('TABLE', 'BIZTECH_DEMO.CLF.TRAINING_DATA'),
    TARGET_COLNAME => 'EXAM_PERFORMANCE',
    CONFIG_OBJECT => { 'ON_ERROR': 'SKIP' }
);

/**
  * This code is commented out, but if you noticed your model isn't working you can take a look at the logs here
  * to try to understand what went wrong. Just remove the `--` from the front to get rid of the comment.
  */
-- CALL BIZTECH_DEMO.CLF.PREDICT_PERFORMANCE!SHOW_TRAINING_LOGS();

/**
  * Here, we use the model we just created to predict how each student did based on their study habits and previous grades.
  * 
  * The predictions are actually returned as a bunch of data, including with probabilities. We use `:class` to pick out just the
  * actual prediction.
  */
CREATE OR REPLACE TABLE 
    BIZTECH_DEMO.CLF.PREDICTIONS
AS 
    SELECT
        *, 
        BIZTECH_DEMO.CLF.PREDICT_PERFORMANCE!PREDICT(
            OBJECT_CONSTRUCT(*)
        ):class as PREDICTED_PERFORMANCE
    from BIZTECH_DEMO.CLF.TEST_DATA;

SELECT * FROM BIZTECH_DEMO.CLF.PREDICTIONS LIMIT 10;

/**
  * Here, we just add up every time the model was correct for each exam_performance level.
  */ 
CREATE OR REPLACE VIEW
    BIZTECH_DEMO.CLF.CORRECT_PREDICTIONS_COUNT
AS
    SELECT
        EXAM_PERFORMANCE,
        COUNT(*) AS NUM_CORRECT
    FROM
        BIZTECH_DEMO.CLF.PREDICTIONS
    WHERE
        EXAM_PERFORMANCE = PREDICTED_PERFORMANCE
    GROUP BY
        EXAM_PERFORMANCE;

/**
  * Here we are just counting up the total number of predictions for each exam performance.
  * So if the model predicts that 120 students got a LOW_PERFORMANCE, this table would have a row
  * containing LOW_PERFORMANCE with the number 120 as NUM_PREDICTED.
  * 
  * We will use this to evaluate our model later on. It's very useful because sometimes a model can
  * look confusing when you evaluate it. For example, if your model just predicted EVERY STUDENT did poorly,
  * then you would see it's always correct when predicting LOW_PERFORMANCE. But we know that model is not very good,
  * so we need to account for the number of predictions the model made that were low performance.
  */
CREATE OR REPLACE VIEW
    BIZTECH_DEMO.CLF.TOTAL_PREDICTIONS_COUNT
AS
    SELECT
        PREDICTED_PERFORMANCE,
        COUNT(*) AS NUM_PREDICTED
    FROM
        BIZTECH_DEMO.CLF.PREDICTIONS
    GROUP BY
        PREDICTED_PERFORMANCE;

/**
  * Let's look at what we just made - how many in total did the model get right for each performance level?
  */
SELECT * FROM BIZTECH_DEMO.CLF.CORRECT_PREDICTIONS_COUNT;

/**
  * When we generated all the data, we also counted up how many students there actually were that had each different
  * performance level. Now, we can calculate the some key metrics for this model for each of these performance levels.
  * 
  * The RECALL simply tells us the percentage of students that were correctly predicted to have a particular score.
  * For example, if 10 students got a high performance, but the model only predicted 2 of those 10 scored high performance,
  * the recall will be
  * 
  *     RECALL = 2 / 10 = 20%
  *
  * The PRECISION tells us about how accurate the model is when predicting a particular performance level.
  * For example, if the model predicts that 10 students score high performance, but only 6 of those students actually scored
  * high performance on the exam, then the precision would be
  *
  *     PRECISION = 6 / 10 = 60%
  */   
SELECT
    COUNTS.EXAM_PERFORMANCE AS EXAM_PERFORMANCE,
    ROUND(100 * NUM_CORRECT / NUM_STUDENTS, 2) AS RECALL,
    ROUND(100 * NUM_CORRECT / NUM_PREDICTED, 2) AS PRECISION
FROM
    BIZTECH_DEMO.CLF.CORRECT_PREDICTIONS_COUNT AS COUNTS
JOIN
    BIZTECH_DEMO.CLF.TEST_DATA_SUPPORT AS SUPPORT
ON
    COUNTS.EXAM_PERFORMANCE = SUPPORT.EXAM_PERFORMANCE
JOIN
    BIZTECH_DEMO.CLF.TOTAL_PREDICTIONS_COUNT AS TOTAL_COUNTS
ON
    TOTAL_COUNTS.PREDICTED_PERFORMANCE = SUPPORT.EXAM_PERFORMANCE;

