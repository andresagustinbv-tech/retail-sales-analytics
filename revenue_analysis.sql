-- revenue total
SELECT  SUM(amount_usd) AS total_revenue,
		SUM(s.quantity * p.production_cost) as total_cost,
        SUM(amount_usd) - SUM(s.quantity * p.production_cost) AS total_profit
		FROM sales_usd s
        JOIN products p 
        ON s.product_id = p.product_id;
        
-- revenue per year
SELECT  YEAR(DATE) as year,
		SUM(amount_usd) as revenue,
		SUM(s.quantity * p.production_cost) as cost,
        SUM(amount_usd) - SUM(s.quantity * p.production_cost) AS profit
		FROM sales_usd s
        JOIN products p 
        ON s.product_id = p.product_id
        GROUP BY 1;
        
-- top 20 products
SELECT  s.product_id,
		SUM(s.amount_usd) as revenue,
		SUM(s.quantity * p.production_cost) as cost,
        SUM(s.amount_usd) - SUM(s.quantity * p.production_cost) AS profit
	    FROM sales_usd s
	    JOIN products p 
        ON s.product_id = p.product_id
        GROUP BY 1
        ORDER BY 4 DESC
        LIMIT 20;
        
 -- revenue stores
        SELECT  s.store_id,
		SUM(s.amount_usd) as revenue,
		SUM(s.quantity * p.production_cost) as cost,
        SUM(s.amount_usd) - SUM(s.quantity * p.production_cost) AS profit
		FROM sales_usd s
	    JOIN stores ss ON s.store_id = ss.store_id
        JOIN products p ON p.product_id = s.product_id
        GROUP BY s.store_id
        ORDER BY profit DESC;        
        
  -- revenue per month 
        SELECT  DATE_FORMAT(date, '%Y-%m-01') as year_monthh,
				SUM(s.amount_usd) as revenue,
				SUM(s.quantity * p.production_cost) as cost,
				SUM(s.amount_usd) - SUM(s.quantity * p.production_cost) AS profit
				FROM sales_usd s
				JOIN products p 
				ON s.product_id = p.product_id
                GROUP BY 1
                ORDER BY 1 ASC;

 -- revenue category         
	SELECT      p.category,
			    SUM(s.amount_usd) as revenue,
				SUM(s.quantity * p.production_cost) as cost,
				SUM(s.amount_usd) - SUM(s.quantity * p.production_cost) AS profit
				FROM sales_usd s
				JOIN products p 
				ON s.product_id = p.product_id
                GROUP BY 1 
                ORDER BY 4 DESC;
                
	 -- revenue sub_category         
	SELECT      p.sub_category,
			    SUM(s.amount_usd) as revenue,
				SUM(s.quantity * p.production_cost) as cost,
				SUM(s.amount_usd) - SUM(s.quantity * p.production_cost) AS profit
				FROM sales_usd s
				JOIN products p 
				ON s.product_id = p.product_id
                GROUP BY 1 
                ORDER BY 4 DESC;
                
                
ALTER TABLE sales_usd
ADD COLUMN category VARCHAR(40);

UPDATE sales_usd s
JOIN products p ON s.product_id = p.product_id
SET s.category = p.category;
	
--  percentage of total per month and year over month total
SELECT 
    YEAR(date) AS year,
    MONTH(date) AS month,
    category,
    SUM(amount_usd) AS sales_category,
    SUM(SUM(amount_usd)) OVER (PARTITION BY YEAR(date), MONTH(date)) AS sales_month,
    SUM(amount_usd) * 100.0 / SUM(SUM(amount_usd)) OVER (PARTITION BY YEAR(date), MONTH(date)) AS pctj
FROM sales_usd
WHERE category IN ('Feminine', 'Masculine', 'Children')
GROUP BY YEAR(date), MONTH(date), category
ORDER BY year, month, category;

-- percentage of total per year 
SELECT 
    YEAR(date) AS year,
    category,
    SUM(amount_usd) AS sales_category,
    SUM(SUM(amount_usd)) OVER (PARTITION BY YEAR(date)) AS sales_year,
    SUM(amount_usd) * 100.0 / SUM(SUM(amount_usd)) OVER (PARTITION BY YEAR(date)) AS pctj
FROM sales_usd
WHERE category IN ('Feminine', 'Masculine', 'Children')
GROUP BY YEAR(date), category
ORDER BY year, category;

--  percentage of total per year and month over total year
SELECT 
    YEAR(date) AS año,
    MONTH(date) AS mes,
    category,
    SUM(amount_usd) AS ventas_mes_categoria,
    SUM(SUM(amount_usd)) OVER (PARTITION BY YEAR(date)) AS ventas_año,
    SUM(amount_usd) * 100.0 / SUM(SUM(amount_usd)) OVER (PARTITION BY YEAR(date)) AS pctj_anual
FROM sales_usd
WHERE category IN ('Feminine', 'Masculine', 'Children')
GROUP BY YEAR(date), MONTH(date), category
ORDER BY año, mes, category;

-- percentage change over time: TOMA UN PERIODO COMO 0 Y EN FUNCION A ESO CALCULA COLUMNA CON CRECIMIENTO
SELECT  year_sale,
		category,
        (sales / FIRST_VALUE (sales) OVER (PARTITION BY category ORDER BY year_sale)-1)*100 as index_sales
		
FROM(
SELECT  YEAR(date) as year_sale,
		category,
        SUM(amount_usd) as sales
        FROM sales_usd
        WHERE category IN ('Feminine', 'Masculine', 'Children')
        GROUP BY 1,2) as a;

-- moving average taking into account current month and the previous 11 months

SELECT  
    date_month,
    ROUND(AVG(sales) OVER (ORDER BY date_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 2) AS avg_moving_sales,
    COUNT(sales) OVER (ORDER BY date_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS number_register
FROM (
    SELECT  
        DATE_FORMAT(date, '%Y-%m-01') AS date_month,
        SUM(amount_usd) AS sales
    FROM sales_usd
    WHERE category IN ('Feminine', 'Masculine', 'Children')
    GROUP BY DATE_FORMAT(date, '%Y-%m-01')
) AS a
ORDER BY date_month;

-- year to date
SELECT  
    DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
    SUM(amount_usd) AS sales_month,
    SUM(SUM(amount_usd)) OVER (PARTITION BY YEAR(date) ORDER BY DATE_FORMAT(date, '%Y-%m-01') 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS sales_ytd
FROM sales_usd
GROUP BY DATE_FORMAT(date, '%Y-%m-01'), YEAR(date)
ORDER BY sales_month;