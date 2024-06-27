-- Answers to questions

-- Question 1: Which cities and countries have the highest level of transaction revenues on the site?

	SELECT * FROM all_sessions_clean WHERE totaltransactionrevenue IS NOT NULL -- 81 fields indicating a transaction took place
	SELECT * FROM analytics_clean
	SELECT * FROM all_sessions_clean WHERE transactionid IS NOT NULL -- 9 fields indicating a transaction took place
	SELECT * FROM all_sessions_clean WHERE transactions IS NOT NULL -- 81 fields, the same 81 with totaltransactionrevenue
	SELECT * FROM all_sessions_clean WHERE pagetitle = 'Checkout Confirmation' -- 9 fields, the same 9 with transactionid

		-- I chose to use totaltransactionrevenue in answering this question
	SELECT 	
			city, 
			country, 
			SUM(totaltransactionrevenue) as total_transaction_revenue
	FROM all_sessions_clean 
	WHERE totaltransactionrevenue IS NOT NULL
	GROUP BY country, city
	ORDER BY SUM(totaltransactionrevenue) DESC;

	-- from this totaltransactionrevenue data, San Francisco USA has the highest level of transaction revenues. 
	-- Sunnyvale, Atlanta, Palo Alto, New York are all in the top 10, Tel-Aviv Israel is the only non-US in top 10.
	-- However nearly half of the revenue ($6,092 out of over $14,000) in this report does not have city data available, though it is in the USA.


-- Question 2: What is the average number of products ordered from visitors in each city and country?

-- General strategy: ordered quantity and SKU from sales_report, join all_sessions city country

	SELECT name, total_ordered FROM sales_report_clean ORDER BY total_ordered DESC
	SELECT * FROM all_sessions_clean

		-- refer to column_cleaning_commands, I trust the products table more for comprehensive data on items ordered (below)
		
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


	-- average products ordered is highest in Seattle USA and Sydney Australia in both methods of answering this question.


	-- I am concerned that transaction from Israel doesn't appear in the above query. Why not?
			SELECT * FROM all_sessions_clean WHERE product_sku = 'GGOENEBB079399'
			SELECT * FROM sales_report_clean WHERE product_sku = 'GGOENEBB079399'
			SELECT * FROM products_clean WHERE sku = 'GGOENEBB079399'

			-- the Israel order SKU doesn't seem to be in any of the tables...

	-- Final thoughts:
		
		-- the biggest problem here is that with sales_report_clean we have lots of ordered products but in all_sessions...
		-- there is simply no authoritative indicator that this number of products were ordered. Only 81 transactions can be verified in all_sessions
		
----------
----------
----------

-- Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?

		SELECT 		city,
					country,
					v2productcategory
		FROM all_sessions_clean 
		WHERE transactions IS NOT NULL
		group by v2productcategory

		SELECT v2productcategory, COUNT(DISTINCT city)
		FROM all_sessions_clean
		WHERE transactions IS NOT NULL
		GROUP BY
----------
----------
----------

-- Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?

----------
----------
----------

-- Question 5: Can we summarize the impact of revenue generated from each city/country?
