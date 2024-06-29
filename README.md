# Final-Project-Transforming-and-Analyzing-Data-with-SQL

## Project/Goals
five data tables were provided related to an ecommerce website, with business questions asked that required exploration of the tables to answer. These questions were based on revenue generated from transactions, where customers were purchasing from, what they were purchasing and patterns therein. The data was a mix of an annual record of user sessions, sales reports, a very large repository of web analytics and a products table.

## Process
### I set out to find where the information was and found a mix of features across the columns, including ordered quantities in products, a boolean column of transactions taking place, transaction revenues, product names and categories and some other features.
### There was a lot of cleaning of product names, categories and indicators of a transaction taking place. There were several columns which were entirely null which were dropped, and I tried to work with the large messy analytics table to identify where products had been sold and not logged as a transaction.

## Results
I was able to The vast majority of confirmed transactions were based in the US in major metropolitan areas like San Francisco, Palo Alto and New York. Because of a small sample size of completed ransactions, I grouped them by regions e.g US West/Central/East and found that the West Coast states were significant contributors to revenue, at least in cases where city data was available. I found some patterns into popular products, some seasonality in their purchase and marketing channels through which purchases were made and channels that were less successful.

## Challenges 
The most serious challenge was the sheer lack of confirmed transactions and the difficulty in bridging the gap between confirmed transaction revenue and the number of products ordered. There were 81 confirmed transactions in over 15000 'user sessions' so attempts were made to identify where units had been sold and thus revenue had been generated from the web analytics data. There was data on the web page being viewed in the checkout process, where we could make an assumption at checkout review that a user would confirm and not abandon the cart. 
Ultimately, the products table indicates that tens of thousands of products have been sold but the confirmed transactions accounted for only around $14,000.

## Future Goals
I would like to dig further into the web analytics data which seems the most likely place to identify instances were products were sold without being logged as transaction revenue in a user session. In the analytics table, there are around 95000 records with non-null units_sold, and only 15000 records with non_null revenue which suggests to me some sales have not been logged - what else is going on with those 80,000 remaining rows with something sold? However, it is a very messy data set with over 4.3 million records compared to the 15,000 user sessions. It would need combing through for duplicate data before identifying recorded sales.
