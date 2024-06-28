-- Answers to questions

-- Question 1: Which cities and countries have the highest level of transaction revenues on the site?

	-- make a summary table? fullvisitorid, city, country, totaltransactionrevenue

	SELECT * FROM all_sessions_clean WHERE totaltransactionrevenue IS NOT NULL -- 81 fields indicating a transaction took place
	SELECT * FROM all_sessions_clean WHERE transactionid IS NOT NULL -- 9 fields indicating a transaction took place
	SELECT * FROM all_sessions_clean WHERE transactions IS NOT NULL -- 81 fields, the same 81 with totaltransactionrevenue
	SELECT * FROM all_sessions_clean WHERE pagetitle = 'Checkout Confirmation' -- 9 fields, the same 9 with transactionid

		-- I chose to use totaltransactionrevenue in answering this question
		
	SELECT 	
			city, 
			country, 
			SUM(totaltransactionrevenue) AS total_transaction_revenue
	FROM all_sessions_clean 
	WHERE totaltransactionrevenue IS NOT NULL
	GROUP BY country, city
	ORDER BY SUM(totaltransactionrevenue) DESC;

		-- from this totaltransactionrevenue data, San Francisco USA has the highest level of transaction revenues. 
		-- Sunnyvale, Atlanta, Palo Alto, New York are all in the top 10, Tel-Aviv Israel is the only non-US in top 10.
		-- However nearly half of the revenue ($6,092 out of over $14,000) in this report does not have city data available, though it is in the USA.


		-- IF MORE TIME: can we get more data with the pagetitle or ecommerceaction_step?
		SELECT totaltransactionrevenue, pagetitle, country FROM all_sessions_clean WHERE ecommerceaction_type = 5; 
			-- Above: Users are on Payment Method & Review, ASSUME THEY CONFIRMED?


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
	

		-- both tables agree the average products ordered is highest in Seattle USA and Sydney Australia followed by Houston, Nashville, Palo Alto for the top 5.

		-- I am concerned that transaction from Israel doesn't appear in the above query. Why not?
				SELECT * FROM all_sessions_clean WHERE product_sku = 'GGOENEBB079399'
				SELECT * FROM sales_report_clean WHERE product_sku = 'GGOENEBB079399'
				SELECT * FROM products_clean WHERE sku = 'GGOENEBB079399'
	
				-- the Israel order SKU doesn't seem to be in any of the tables...is other data missing?

		-- Final thoughts:
			
			-- the biggest problem here is that with products_clean we have lots of ordered products but in all_sessions...
			-- there is simply no authoritative indicator that this number of products were ordered. Only 81 transactions can be verified in all_sessions
			-- hence i tried to calculate revenues from units_sold in analytics
	
			-- we can use ecommerceaction_step 5 as proxies for purchasing - it represents the Checkout Review/Payment Method screens, we could assume they complete checkout
		
----------
----------
----------

-- Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?

			-- below is the number of different categories ordered from each city. Most of the 81 confirmed transactions are US so I started with city only.
			-- San Francisco, New York and Mountain View (near SF) ordered the most different categories
			SELECT city, COUNT(DISTINCT v2productcategory) AS number_of_different_categories
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY city
			ORDER BY COUNT(DISTINCT v2productcategory) DESC
					
			-- add country into the equation -- all non-us confirmed transactions were just the one single category
			SELECT country, city, COUNT(DISTINCT v2productcategory) AS number_of_different_categories
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY country, city
			ORDER BY COUNT(DISTINCT v2productcategory) DESC
					
			-- which categories are the most popular by city and country? Nest products were the most popular taking 3 of the top four slots
			SELECT v2productcategory, city, country, COUNT(*) AS times_ordered
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY v2productcategory, city, country
			ORDER BY COUNT(*) DESC
		

----------
----------
----------

-- Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?

		-- first let's find the top selling products
			SELECT v2productname, city, COUNT(*) AS number_of_orders
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY v2productname, city
			ORDER BY v2productname

		-- The above query is slightly difficult to see because of lots of slight permutations of product names, but the Nest products are very popular.
		-- two of the four non-US purchases were for Nest products (indoor security camera and Nest Smoke Alarm), the other two non-US orders were for Men's Henley shirts

		-- the below query ordered by city makes it easier to see the city's habits: San Francisco bought slightly more outdoor gear (sport bottle, waterproof backpack)
		-- whereas New York was indoor and clothing (Men's Tees/clothing, Nest products)
					
			SELECT v2productname, city, COUNT(*) AS number_of_orders
			FROM all_sessions_clean
			WHERE transactions IS NOT NULL
			GROUP BY v2productname, city
			ORDER BY city
					
		-- the below query is every product ordered by orderedquantity in the products table, it appears to have duplicates due to other SKUs but they are likely slight product variants
		-- e.g. red or green sunglasses, MD or XL tee (discovered in data cleaning)
		-- The table below doesn't bear much resemblance to the above queries but you can see, with the slight permutations of product names that Nest products are very popular
					
			SELECT DISTINCT(sesh.v2productname), p.orderedquantity 
			FROM products_clean p
			JOIN all_sessions_clean sesh ON p.sku = sesh.product_sku
			ORDER BY orderedquantity DESC


----------
----------
----------

-- Question 5: Can we summarize the impact of revenue generated from each city/country?

	-- The United states makes up the bulk of the revenue by virtue of almost all confirmed transactions via the transactions column in all_sessions
	-- The totaltransactionrevenue field has a lot of missing data compared to the orderedquantity, so using the below query to find product_price and orderedquantity...

		SELECT DISTINCT(v2productname), productprice, orderedquantity
		FROM all_sessions_clean sesh
		JOIN products_clean p ON sesh.product_sku = p.sku
		WHERE v2productname LIKE '%Nest%' OR v2productname LIKE '%YouTube%' OR v2productname LIKE '%Google Men''s%' AND orderedquantity > 0
		ORDER BY productprice DESC

	-- .. you can see that the Nest products are among the HIGHEST ticket items, and the MOST ordered.
	-- Even though they are typically bought in low quantities (they are smoke alarms, security cameras etc) unlike the other highly ordered products like stickers

	-- using this query showing the products ordered by people in particular cities and their price:

		SELECT v2productname, city, productprice
		FROM all_sessions_clean
		WHERE transactions IS NOT NULL
		ORDER BY city
	
	-- I would anticipate that the locations with more orders of Nest products like Palo Alto and New York are the highest contributors to revenue.