CREATE VIEW FullStatShops AS
SELECT
    s.shop_id,
    s.shop_address,
    c2.country_name AS country,
    COUNT(s2.sales_id) AS total_sales_count,
    SUM(s2.total_price) AS total_sales_amount
FROM
    sales s2
    LEFT JOIN employees e ON s2.employee_id = e.employee_id
    LEFT JOIN shops s ON e.shop_id = s.shop_id
    LEFT JOIN cities c ON s.city_id = c.city_id
    LEFT JOIN countries c2 ON c.country_id = c2.country_id
GROUP BY
    s.shop_id,
    s.shop_address,
    country
ORDER BY
    s.shop_id;

SELECT * FROM FullStatShops