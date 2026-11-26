SELECT
	s.transaction_number,
	p.product_name,
	s.total_price,
	s.customer_id,
	s.sales_timestamp,
	p."class" 
FROM 
	sales s
LEFT JOIN products p ON s.product_id = p.product_id 
WHERE
	s.total_price > 1500 AND p."class" = 'A'
ORDER BY
	s.transaction_number;
