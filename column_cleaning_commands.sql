-- LOG OF DATA CLEANING OPERATIONS

-- I imported date as a varchar to avoid errors from potential bad data, then converted it to date to allow min, max calculations
	ALTER TABLE analytics ALTER COLUMN date TYPE date USING date::date;

	SELECT visitnumber FROM analytics WHERE visitnumber !~ '^\d+$'

	SELECT * FROM analytics WHERE socialengagementtype = 'Not Socially Engaged'

-- need to change units_sold to a small integer, did this in the analytics table
	ALTER TABLE analytics ALTER COLUMN units_sold TYPE smallint USING units_sold::smallint;	
		
-- I copied the products table into a products_clean table for manipulation - preserve the products raw data table, clean the copy
	CREATE TABLE products_clean AS (SELECT * FROM products)
		
-- In the products_clean table, I will trim whitespace from product name
	UPDATE products_clean SET name = trim(name);
	
	SELECT * FROM products_clean
		order by name

-- I will create a _clean version of the other tables: all_sessions_clean, analytics_clean, sales_report_clean, sales_by_sku not needed (see column_data_inspection)
	CREATE TABLE all_sessions_clean AS (SELECT * FROM all_sessions);
	CREATE TABLE analytics_clean AS (SELECT * FROM analytics);
	CREATE TABLE sales_report_clean AS (SELECT * FROM sales_report);
		
-- trim Home/ from v2 product category in all_sessions_clean, as it is the top level domain of the website, not much analytical value
	-- over 14300 records of 15000 total have 'Home/' in them so this will help us differentiate records
	SELECT v2productcategory FROM all_sessions_clean WHERE v2productcategory LIKE 'Home/%'

-- name the columns in lower case to make querying easier.

	ALTER TABLE products RENAME COLUMN "SKU" TO sku;
	
SELECT * FROM products -- sku in products, product_sku in all_sessions
