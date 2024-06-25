-- LOG OF DATA CLEANING OPERATIONS

-- I imported date as a varchar to avoid errors from potential bad data, then converted it to date to allow min, max calculations
	ALTER TABLE analytics ALTER COLUMN date TYPE date USING date::date;

SELECT visitnumber FROM analytics WHERE visitnumber !~ '^\d+$'

SELECT * FROM analytics WHERE socialengagementtype IS NOT NULL

-- need to change units_sold to a small integer
	ALTER TABLE analytics ALTER COLUMN units_sold TYPE smallint USING units_sold::smallint;

-- need to left trim whitespace from Product Name
	SELECT DISTINCT trim(name), sku FROM Products
		order by trim(name)

-- I copied the products table into a products_clean table for manipulation
CREATE TABLE products_clean as (SELECT * FROM products)
		
	
		
	-- UPDATE products SET name = trim(name)

-- May be beneficial to trim Home/ from product category as it is the top level domain of the website, not much analytical value

-- name the columns in lower case to make querying easier.

ALTER TABLE products RENAME COLUMN "SKU" TO sku;
	
SELECT * FROM products -- sku in products, product_sku in all_sessions

SELECT units_sold from analytics WHERE units_sold IS NOT NULL

