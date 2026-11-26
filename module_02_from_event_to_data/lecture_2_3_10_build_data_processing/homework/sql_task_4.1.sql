SELECT 
    p.product_name,
    SUM(s.total_price) AS total_revenue,
    AVG(s.total_price) AS avs_sale
FROM
    sales s 
LEFT JOIN products p ON s.product_id = p.product_id
GROUP BY
    p.product_name
HAVING
    SUM(s.total_price) > 400000
ORDER BY
    total_revenue DESC
LIMIT 10;
