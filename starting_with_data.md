Question 1: Is there a relationship between date / time of year and when certain orders were placed?

SQL Queries: 
  > SELECT visitid, DATE_TRUNC('quarter', date)::date AS quarter_date, v2productname, v2productcategory 
	FROM all_sessions_clean
	WHERE transactions IS NOT NULL
	ORDER BY DATE_TRUNC('quarter', date)::date

Answer: 		

In Q3 (Summer/Fall) 2016 sports bag, T shirts. In Q4 (Fall/Winter) hoodies were ordered, Nest camera. 
In Q1 (Winter/spring) 2017 LOTS of Nest products; outdoor security cameras, thermostats, smoke alarms. A lot more orders in general in Q1 2017
In Q2 (spring/summer) lots of Tees (T shirts) short sleeved, some more Nest products
In Q3 2017 just a few items including SPF-15 Lip balm (understandable as it's summer in July-August)

In summary, the colder months saw a lot more Nest electronic products which may have coincided with their release or just greater demand as people spend more time indoors in the Fall/Winter. Spring/Summer lots more summer clothing preparing for warmer weather.



Question 2: Analytics of channelgrouping - look at the visitid and channelgrouping, is there anything interesting about the products bought from different channels?

SQL Queries:  

  > SELECT * FROM analytics_clean
	SELECT * FROM all_sessions_clean
	
  > SELECT DISTINCT channelgrouping FROM analytics_clean

  > SELECT v2productname, v2productcategory, channelgrouping
	FROM all_sessions_clean
	WHERE transactions IS NOT NULL
	ORDER BY channelgrouping, v2productcategory

Answer:

The major transaction channels are Referral, Organic Search and Direct, with only 3 Paid Search in total, and zero Affiliates, Display or Social.
A lot of Nest products are purchased via Referral and Direct, but not Organic Search. This suggests that either trusted contacts (referral) or the brand themselves are leading to the purchase rather than users searching online and finding themselves buying a Nest product. Apparel seems evenly distributed between channels but a lot of Organic Search is Apparel. 



Question 3: Is this the same with general viewing of the website that did not necessarily convert? Are the other marketing channels present?


SQL Queries:

  > SELECT v2productname, an.channelgrouping, COUNT(*)
	FROM analytics_clean an
	JOIN all_sessions_clean sesh USING(visitid)
	GROUP BY an.channelgrouping, v2productname

Answer:

  Here we see the other channels that did not convert to transactions in all_sessions 
	Affiliates, many pages viewed were Android, Google and YouTube products. They didn't convert, so their affiliate marketing schemes may want to be revised
	The branded items feature heavily in general analytics
	Social seems to be a very very small channel, only six different products viewed via this channel



Question 4: Stock ratio - ratio in sales_report is total_ordered divided by stocklevel. Which products and product categories have the highest ratio?

SQL Queries:

  > SELECT DISTINCT(v2productname), v2productcategory, ratio 
	FROM sales_report_clean sr
	JOIN all_sessions_clean sesh USING(Product_sku)
	WHERE stocklevel > 0 AND total_ordered > 0
	ORDER BY ratio DESC

  The query shown below is for the higher ticket Nest products (most over $100 each), and shows their ratios are much lower, almost all below 0.05 with very large stocks
	This could be useful as a higher revenue item is more priority for stock space so they will want to avoid a low-stock situation
		
	SELECT DISTINCT(v2productname), total_ordered, ratio 
	FROM sales_report_clean sr
	JOIN all_sessions sesh USING(Product_sku)
	WHERE stocklevel > 0 AND total_ordered > 0 AND v2productname LIKE '%Nest%'
	ORDER BY ratio DESC

Answer: See above.

  
