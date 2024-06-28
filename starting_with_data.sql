-- Starting with Data

-- Q1 Is there a connection between date / time of year and when orders were placed?

	SELECT visitid, DATE_TRUNC('quarter', date)::date AS quarter_date, v2productname, v2productcategory 
	FROM all_sessions_clean
	WHERE transactions IS NOT NULL
	ORDER BY DATE_TRUNC('quarter', date)::date

		-- in Q3 (Summer/Fall) 2016 sports bag, T shirts, 
		-- in Q4 (Fall/Winter) hoodies were ordered, Nest camera, 
		-- in Q1 (Winter/spring) 2017 LOTS of Nest products; outdoor security cameras, thermostats, smoke alarms. A lot more orders in general in Q1 2017
		-- in Q2 (spring/summer) lots of Tees (T shirts) short sleeved, some more Nest products
		-- in Q3 2017 just a few items including SPF-15 Lip balm (understandable as it's summer in July-August)

-- Q2 Analytics of channelgrouping - look at the visitid and channelgrouping, is there anything interesting about the products bought from different channels?

	SELECT * FROM analytics_clean -- want to grab visitid, date, channelgrouping
	SELECT * FROM all_sessions -- visitid join, v2productcategory
	
	SELECT DISTINCT channelgrouping FROM analytics_clean -- Channels are: affiliates, Direct, Display, Organic Search, Paid Search, Referral, Social

	SELECT v2productname, v2productcategory, channelgrouping
	FROM all_sessions_clean
	WHERE transactions IS NOT NULL
	ORDER BY channelgrouping