# What issues will you address by cleaning the data?

Data cleaning initially was about identifying which features were important to the questions, which features could be used to infer more important information, and which features were not useful. I made minimal changes to the raw files (changing some data types after importing via csv) such as altering the date column to be date type. Otherwise, I created copy tables for my data cleaning and manipulation.

One major issue of the data was that the same products seemingly had multiple SKUs, as the primary key this was concerning. Using an almost entirely null feature, productvariant, I discovered a distinction in the products which I concatenated into the product name, allowing the productvariant column to be dropped from the cleaned table. Other issues of product name and variant was whitespace trimming, product category having redundant information e.g. 'Home/' to be trimmed

With the limited transaction data, getting the confirmed transactions was vital. Some instances of clearly incorrect country records were found e.g. Los Angeles, Australia and Mountain View, Japan. I took the view that the city was likely the true record and updated the country accordingly.

Another issue is the readability of transaction revenue features, which are all very large numbers that do not make sense with the ticket size (e.g. a backpack for 69000000 USD). Spot checking these, it because clear that dividing by 1,000,000 was appropriate.


# Queries:
## Below, provide the SQL queries you used to clean your data.

You can refer to column_cleaning_commands.sql for the entire log of cleanup queries to the raw files which I applied to copy tables (products_clean, all_sessions_clean).

Some examples of the SQL queries to concatenate product name and variant:

  > UPDATE all_sessions_clean 
		SET v2productname = CASE
								WHEN productvariant = '(not set)' THEN v2productname
								ELSE v2productname || ' ' || productvariant
							END;

Below is replacing double whitespaces with Regex:

  SELECT v2productname, REGEXP_REPLACE(v2productname, '\s{2,}', ' ', 'g') 
		FROM all_sessions_clean
		WHERE v2productname LIKE '%  %'

Removing extraneous top domains of the product category (which appears to be abstracted from the website URL):

  SELECT DISTINCT v2productcategory,
						REPLACE(v2productcategory, 'Shop by Brand/', ''),
						REPLACE(v2productcategory, 'Brands/', '')

Updating known product categories to remove some null-ish entries of popular database records:

  UPDATE all_sessions_clean
		SET v2productcategory = REPLACE(REPLACE(v2productcategory, '(not set)', 'Accessories/Sports & Fitness'), '${escCatTitle}', 'Accessories/Sports & Fitness')
		WHERE v2productname = 'Google Kick Ball';

Identifying erroneous countries based on city data:

  SELECT country, city FROM all_sessions_clean
		WHERE city IN ('Mountain View', 'San Francisco', 'New York', 'Los Angeles') AND country != 'United States'

Example of updating the total transaction revenue:

  UPDATE all_sessions_clean
			SET totaltransactionrevenue = ROUND(totaltransactionrevenue / 1000000, 2);
