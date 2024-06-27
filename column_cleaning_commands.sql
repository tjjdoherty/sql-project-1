-- LOG OF DATA CLEANING OPERATIONS

-- I imported date as a varchar to avoid errors from potential bad data, then converted it to date to allow min, max calculations
	ALTER TABLE analytics ALTER COLUMN date TYPE date USING date::date;

	SELECT visitnumber FROM analytics WHERE visitnumber !~ '^\d+$'

	SELECT * FROM analytics WHERE socialengagementtype = 'Not Socially Engaged'

-- name the columns in lower case to make querying easier.

	ALTER TABLE products RENAME COLUMN "SKU" TO sku;
			
-- need to change units_sold to a small integer, did this in the analytics table
	ALTER TABLE analytics ALTER COLUMN units_sold TYPE smallint USING units_sold::smallint;	
		
-- I copied the products table into a products_clean table for manipulation - preserve the products raw data table, clean the copy
	CREATE TABLE products_clean AS (SELECT * FROM products);
		
-- In the products_clean table, I will trim whitespace from product name
	UPDATE products_clean SET name = trim(name);
	
	SELECT distinct(name) FROM products_clean -- there are only 309 distinct names of products now.
		order by name

-- I will create a _clean version of the other tables: all_sessions_clean, analytics_clean, sales_report_clean, sales_by_sku not needed (see column_data_inspection)
	CREATE TABLE all_sessions_clean AS (SELECT * FROM all_sessions);
	CREATE TABLE analytics_clean AS (SELECT * FROM analytics);
	CREATE TABLE sales_report_clean AS (SELECT * FROM sales_report);

-- DROP junk columns as identified in column_data_inspection
	ALTER TABLE all_sessions_clean DROP COLUMN sessionqualitydim;
	ALTER TABLE all_sessions_clean DROP COLUMN productrefundamount;
	ALTER TABLE all_sessions_clean DROP COLUMN itemquantity;
	ALTER TABLE all_sessions_clean DROP COLUMN itemrevenue;
	ALTER TABLE all_sessions_clean DROP COLUMN searchkeyword;
	ALTER TABLE analytics_clean DROP COLUMN userid;
	ALTER TABLE analytics_clean DROP COLUMN socialengagementtype;

	SELECT * FROM all_sessions_clean;
	SELECT * FROM analytics_clean;

-- Concatenate v2productname and productvariant to add the appropriate color, size e.g. Men's Tee XL, Google Sunglasses RED,
-- There are many product names that fit this pattern
	UPDATE all_sessions_clean 
		SET v2productname = CASE
								WHEN productvariant = '(not set)' THEN v2productname
								ELSE v2productname || ' ' || productvariant
							END;

	-- this has introduced some mess with 'Single Option Only' but I can just trim this out if it doesn't add value
	-- now we can drop the productvariant column
	ALTER TABLE all_sessions_clean DROP COLUMN productvariant;

	-- The productvariant column needed whitespace trimming before concatenation. A few instances where '  ' two whitespaces exist.
	-- I can use a REGEXP_replace for this:
		SELECT v2productname, REGEXP_REPLACE(v2productname, '\s{2,}', ' ', 'g') 
		FROM all_sessions_clean
		WHERE v2productname LIKE '%  %'
		-- here's the Update command to all_sessions_clean
			UPDATE all_sessions_clean
				SET v2productname = REGEXP_REPLACE(v2productname, '\s{2,}', ' ', 'g')

			-- QA - check for double whitespace in the table ensuring it's complete. The below query should have no records, zero. Checks out.
				SELECT v2productname FROM all_sessions_clean WHERE v2productname LIKE '%  %';

-- Clean up product category, firstly check what distinct categories there are
	SELECT DISTINCT(v2productcategory) FROM all_sessions_clean

	-- trim Home/ from v2 product category, as it is the top level domain of the website, not much analytical value
	
		-- over 14300 records of 15000 total have 'Home/' in them so this will help us differentiate record.
		-- check the query works with a SELECT statement first
			SELECT	v2productcategory,
					REPLACE(v2productcategory, 'Home/', '')
			FROM all_sessions_clean
	
				-- Now we update the column
				UPDATE all_sessions_clean
					SET v2productcategory = REPLACE(v2productcategory, 'Home/', '');
	
				-- We can also trim / off of the right hand side - no need for it. Test with SELECT statement first, then update.
					SELECT RTRIM(v2productcategory, '/') FROM all_sessions_clean
				UPDATE all_sessions_clean
					SET v2productcategory = RTRIM(v2productcategory, '/')

	-- YouTube and Waze are here, but so is Brands/YouTube and Shop by Brand/YouTube so let's remove these latter two, so it just has the brand name
	-- Test with a Select query, there are some entries with only 'Brands' and 'Shop by Brand', we need to replace with the / to avoid touching these.
		SELECT DISTINCT v2productcategory,
						REPLACE(v2productcategory, 'Shop by Brand/', ''),
						REPLACE(v2productcategory, 'Brands/', '')	
						
		FROM all_sessions_clean WHERE v2productcategory LIKE '%Brand%';

			-- Make the Updates
			UPDATE all_sessions_clean
				SET v2productcategory = REPLACE(v2productcategory, 'Shop by Brand/', '');

			UPDATE all_sessions_clean
				SET v2productcategory = REPLACE(v2productcategory, 'Brands/', '');

-- Cleaning of city and country. Maybe some cities and countries are erroneous? Remove the not set, not available etc...

	SELECT DISTINCT country, city FROM all_sessions_clean
	WHERE city NOT IN ('not available in demo dataset', '(not set)')
	ORDER BY country
	-- There are a number of instances of American cities in non-American countries e.g. Los Angeles -> Australia, Mountain View -> Japan
	-- let's find them, 6 records:
		SELECT country, city FROM all_sessions_clean
		WHERE city IN ('Mountain View', 'San Francisco', 'New York', 'Los Angeles') AND country != 'United States'
		
		-- we will change these six records to United States. IMO it is more plausible that the city, being more precise, is the correct data not the country.
		UPDATE all_sessions_clean
			SET country = 'United States'
			WHERE city IN ('Mountain View', 'San Francisco', 'New York', 'Los Angeles') AND country != 'United States'

-- Cleaning of transaction revenue, productprice unit cost etc...
	-- based on a judgement of item description vs the unit cost, dividing by 1,000,000 seems appropriate. 
	-- e.g. Google Rucksack would be $69.99, Gel Roller Pen $3.50
		SELECT 	v2productname,
				productprice,
				ROUND(productprice / 1000000, 2)
		FROM all_sessions_clean

		SELECT * FROM all_sessions_clean
		SELECT totaltransactionrevenue, productprice, productrevenue, transactionrevenue FROM all_sessions_clean

		-- First let's alter the table for productprice from bigint to numeric. Others were done on import via CSV
		ALTER TABLE all_sessions_clean
		ALTER COLUMN productprice TYPE NUMERIC(14,2)
		USING productprice::NUMERIC;

		-- Now update the columns,divide all not null by 1,000,000
		-- UPDATE all_sessions_clean
			-- SET productprice = ROUND(productprice / 1000000, 2)
