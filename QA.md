What are your risk areas? Identify and describe them.

My main risk area is determining which data tables and columns can authoritatively say that a transaction took place. All of the business questions are concerned with transaction revenue (a sale has occurred), or the demographics of previous orders which is also a post-sale exploration. Therefore, being confident in which records were a genuine transaction is essential.


QA Process:
Describe your QA process and include the SQL queries used to execute it.

The file "column_data_inspection" in this repo has comprehensively worked through every column of the five raw data tables in this project with the appropriate SQL queries for QA and testing.

On a higher level, initial QA was to test every column of all five data entities for null, such as 		SELECT * FROM all_sessions WHERE transactions IS NOT NULL
Columns with almost all null values were grounds for deletion

There are only 81 fields in all_sessions with a non-null totaltransactionvolume and a corresponding non-null value in transactions, which appears to be a boolean null for no transaction and 1 for a transaction.
I noticed the ecommerceaction_type column which progresses through the ecommerce pipeline of products, to basket, to checkout, to order complete. The same is true of the pagetitle column. These columns were verified along with the transactions column to ensure these could be counted as transactions; all ecommerceactiontype 6 records had a corresponding pagetitle of "Checkout Confirmation" which aligned with transactions equal to 1.

In the all_sessions entity, there was confusion around multiple SKUs for apparently the same products such as "Sunglasses" and some apparel items. By exploring the productvariant column which was almost entirely NULL on first test, it became clear the column was actually for differentiating the productnames with these ambiguous products such as by colour and size. 

Trimming of product category names, which appeared to be taken from the URL of the website was tested as many (not set) and other null-ish records were counted before and after the clean. For example:
SELECT DISTINCT v2productname, v2productcategory FROM all_sessions
					WHERE v2productcategory IN ('(not set)', '${escCatTitle}');
In the correcponding all_sessions_clean table, the record count is lower for this query.
