SELECT
	sales_id,
	p.product_name,
	s2.address
FROM
	sales s 
LEFT JOIN products p ON s.product_id = p.product_id
LEFT JOIN employees e ON s.employee_id = e.employee_id
LEFT JOIN shops s2 ON e.shop_id = s2.shop_id
LIMIT 10