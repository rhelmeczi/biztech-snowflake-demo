# UBC BizTech Snowflake Demo

To demonstrate some of the capabilities of data warehouses in general, this repository provides
some helper code to follow along with.

With the code in this repository, we will:

- Create some synthetic data about a real world problem
- Explore this data using queries and visualization
- Create a machine learning model using built-in snowflake functionality to make some predictions about the data
- Check the accuracy of those predictions.

You do **not** have to understand all of the code written here - for introductory data science, this will feel a bit daunting.
The hopeful takeaway is the capabilities of a data warehouse, namely that they:

- Store all your data
- Let you query and visualize your data (or connect to better tools for that job)
- Let you train machine learning models

all in one place!

## In this Repository

Here in this repository we have three files:

1. Create - in this file, we create the dataset that we're going to use for the tutorial. It is not necessary that you
understand this code, only that it creates the dataset we will use in the reset of the tutorial.
2. Explore - in this file, we have some simple commands that will tell us about the dataset we created in the previous step.
In this file we'll look at a few tables and a visualization of the data as well.
3. Model - in this file, we will finally create a machine learning model that can be used to make predictions about our data.
In this file we also evaluate our predictions to see how accurate they are!
