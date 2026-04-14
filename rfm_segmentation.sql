-- recency frequecy monetary

    WITH rfm_base AS (

SELECT
customer_id,
DATEDIFF((SELECT MAX(date) FROM sales_usd), MAX(date)) AS recency,
COUNT(DISTINCT invoice_id) AS frequency,
SUM(amount_usd) AS monetary
FROM sales_usd
GROUP BY customer_id

),

rfm_scores AS (

SELECT
customer_id,
recency,
frequency,
monetary,
NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
FROM rfm_base

),

rfm_segments AS (

SELECT
customer_id,

CASE
WHEN r_score = 5 AND f_score >=4 AND m_score >=4 THEN 'Champions'
WHEN r_score >=4 AND f_score >=3 THEN 'Loyal Customers'
WHEN r_score >=3 AND f_score >=3 THEN 'Potential Loyalists'
WHEN r_score <=2 AND f_score >=3 THEN 'At Risk'
WHEN r_score =1 THEN 'Lost Customers'
ELSE 'Others'
END AS segment

FROM rfm_scores

)

SELECT
segment,
COUNT(*) AS customers
FROM rfm_segments
GROUP BY segment
ORDER BY customers DESC;