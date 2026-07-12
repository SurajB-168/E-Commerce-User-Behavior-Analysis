-- =============================
-- E-COMMERECE USER EVENTS ANALYSIS
-- =============================

-- View Data
SELECT * FROM user_events;


-- =============================
-- USER DISTRIBUTION ANALYSIS
-- =============================

-- No of users by event_type
SELECT event_type, COUNT(DISTINCT user_id) AS users
FROM user_events
GROUP BY event_type
ORDER BY users DESC
;


-- =============================
-- TRAFFIC SOURCE ANALYSIS
-- =============================

-- No of users who visited page via different traffic source
SELECT traffic_source, event_type, COUNT(DISTINCT user_id) AS visited_users
FROM user_events
GROUP BY traffic_source, event_type
HAVING event_type = 'page_view'
ORDER BY traffic_source
;

-- No of users who actually purchased coming via different traffic source
SELECT traffic_source, event_type, COUNT(DISTINCT user_id) AS users_who_purchased
FROM user_events
GROUP BY traffic_source, event_type
HAVING event_type = 'purchase'
ORDER BY traffic_source
;


-- =============================
-- TRAFFIC SOURCE FUNNEL ANALYSIS
-- =============================

-- No of users at different event_type coming via different traffic source
SELECT traffic_source,
COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS page_view_count,
COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS add_to_cart_count,
COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS checkout_start_count,
COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS payment_info_count,
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase_count
FROM user_events
GROUP BY traffic_source
;


-- =============================
-- PAGE VIEW TO PURCHASE CONVERSION RATE
-- =============================

-- page_view TO purchase conversion rates for each traffic_source
SELECT page_view_counts.traffic_source, page_view_counts.visited_users, purchase_count.users_who_purchased, CONCAT(ROUND((users_who_purchased/visited_users)*100, 1), ' %') AS conversion_rates
FROM 
	(SELECT traffic_source, event_type, COUNT(DISTINCT user_id) AS visited_users
	FROM user_events
	GROUP BY traffic_source, event_type
	HAVING event_type = 'page_view'
	ORDER BY visited_users DESC) AS page_view_counts
JOIN 
	(SELECT traffic_source, event_type, COUNT(DISTINCT user_id) AS users_who_purchased
	FROM user_events
	GROUP BY traffic_source, event_type
	HAVING event_type = 'purchase'
	ORDER BY traffic_source) AS purchase_count
ON page_view_counts.traffic_source = purchase_count.traffic_source
;


-- =============================
-- STAGE WISE CONVERSION RATE ANALYSIS
-- =============================

-- Stage wise conversion rates by event_type
SELECT traffic_source,
CONCAT(ROUND((add_to_cart_count/page_view_count)*100, 2), ' %') AS view_TO_cart_CONVERSION_RATE,
CONCAT(ROUND((checkout_start_count/add_to_cart_count)*100, 2), ' %') AS cart_TO_checkout_CONVERSION_RATE,
CONCAT(ROUND((payment_info_count/checkout_start_count)*100, 2), ' %') AS checkout_TO_payment_CONVERSION_RATE,
CONCAT(ROUND((purchase_count/payment_info_count)*100, 2), ' %') AS payment_TO_purchase_CONVERSION_RATE
FROM
(SELECT traffic_source,
COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS page_view_count,
COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS add_to_cart_count,
COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS checkout_start_count,
COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS payment_info_count,
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase_count
FROM user_events
GROUP BY traffic_source) AS counts_table
;


-- =============================
-- PRODUCT PERFORMANCE ANALYSIS
-- =============================

-- Product wise analysis
SELECT product_id,
COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS viewed_page,
COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS added_to_cart,
COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS started_checkout,
COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS got_payment_info,
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchased
FROM user_events
GROUP BY product_id
;


-- =============================
-- PRODUCT WISE CONVERSION RATES
-- =============================

-- Conversion rates product wise
SELECT product_id,
CONCAT(ROUND((add_to_cart_count/page_view_count)*100, 2), ' %') AS view_TO_cart_CONVERSION_RATE,
CONCAT(ROUND((checkout_start_count/add_to_cart_count)*100, 2), ' %') AS cart_TO_checkout_CONVERSION_RATE,
CONCAT(ROUND((payment_info_count/checkout_start_count)*100, 2), ' %') AS checkout_TO_payment_CONVERSION_RATE,
CONCAT(ROUND((purchase_count/payment_info_count)*100, 2), ' %') AS payment_TO_purchase_CONVERSION_RATE
FROM
(SELECT product_id,
COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS page_view_count,
COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS add_to_cart_count,
COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS checkout_start_count,
COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS payment_info_count,
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase_count
FROM user_events
GROUP BY product_id) AS counts_table
;


-- =============================
-- PAGE VIEW TO PURCHASE CONVERSION BY PRODUCT
-- =============================

-- page_view to purchase conversion rate product id wise
SELECT product_id,
CONCAT(ROUND((purchase_count/page_view_count)*100, 2), ' %') AS page_view_TO_purchase_Cnversion_Rate
FROM
	(SELECT product_id,
	COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS page_view_count,
	COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase_count
	FROM user_events
	GROUP BY product_id) AS count_table
;


-- =============================
-- PRODUCT REVENUE ANALYSIS
-- =============================

-- Product wise revenue
SELECT product_id, SUM(amount) AS product_wise_revenue, CONCAT(ROUND((SUM(amount)/(SELECT SUM(amount) AS total_revenue FROM user_events)*100), 2), ' %') AS revenue_percentage
FROM user_events
GROUP BY product_id
;


-- =============================
-- TRAFFIC SOURCE REVENUE ANALYSIS
-- =============================

-- Traffic source wise revenue
SELECT traffic_source, SUM(amount) AS traffic_wise_revenue, CONCAT(ROUND((SUM(amount)/(SELECT SUM(amount) AS total_revenue FROM user_events)*100), 2), ' %') AS revenue_percentage
FROM user_events
GROUP BY traffic_source
ORDER BY traffic_source
;


-- =============================
-- TOTAL REVENUE SUMMARY
-- =============================

-- Total revenue
SELECT SUM(amount) AS total_revenue
FROM user_events
;


-- =============================
-- PURCHASED USER ANALYSIS
-- =============================

-- Users who completed the purchase process
SELECT user_id, product_id, event_type, event_date
FROM user_events
WHERE user_id IN
(SELECT user_id
FROM user_events
WHERE event_type = 'purchase') 
;


-- =============================
-- PURCHASE JOURNEY TIME ANALYSIS
-- =============================

-- Time taken to go from one step to the next
SELECT table1.user_id,
TIMESTAMPDIFF(MINUTE, table1.event_date, table2.event_date) AS page_view_TO_add_to_cart,
TIMESTAMPDIFF(MINUTE, table2.event_date, table3.event_date) AS add_to_cart_TO_checkout_start,
TIMESTAMPDIFF(MINUTE, table3.event_date, table4.event_date) AS checkout_start_TO_payment_info,
TIMESTAMPDIFF(MINUTE, table4.event_date, table5.event_date) AS payment_info_TO_purchase

FROM user_events AS table1
JOIN user_events AS table2
ON table1.user_id = table2.user_id AND table2.event_type = 'add_to_cart'
JOIN user_events AS table3
ON table1.user_id = table3.user_id AND table3.event_type = 'checkout_start'
JOIN user_events AS table4
ON table1.user_id = table4.user_id AND table4.event_type = 'payment_info'
JOIN user_events AS table5
ON table1.user_id = table5.user_id AND table5.event_type = 'purchase'
WHERE table1.event_type = 'page_view'
ORDER BY user_id
;


-- =============================
-- AVERAGE CUSTOMER JOURNEY TIME
-- =============================

-- Average time taken by users to go from one step to another
SELECT 
ROUND(AVG(TIMESTAMPDIFF(MINUTE, table1.event_date, table2.event_date)), 2) AS page_view_TO_add_to_cart,
ROUND(AVG(TIMESTAMPDIFF(MINUTE, table2.event_date, table3.event_date)), 2) AS add_to_cart_TO_checkout_start,
ROUND(AVG(TIMESTAMPDIFF(MINUTE, table3.event_date, table4.event_date)), 2) AS checkout_start_TO_payment_info,
ROUND(AVG(TIMESTAMPDIFF(MINUTE, table4.event_date, table5.event_date)), 2) AS payment_info_TO_purchase
FROM user_events AS table1
JOIN user_events AS table2
ON table1.user_id = table2.user_id AND table2.event_type = 'add_to_cart'
JOIN user_events AS table3
ON table1.user_id = table3.user_id AND table3.event_type = 'checkout_start'
JOIN user_events AS table4
ON table1.user_id = table4.user_id AND table4.event_type = 'payment_info'
JOIN user_events AS table5
ON table1.user_id = table5.user_id AND table5.event_type = 'purchase'
WHERE table1.event_type = 'page_view'
;
