Answer the following questions and provide the SQL queries used to find the answer.

    
**Question 1: Which cities and countries have the highest level of transaction revenues on the site?**


SQL Queries:

Which column should we use to determine if a transaction took place?

	SELECT * FROM all_sessions_clean WHERE totaltransactionrevenue IS NOT NULL -- 81 fields indicating a transaction took place
	SELECT * FROM all_sessions_clean WHERE transactionid IS NOT NULL -- 9 fields indicating a transaction took place
	SELECT * FROM all_sessions_clean WHERE transactions IS NOT NULL -- 81 fields, the same 81 with totaltransactionrevenue
	SELECT * FROM all_sessions_clean WHERE pagetitle = 'Checkout Confirmation' -- 9 fields, the same 9 with transactionid

		
	SELECT 	
			city, 
			country, 
			SUM(totaltransactionrevenue) AS total_transaction_revenue
	FROM all_sessions_clean 
	WHERE totaltransactionrevenue IS NOT NULL
	GROUP BY country, city
	ORDER BY SUM(totaltransactionrevenue) DESC;



Answer:

From this totaltransactionrevenue data, San Francisco USA has the highest level of transaction revenues. 
Sunnyvale, Atlanta, Palo Alto, New York are all in the top 10, Tel-Aviv Israel is the only non-US in top 10.
However nearly half of the revenue ($6,092 out of over $14,000) in this report does not have city data available, though it is in the USA.


**Question 2: What is the average number of products ordered from visitors in each city and country?**


SQL Queries:

-- General strategy: ordered quantity and SKU from sales_report, join all_sessions city country

		SELECT name, total_ordered FROM sales_report_clean ORDER BY total_ordered DESC
		SELECT * FROM all_sessions_clean
	
			-- Refer to column_cleaning_commands, I trust the products table more for comprehensive data on items ordered (below)
			
			SELECT 		sesh.country, 
						sesh.city, 
						ROUND(AVG(p.orderedquantity), 2) AS average_products_ordered
			FROM all_sessions_clean sesh
			JOIN products_clean p ON sesh.product_sku = p.sku
			WHERE sesh.transactions IS NOT NULL
			GROUP BY sesh.country, sesh.city
			ORDER BY ROUND(AVG(p.orderedquantity), 2) DESC;
	
			-- Below I am using the total_ordered from sales_report entity, a few less records
	
			SELECT 		sesh.country, 
						sesh.city, 
						ROUND(AVG(sc.total_ordered), 2) AS average_products_ordered
			FROM all_sessions_clean sesh
			JOIN sales_report_clean sc USING(product_sku)
			WHERE sesh.transactions IS NOT NULL
			GROUP BY sesh.country, sesh.city
			ORDER BY ROUND(AVG(sc.total_ordered), 2) DESC;



Answer: The average products ordered is highest in Seattle USA and Sydney Australia followed by Houston, Nashville, Palo Alto for the top 5. Using the products table the average number of products ordered in Sydney, Aus and Seattle, US is over 2,000 with the trailing 6 - 7 cities in the 1000s range. Both tables agree the average products ordered is highest in Seattle USA and Sydney Australia followed by Houston, Nashville, Palo Alto for the top 5.
Although sales_report has less records



**Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**


SQL Queries:

    -- Below is the number of different categories ordered from each city. 
			
           SELECT city, COUNT(DISTINCT v2productcategory) AS number_of_different_categories
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY city
			ORDER BY COUNT(DISTINCT v2productcategory) DESC
					
			-- Add country into the equation 
			
           SELECT country, city, COUNT(DISTINCT v2productcategory) AS number_of_different_categories
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY country, city
			ORDER BY COUNT(DISTINCT v2productcategory) DESC
					
			-- Which categories are the most popular by city and country? Nest products were the most popular taking 3 of the top four slots
			
           SELECT v2productcategory, city, country, COUNT(*) AS times_ordered
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY v2productcategory, city, country
			ORDER BY COUNT(*) DESC


Answer:

Most of the 81 confirmed transactions are US. San Francisco, New York and Mountain View (near SF) ordered the most different categories. All non-us confirmed transactions were just the one single category. Nest products were the most popular taking 3 of the top four slots


**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**


SQL Queries and Answer:

First let's find the top selling products
			SELECT v2productname, city, COUNT(*) AS number_of_orders
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY v2productname, city
			ORDER BY v2productname

		-- The above query is slightly difficult to see because of lots of slight permutations of product names, but the Nest products are very popular.
		-- two of the four non-US purchases were for Nest products (indoor security camera and Nest Smoke Alarm), the other two non-US orders were for Men's Henley shirts

		-- The below query ordered by city makes it easier to see the city's habits: San Francisco bought slightly more outdoor gear (sport bottle, waterproof backpack)
		-- Whereas New York was indoor and clothing (Men's Tees/clothing, Nest products)
					
			SELECT v2productname, city, COUNT(*) AS number_of_orders
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY v2productname, city
			ORDER BY city
					
		-- The below query is every product ordered by orderedquantity in the products table, it appears to have duplicates due to other SKUs but they are likely slight product variants
		-- E.g. red or green sunglasses, MD or XL tee (discovered in data cleaning)
		-- The table below doesn't bear much resemblance to the above queries but you can see, with the slight permutations of product names that Nest products are very popular
					
			SELECT DISTINCT(sesh.v2productname), p.orderedquantity 
			FROM products_clean p
			JOIN all_sessions_clean sesh ON p.sku = sesh.product_sku
			ORDER BY orderedquantity DESC




**Question 5: Can we summarize the impact of revenue generated from each city/country?**

SQL Queries and Answer:

The United states makes up the bulk of the revenue by virtue of almost all confirmed transactions via the transactions column in all_sessions
The totaltransactionrevenue field has a lot of missing data compared to the orderedquantity, so using the below query to find product_price and orderedquantity...

		SELECT DISTINCT(v2productname), productprice, orderedquantity
		FROM all_sessions_clean sesh
		JOIN products_clean p ON sesh.product_sku = p.sku
		WHERE v2productname LIKE '%Nest%' OR v2productname LIKE '%YouTube%' OR v2productname LIKE '%Google Men''s%' AND orderedquantity > 0
		ORDER BY productprice DESC

You can see that the Nest products are among the HIGHEST ticket items, and the MOST ordered.
Even though they are typically bought in low quantities (they are smoke alarms, security cameras etc) unlike the other highly ordered products like stickers

Using this query showing the products ordered by people in particular cities and their price:

		SELECT v2productname, city, productprice
		FROM all_sessions_clean
		WHERE transactions IS NOT NULL
		ORDER BY city
	
I would anticipate that the locations with more orders of Nest products like Palo Alto and New York are the highest contributors to revenue.

