-- duplicates
select Count(*) 
from(
SELECT Invoice_ID, product_id, COUNT(*) as duplicates
FROM sales_usd
WHERE amount_usd > 0
GROUP BY 1,2
HAVING duplicates > 1) as t;


-- cleaning duplicates
CREATE TABLE global_fashion_clean AS
SELECT *
FROM (
    SELECT d.*,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   invoice_Id, 
                   Product_Id, 
                   amount_usd 
               ORDER BY invoice_Id
           ) AS rn
    FROM sales_usd d
) t
WHERE rn = 1 OR amount_usd <= 0;

DROP TABLE sales_usd;

RENAME TABLE global_fashion_clean TO sales_usd;

-- nulls 
SELECT
  SUM(CASE WHEN Invoice_ID IS NULL THEN 1 ELSE 0 END) AS null_orders,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_products,
  SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
  SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date,
  SUM(CASE WHEN amount_usd IS NULL THEN 1 ELSE 0 END) AS null_sales
FROM sales_usd;

-- cheking format date
SELECT invoice_id, date
FROM sales_usd
WHERE date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}';

-- format text 
UPDATE sales_usd
SET payment_method = LOWER(TRIM(payment_method)),
	Transaction_Type = LOWER(TRIM(Transaction_Type));
   
-- cheking orders without customer
SELECT s.*
FROM sales_usd s 
LEFT JOIN customers c 
ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- cheking orders without products
SELECT s.*
FROM sales_usd s
LEFT JOIN products p
ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

-- range date
SELECT MIN(date), 
		MAX(date)
        FROM sales_usd;
        
-- customers duplicates
SELECT email,customer_id, COUNT(*)
FROM customers
GROUP BY email,customer_id
HAVING COUNT(*) > 1;


SELECT 
    invoice_id,
    invoice_total,
    SUM(amount_usd) as total_paid
FROM sales_usd
GROUP BY 1
HAVING total_paid != invoice_total;

-- sum empty string
SELECT
  SUM(customer_id = '') AS customer_empty,
  SUM(invoice_id = '') AS invoice_empty,
  SUM(Product_id= '') AS product_empty,
  SUM(transaction_type = '') AS transactiontype_empty,
  SUM(amount_usd = '') AS amount_empty
FROM sales_usd;




