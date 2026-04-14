 -- basket analysis
    SELECT AVG(total_items)
      FROM(
        SELECT  invoice_id,
				SUM(Quantity) as total_items
			    FROM sales_usd
                GROUP BY 1) as t;
                
-- average order value 
    SELECT AVG(total_orders) as avg_order_value
    FROM(
    SELECT  invoice_id,
			SUM(amount_usd) as total_orders
            FROM sales_usd
            GROUP BY 1) as t;
            
-- total_orders
SELECT COUNT(DISTINCT invoice_id) as total_orders
FROM sales_usd;

-- total discount 
SELECT 
    SUM(unit_price * Quantity * discount) as total_discount
    FROM sales_usd;
    
-- returns analysis
SELECT SUM(CASE WHEN amount_usd < 0 THEN 1 ELSE 0 END) AS returns
FROM sales_usd;