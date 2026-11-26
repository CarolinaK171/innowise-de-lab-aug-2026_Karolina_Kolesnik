SELECT 
    e.first_name, 
    e.last_name, 
    s2.address, 
    s.total_price AS max_amount 
FROM sales s
LEFT JOIN employees e ON s.employee_id = e.employee_id
LEFT JOIN shops s2 ON e.shop_id = s2.shop_id
WHERE s.total_price = (SELECT MAX(total_price) FROM sales);

        