WITH country_data AS (
    SELECT
        s.shop_id,
        s.address,
        c2.country_name
    FROM
        shops s
    LEFT JOIN cities c ON s.city_id = c.city_id
    LEFT JOIN countries c2 ON c.country_id = c2.country_id
    )
SELECT
    cd.country_name,
    e.shop_id,
    cd.address,
    COUNT(s.sales_id) AS total_sales_count,
    SUM(s.total_price) AS total_sales_amount
FROM
    sales s
LEFT JOIN employees e ON s.employee_id = e.employee_id
LEFT JOIN country_data cd ON e.shop_id = cd.shop_id
GROUP BY
    cd.country_name,
    e.shop_id,
    cd.address
HAVING 
    SUM(s.total_price) > 20000
ORDER BY 
    cd.country_name,
    total_sales_amount DESC
LIMIT 25