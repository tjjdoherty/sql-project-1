-- Answers to questions

-- Question 1: Which cities and countries have the highest level of transaction revenues on the site?

SELECT * FROM all_sessions_clean WHERE totaltransactionrevenue IS NOT NULL
SELECT * FROM analytics_clean 

-- Question 2: What is the average number of products ordered from visitors in each city and country?

-- ordered quantity and SKU from sales_report, join all_sessions city country

----------
----------
----------

-- Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?

-- 

----------
----------
----------

-- Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?

----------
----------
----------

-- Question 5: Can we summarize the impact of revenue generated from each city/country?
