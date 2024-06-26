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

	SELECT * FROM all_sessions_clean
	SELECT * FROM analytics_clean

-- Concatenate v2productname and productvariant to add the appropriate color, size e.g. Men's Tee XL, Google Sunglasses RED,
-- There are many product names that fit this pattern
	UPDATE all_sessions_clean 
		SET v2productname = CASE
								WHEN productvariant = '(not set)' THEN v2productname
								ELSE v2productname || ' ' || productvariant
							END;
	SELECT v2productname FROM all_sessions_clean WHERE productvariant IS NOT NULL AND productvariant != '(not set)'

	-- this has introduced some mess with 'Single Option Only' but I can just trim this out if it doesn't add value
	-- now we can drop the productvariant column
	ALTER TABLE all_sessions_clean DROP COLUMN productvariant;

	SELECT * FROM all_sessions
		
-- trim Home/ from v2 product category in all_sessions_clean, as it is the top level domain of the website, not much analytical value
	-- over 14300 records of 15000 total have 'Home/' in them so this will help us differentiate records
		
