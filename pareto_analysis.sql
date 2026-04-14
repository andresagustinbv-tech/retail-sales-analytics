-- pareto analysis
WITH customer_revenue AS (

SELECT
customer_id,
SUM(amount_usd) AS revenue
FROM sales_usd
WHERE amount_usd > 0
GROUP BY customer_id

),

ranked AS (

SELECT
customer_id,
revenue,
NTILE(10) OVER (ORDER BY revenue DESC) AS customer_decile
FROM customer_revenue

),

decile_revenue AS (

SELECT
customer_decile,
SUM(revenue) AS revenue
FROM ranked
GROUP BY customer_decile

)

SELECT
customer_decile,
revenue,
SUM(revenue) OVER (ORDER BY customer_decile) /
SUM(revenue) OVER () AS cumulative_revenue_percentage
FROM decile_revenue
ORDER BY customer_decile;
