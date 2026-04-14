-- cohort analysis
WITH cohort AS (
SELECT
customer_id,
DATE_FORMAT(MIN(date),'%Y-%m-01') AS cohort_month
FROM sales_usd
GROUP BY customer_id

),

transactions AS (
SELECT
customer_id,
DATE_FORMAT(date,'%Y-%m-01') AS purchase_month
FROM sales_usd

),

cohort_table AS (

SELECT
c.cohort_month,
t.purchase_month,
TIMESTAMPDIFF(MONTH, c.cohort_month, t.purchase_month) AS cohort_index,
COUNT(DISTINCT t.customer_id) AS customers

FROM cohort c
JOIN transactions t
ON c.customer_id = t.customer_id

GROUP BY 1,2,3

),

cohort_size AS (
SELECT
cohort_month,
COUNT(DISTINCT customer_id) AS cohort_size
FROM cohort
GROUP BY cohort_month

)

SELECT
ct.cohort_month,
ct.cohort_index,
ct.customers,
cs.cohort_size,
ct.customers / cs.cohort_size AS retention_rate

FROM cohort_table ct
JOIN cohort_size cs
ON ct.cohort_month = cs.cohort_month

ORDER BY ct.cohort_month, ct.cohort_index;       
	
    
	
