-- purcharse frequency
SELECT AVG(orders)  as purcharse_frequency
   FROM(
     SELECT customer_id,
		    COUNT(DISTINCT invoice_id) as orders
        FROM sales_usd
        GROUP BY 1) as t;
        
-- total customers
SELECT COUNT(DISTINCT customer_id)
	   FROM sales_usd;
       
-- repeat customers 
SELECT COUNT(*) as repeat_customers
  FROM(
      SELECT customer_id,
		     COUNT(DISTINCT invoice_id) as orders
             FROM sales_usd
             GROUP BY 1
             HAVING COUNT(DISTINCT invoice_id) >1) as t;
             
-- repeat_rate
SELECT SUM(CASE WHEN orders >1 THEN 1 ELSE 0 END) / COUNT(*) AS repeat_rate
FROM(
    SELECT customer_id,
		   COUNT(DISTINCT invoice_id) as orders
           FROM sales_usd
           GROUP BY 1) as t;

 -- customer life time values
 SELECT customer_id,
		COUNT(DISTINCT invoice_id) as total_orders,
		SUM(amount_usd) as total_revenue,
        AVG(amount_usd) as avg_order_value,
        MIN(date) as first_purchase,
        MAX(date) as last_purchase
	FROM sales_usd
    GROUP BY 1
    ORDER BY 3 DESC;
           
-- average_customer_lifetime_value
SELECT AVG(customers_revenue) as avg_customer_lifetime_value
  FROM(
    SELECT  customer_id,
		    SUM(amount_usd) as customers_revenue 
            FROM sales_usd
            GROUP BY 1) as t;
            
-- top 20 customers
SELECT  customer_id,
		SUM(amount_usd) as customer_revenue
        FROM sales_usd
        GROUP BY 1 
        ORDER BY 2 DESC
        LIMIT 20;
        
-- repeat customers vs unique customers     
SELECT CASE WHEN orders_count = 1 THEN 'One_time_buyers' ELSE 'Repeat_buyers' END as customer_type,
		COUNT(*) as customers
FROM(        
SELECT  customer_id,
		COUNT(DISTINCT invoice_id) as orders_count
        FROM sales_usd
        GROUP BY 1) as t
        GROUP BY customer_type;
        
-- customer churn detection
WITH last_purchase AS (

SELECT
customer_id,
MAX(date) AS last_purchase
FROM sales_usd
WHERE amount_usd > 0
GROUP BY customer_id

),

customer_status AS (

SELECT
customer_id,

DATEDIFF('2025-03-31', last_purchase) AS days_inactive

FROM last_purchase

)

SELECT

CASE
WHEN days_inactive <= 30 THEN 'Active'
WHEN days_inactive <= 90 THEN 'At Risk'
ELSE 'Churned'
END AS customer_status,

COUNT(*) AS customers

FROM customer_status
GROUP BY customer_status;