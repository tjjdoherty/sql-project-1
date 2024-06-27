-- Identify inspect each column/features, identify null columns 
-- Assess if they are worth keeping given the business questions (see other file).

-- all_sessions - this is an annual report from August 1 2016 to 2017, the 4th Quarter May-July 2017 is also covered by the analytics entity

SELECT * FROM all_sessions -- 15134 rows

	-- fullvisitorid - all present (all 15134 rows appear in the query)
		SELECT * FROM all_sessions WHERE fullvisitorid IS NOT NULL

	-- channelgrouping - all present
		SELECT * FROM all_sessions WHERE channelgrouping IS NULL

	-- time - all present
		SELECT * FROM all_sessions WHERE time IS NULL

	-- country - all present, however there are 24 '(not set)' entries. Keep those records, they're small but maybe they have a city entry
		SELECT * FROM all_sessions
		WHERE country IS NOT NULL
			SELECT DISTINCT country FROM all_sessions -- (not set) is the only null-ish entry
		
			SELECT country, COUNT(country) FROM all_sessions
			GROUP BY country
			ORDER BY count(country) DESC

			-- are the country (not set) records also city (not set) - yes they are
			SELECT city, country FROM all_sessions WHERE country = '(not set)'
	
	-- city - all present, check for null-ish city entries
		SELECT * FROM all_sessions
		WHERE city IS NOT NULL
				SELECT DISTINCT city FROM all_sessions ORDER BY city 	
		
			-- (not set) appears again... San Francisco, SOUTH San Francisco (the same city?), 'not available in demo dataset' also appears
		
			SELECT city FROM all_sessions WHERE city IN ('not available in demo dataset', '(not set)')
			-- 8656 entries, over half of the city data is not available...
	
			-- Let's group by to see if there's messy entries for cities e.g. typos, grammar
			SELECT DISTINCT city, COUNT(city) FROM all_sessions -- 266 unique cities
			GROUP BY city
			ORDER BY COUNT(city) DESC
			
	
			-- CONCLUSION: we need this data because of its relevance to Q1 and other questions
			

	
	-- totaltransactionrevenue - only 81 records with this present 
		SELECT * FROM all_sessions WHERE totaltransactionrevenue IS NOT NULL
	
			-- CONCLUSION: we likely need this for its contribution to question 1 
			-- but they are very large numbers describing items in the tens of dollar range. divide by 1,000,000 when calculating?


	-- transactions - only 81 non-null records appear and all are 1, very likely to be the same 81 from t.t.r above. every single one of 81 is '1' and the rest null
		SELECT * FROM all_sessions WHERE transactions = '1'
	
			-- CONCLUSION: this is potentially useful for telling me if a purchase took place, and what other columns are also indicators of this

	-- timeonsite - 11834 rows present, keep for now
		SELECT * FROM all_sessions WHERE timeonsite IS NOT NULL
	
			-- is it seconds? MAX 4661, MIN 1, seems most sensible guess of the units
			SELECT MAX(timeonsite) FROM all_sessions

	-- pageviews - all present
		SELECT * FROM all_sessions WHERE pageviews IS NOT NULL

	-- sessionqualitydim - 1228 rows present, 988 are 1, 43 other unique non-null entries
		SELECT * FROM all_sessions WHERE sessionqualitydim 
	
			-- what is sessionqualitydim? 45 unique entries, unclear of its meaning
			SELECT DISTINCT sessionqualitydim FROM all_sessions
			
			-- CONCLUSION: junk feature, not enough context to see its meaning now

	-- date - all present and very likely to be of importance, ranges from 2016-08-01 to 2017-08-01
		SELECT * FROM all_sessions WHERE date IS NOT NULL
		SELECT MIN(date) FROM all_sessions
		SELECT MAX(date) FROM all_sessions

	-- visitid - all present, maybe important for identifying different user sessions vs visitorid, keep
		SELECT * FROM all_sessions WHERE visitid IS NOT NULL
	
			 -- 14556 DISTINCT visitid's - is this 14556 different visits to the website?
			SELECT distinct visitid FROM all_sessions WHERE visitid IS NOT NULL

	-- type - all present, either PAGE (14942) or EVENT (192) - maybe investigate further if more time what product 'events' are
		SELECT type, COUNT(type) FROM all_sessions
		GROUP BY type

	-- productrefundamount - ALL NULL, ignore / delete
		SELECT * FROM all_sessions WHERE productrefundamount IS NOT NULL

	-- productquantity - 53 non-null
		SELECT * FROM all_sessions WHERE productquantity IS NOT NULL

	-- productprice - all present, very large figures 1990000 for 1 oz Hand Sanitizer - divide by 1m to get $1.99 USD, this seems reasonable
		SELECT * FROM all_sessions WHERE productprice IS NOT NULL

	-- productrevenue - only 4 non-nulls, likely a junk feature
		SELECT * FROM all_sessions WHERE productrevenue IS NOT NULL
	
			-- why these four specifically? Spot check two of them to see if it has null and non-null productrevenue - they do
			SELECT distinct(productrevenue), v2productname FROM all_sessions
			WHERE v2productname IN ('Compact Bluetooth Speaker', 'Reusable Shopping Bag')
			
			-- CONCLUSION: there are four non-null productrevenue entries and those products have both null and non-null product revenues
			-- this makes it a junk feature, I can't tell anything concrete even from the 4 non-nulls

	-- product_sku - all present, no nulls
		SELECT * FROM all_sessions WHERE product_sku IS NOT NULL
			-- How many distinct product_skus? 536 total here. most are 'GGOE...'' but some are '918...'' and others '10 ...' 
			-- is there a special category of these 9s and 10s?
			SELECT DISTINCT(product_sku) FROM all_sessions ORDER BY product_sku
	
			-- CONCLUSION: Essential feature to uniquely identify and link foreign key to other entities

	-- v2productname - all present But a this should match up with SKUs, one product, one product_sku. Let's investigate
		SELECT * FROM all_sessions WHERE v2productname IS NOT NULL
	
			-- ISSUE: there are 471 unique productnames but 536 SKUs, so some products have multiple SKUs, potentially problematic
			SELECT DISTINCT v2productname FROM all_sessions
		
			-- let's group them with SKUs and see duplicates - 124 products with multiple SKUs
			SELECT v2productname, COUNT(DISTINCT product_sku) AS number_of_skus FROM all_sessions
			GROUP BY v2productname
			HAVING COUNT(DISTINCT product_sku) > 1
			ORDER BY number_of_skus DESC
		
			-- Spot check some of them to see a pattern in the dupes - many of the '918...' SKUs
			SELECT v2productname, product_sku FROM all_sessions
			WHERE v2productname IN ('Google Sunglasses', 'Google Men''s Long Sleeve Raglan Ocean Blue', 'Google Women''s V-Neck Tee Grey')
			GROUP BY v2productname, product_sku

			SELECT v2productname, productvariant FROM all_sessions WHERE productvariant IS NOT NULL AND productvariant != '(not set)'
	
			-- CONCLUSION: important column that we must keep. But, there are a number of dupes and many of them have the uncommon numerical product_skus.
			-- Ideally we would change these product_skus to the product's alphanumeric product_sku - one is likely the old SKU but its not clear which.
			-- Exploring product variant reveals that the multiple same product names have different colours or sizes e.g. RED/BLUE Google Sunglasses, MD Men's Tee

	-- v2productcategory - all present but 757 (not set)
		SELECT * FROM all_sessions WHERE v2productcategory IS NOT NULL
			-- how many categories? 74 appear from the below query, but it's messy and has lots of duplicates. COUNT queried to see the distribution
			SELECT v2productcategory, COUNT(v2productcategory) FROM all_sessions
			GROUP BY v2productcategory
			ORDER BY COUNT(v2productcategory) DESC

			-- CONCLUSION: important for the questions in the project and will be used, 
			-- Some trimming e.g. LTRIM "Home/" or trim to the last subdomain if we have time would be good

	-- productvariant - all present but 15094 of them are (not set) and the remaining are various size descriptions
		SELECT * FROM all_sessions WHERE productvariant != '(not set)'

			-- Reconciled this with V2productname where there are duplicates - this column differentiates dupe productnames e.g. Red/Blue sunglasses, MD/LG Men's Tee
			-- It is important but should be concatenated into v2productname and dropped in my opinion as this column is 99.8% empty

	-- currencycode - 14862 present, all USD, other 272 null. Low value because almost all transactions are USD
		SELECT * FROM all_sessions WHERE currencycode IS NOT NULL
			-- even foreign non-US are looking in USD, this is either irrelevant (all transactions in USD) or problematic so as to ignore it
			SELECT country, currencycode from all_sessions
			GROUP BY country, currencycode

	-- itemquantity - entirely null, ignore / delete
		SELECT * FROM all_sessions WHERE itemquantity IS NOT NULL;

	-- itemrevenue - entirely null, ignore / delete
		SELECT * FROM all_sessions WHERE itemrevenue IS NOT NULL;

	-- transactionrevenue - all but 4 records, the same records in productrevenue
		SELECT * FROM all_sessions WHERE transactionrevenue IS NOT NULL
			-- itemrevenue and transaction revenue both have the same 4 records, anything interesting?
			SELECT productrevenue, transactionrevenue FROM all_sessions
			WHERE transactionrevenue IS NOT NULL
			-- CONCLUSION: ignore this

	-- transactionid - 9 distinct non-null rows, ignore for now
		SELECT * FROM all_sessions WHERE transactionid IS NOT NULL

	-- pagetitle - all present besides 1
		SELECT * FROM all_sessions WHERE pagetitle IS NOT NULL
			-- can we use these to determine a purchase has been made? - Checkout confirmation
			SELECT DISTINCT pagetitle FROM all_sessions
			WHERE pagetitle LIKE '%Confirm%'
			OR pagetitle LIKE '%Checkout%'
			-- how many fields have Checkout Confirmation? - 9 in total, all /ordercompleted.html, check out pagepathlevel 1 below
			SELECT * FROM all_sessions WHERE pagetitle = 'Checkout Confirmation'

	
	-- searchkeyword - all absent, ignore
		SELECT * FROM all_sessions WHERE searchkeyword IS NOT NULL

	-- pagepathlevel1 - all present with some indicators of a checkout occurring
		SELECT * FROM all_sessions WHERE pagepathlevel1 IS NOT NULL
			-- on exploration most say google redesign, are they all like this? all but 816 are and they point to store, asearch...nothing interesting
			SELECT * FROM all_sessions
			WHERE pagepathlevel1 != '/google+redesign/'

			-- from transactionrevenue earlier, pagepathlevel1 reveals order completed for 9 entries:
			SELECT * FROM all_sessions WHERE pagepathlevel1 = '/ordercompleted.html'
			
	
			-- CONCLUSION: keep for its ability to point out confirmed orders

	-- ecommerceaction_type -- all present
		SELECT * FROM all_sessions
		WHERE ecommerceaction_type IS NOT NULL
			-- these small integer values appear to represent stages in the checkout journey 0 - 6
			SELECT DISTINCT ecommerceaction_type FROM all_sessions

			-- see above - looks likely that ecommerceaction_type 6 means a checkout happened - just 9 fields
			SELECT pagepathlevel1, pagetitle FROM all_sessions WHERE ecommerceaction_type = 6; -- all have pagetitle = checkout confirmation
			SELECT pagepathlevel1, pagetitle FROM all_sessions WHERE ecommerceaction_type = 5; -- 31 records, Checkout review/Your Info / Payment Method
			SELECT pagepathlevel1, pagetitle FROM all_sessions WHERE ecommerceaction_type = 4; -- 1 record, pagepath is /basket, Pagetitle is Shopping Cart
			SELECT pagepathlevel1, pagetitle FROM all_sessions WHERE ecommerceaction_type = 3; -- 37 records record, pagepath is google+redesign (not useful), pagetitle is product name
			SELECT pagepathlevel1, pagetitle FROM all_sessions WHERE ecommerceaction_type = 2; -- 137 records, same as _type 3 above, search results and looking at products
			SELECT pagepathlevel1, pagetitle FROM all_sessions WHERE ecommerceaction_type = 1; -- 134 records, same as above

			-- CONCLUSION: this is useful because I can see people going to search, stages of the checkout process AND confirmed purchases with _type 6
	
	-- ecommerceaction_step - all present, 15134 rows
		SELECT * FROM all_sessions
		WHERE ecommerceaction_step IS NOT NULL
			SELECT DISTINCT ecommerceaction_step, COUNT(ecommerceaction_step) FROM all_sessions
			GROUP BY ecommerceaction_step
			SELECT * FROM all_sessions WHERE ecommerceaction_step = 3; -- 5 records all link to /revieworder, Checkout Review
			SELECT * FROM all_sessions WHERE ecommerceaction_step = 2; -- 13 records, all links to Payment Method in pagetitle
			SELECT * FROM all_sessions WHERE ecommerceaction_step = 1 -- 15116 rows

	-- ecommerceaction_option - 31 rows non-null and they appear to relate to finishing an order
		SELECT * FROM all_sessions
		WHERE ecommerceaction_option IS NOT NULL
			-- is there anything discernible from ecommerceaction_type and _option together?
			SELECT ecommerceaction_option, ecommerceaction_type, ecommerceaction_step
			FROM all_sessions
			WHERE ecommerceaction_option IS NOT NULL
			ORDER BY ecommerceaction_option			

			-- CONCLUSION: These three ecommerceaction columns at the end may be the most comprehensive way to tell if an order has taken place.
			-- it appears that ecommerceaction_steps 1, 2 and 3 are billing/shipping, payment and review respectively and could be matched elsewhere.
			-- it doesn't appear to show that the order is complete, only Review which is seen in pagetitle and pagepathlevel1
			-- therefore there's still a chance that the user has abandoned the cart.


-- analytics - 4,301,122 records (all present) and it is likely a quarterly report, given the 3 month date window May 1 - Aug 1, 2017

SELECT * FROM analytics

	-- visitnumber - all present, 222 unique values all small integers
		SELECT * FROM analytics WHERE visitnumber IS NOT NULL
		SELECT DISTINCT visitnumber FROM analytics ORDER BY visitnumber

	-- visitid - all present, 148642 unique values but almost every single one is equal to visitstarttime... keep it, but ignore visitstarttime
		SELECT * FROM analytics WHERE visitid IS NOT NULL
		SELECT DISTINCT visitid FROM analytics
		SELECT visitid, visitstarttime FROM analytics WHERE visitid = visitstarttime
		SELECT * FROM analytics WHERE visitid = visitstarttime


	-- visitstarttime - all present, 148853 uniques but ignore, see visitid above
		SELECT * FROM analytics WHERE visitstarttime IS NOT NULL

	-- date all present, min 2017-05-01 max 2017-08-01
		SELECT MIN(date) FROM analytics
		SELECT MAX(date) FROM analytics
		SELECT * FROM analytics WHERE date IS NOT NULL

	-- fullvisitorid - all present, 120018 uniques, 3896 of the fullvisitorid's in all_sessions are here
		SELECT * FROM analytics WHERE fullvisitorid IS NOT NULL
		SELECT DISTINCT fullvisitorid FROM analytics WHERE fullvisitorid IS NOT NULL
		SELECT DISTINCT anl.fullvisitorid FROM analytics anl JOIN all_sessions als ON als.fullvisitorid = anl.fullvisitorid

	-- userid - all empty, ignore.
		SELECT * FROM analytics WHERE userid IS NOT NULL

	-- channelgrouping - all present, 8 types e.g. referral, social, affiliate... good quality and interesting to source of commerce /purchases for marketing
		SELECT * FROM analytics WHERE channelgrouping IS NOT NULL
		SELECT DISTINCT channelgrouping FROM analytics

	-- socialengagementtype - all present, but all 'not socially engaged' - very little analytical value here, ignore
		SELECT * FROM analytics WHERE socialengagementtype IS NOT NULL
		SELECT DISTINCT socialengagementtype FROM analytics

	-- units_sold - 95147 records, 135 uniques including -89 in one record and 98 in another. This should be a smallint (change in other file)
		-- this way we can perform calculations e.g. sum of units_sold for a product_sku
		SELECT * FROM analytics WHERE units_sold IS NOT NULL
		SELECT DISTINCT units_sold FROM analytics
		SELECT MAX(units_sold) FROM analytics 

	-- pageviews - 72 nulls - steady small int range of values almost all present, keep but low priority
		SELECT * FROM analytics WHERE pageviews IS NOT NULL;
		SELECT DISTINCT pageviews FROM analytics

	-- timeonsite - 3.8 million present, almost unbroken record of number of seconds (assumption) spent on site up to a few thousand. keep, low value
		SELECT * FROM analytics WHERE timeonsite IS NOT NULL
		SELECT DISTINCT timeonsite FROM analytics
		SELECT MAX (timeonsite) FROM analytics

	-- bounces - 474839 present, literally just measuring whether a marketing bounce occurred, where the user doesn't engage further. What page is that happening on?
		SELECT * FROM analytics WHERE bounces IS NOT NULL
		SELECT DISTINCT bounces FROM analytics


	-- revenue - 15355 records present - entirely numerical, should be numeric and divided by 1m like other money columns
			-- every single revenue non-null record has units_sold
		SELECT * FROM analytics WHERE revenue IS NOT NULL
		SELECT * FROM analytics WHERE revenue IS NOT NULL AND units_sold IS NOT NULL
		SELECT revenue FROM analytics WHERE revenue ~ '^[0-9]+' 

	-- unitprice - all present
		SELECT * FROM analytics WHERE unit_price IS NOT NULL


-- products - 1092 entries, 

SELECT * FROM products

	-- sku all present, all unique. Made the primary key
		SELECT * FROM products WHERE sku IS NOT NULL
		SELECT sku, trim(name) FROM products
		ORDER BY trim(name)
			-- cross-reference with all_sessions.product_sku, there is are no disagreeing SKUs on the same item between entities,
			-- BUT some products do have multiple SKUs in both entities
				SELECT DISTINCT trim(name) as trim_name, p.sku, als.product_sku FROM products p
				JOIN all_sessions als ON p.sku = als.product_sku
				ORDER BY trim(name)
					--How many products have multiple SKUs? There are 90 products with at least 2 SKUs and 190 SKUs representing a product that already has a SKU
						SELECT 
								DISTINCT trim(name) as trim_name, 
								COUNT(DISTINCT p.sku) AS sku_count,
								SUM(COUNT(DISTINCT p.sku)) OVER (ORDER BY COUNT(DISTINCT p.sku) DESC) AS running_total
						FROM products p
						JOIN all_sessions als ON p.sku = als.product_sku
						GROUP BY trim(name)
						HAVING COUNT(DISTINCT p.sku) > 1
						ORDER BY sku_count DESC
					-- There are FIVE total SKUs for 'Sunglasses', four dupes, and four Men's Zip Hoodie, three dupes. Is this reasonable? 
					-- you could definitely have 5 different sunglasses styles recorded as separate SKUs and stored as "sunglasses" as name! Don't change it.

			-- How many unique products exist by their name only?
					SELECT name, trim(name) FROM products
					ORDER BY trim(name)
					SELECT DISTINCT trim(name) FROM products -- there are 309 unique product names in the entity

	-- name all present, but requires trimming e.g. leading whitespace and possibly trailing space
		SELECT * FROM products WHERE name IS NOT NULL

	-- orderedquantity - all present
		SELECT * FROM products WHERE orderedquantity IS NOT NULL
	
	-- stocklevel - all present
		SELECT * FROM products WHERE stocklevel IS NOT NULL

	-- restockingleadtime - all present, not of real interest initially
		SELECT * FROM products WHERE restockingleadtime IS NOT NULL

	-- sentimentscore - all but one present (1091)
		SELECT * FROM products WHERE sentimentscore IS NOT NULL

	-- sentimentmagnitude - all but one present
		SELECT * FROM products WHERE sentimentmagnitude IS NOT NULL


-- sales_by_sku 462 entries -- it's important we figure out how influential these duplicate SKUs are. Make a first pass with the GGOE... SKUs vs 918..SKUs

	SELECT * FROM sales_by_sku
	SELECT SUM(total_ordered) FROM sales_by_sku WHERE product_sku LIKE 'GGOE%'
	SELECT SUM(total_ordered) FROM sales_by_sku WHERE product_sku LIKE '918%'

	-- there are zero recorded orders from the 918... SKUs, We will ignore them.
	-- these 918... SKUs may be new items not released yet


-- sales_report - 454 entries. If this information agrees with sales_by_sku then we can just ignore sales_by_sku, it is duplicate information entirely

SELECT * FROM sales_report

	-- product_sku all 454 unique, primary key. All 454 Match a record in sales_by_sku, but there are 8 missing.
		SELECT sr.product_sku, sk.product_sku FROM sales_report sr
		JOIN sales_by_sku sk USING(product_SKU)
			-- I used a left outer join to find the missing 8 (WHERE clause below reveals the SKUs not in sales_report)
			SELECT sk.product_sku, sr.product_sku
			FROM sales_by_sku sk
			LEFT OUTER JOIN sales_report sr USING(product_sku)
			WHERE sr.product_sku IS NULL
			
			-- the missing 8 SKUs below account for 5 total ordered quantity, small enough to ignore
			SELECT product_sku, total_ordered
			FROM sales_by_sku
			WHERE product_sku IN ( '9184677', '9182779', '9182763', 'GGOEYAXR066128', '9182182', '9180753', '9184663', 'GGOEGALJ057912')
		

	-- does the total_ordered match the number in sales_by_sku? YES.
		SELECT DISTINCT sr.product_sku, sk.total_ordered as ordered_sk, sr.total_ordered as ordered_sr FROM sales_report sr
		JOIN sales_by_sku sk USING(total_ordered)
		WHERE sk.total_ordered != sr.total_ordered


-- FINAL CONCLUSIONS OF THE DATA INSPECTION

-- entities: 
-- sales_by_sku is extraneous data with the exception of 8 SKUs that account for only 5 individual item orders,
-- everything else it offers is accessed by sales_report

-- Questions: 
-- They revolve around the city and country data which is accessed by all_sessions, 
-- these would join to a product SKU which is accessible in sales_report

-- units_sold should be converted to a small_int and this is a useful measure of orders, linking fullvisitorid 
	-- (we could group units_sold by fullvisitorid and their country)

-- Trimming of the product name is a simple effective clean up