WITH eg AS (
    SELECT 
        e.employee_id
    FROM 
        employees e
    JOIN shops s ON e.shop_id = s.shop_id
    JOIN cities c ON s.city_id = c.city_id
    JOIN countries co ON c.country_id = co.country_id
    WHERE 
        co.country_name = 'Germany'
)
SELECT
    DATE_TRUNC('month', NULLIF(s2.sales_timestamp, '')::TIMESTAMP) AS sale_month,
    SUM(s2.total_price) AS monthly_revenue,
    LAG(SUM(s2.total_price)) OVER () AS previous_month_revenue,
    SUM(s2.total_price) - LAG(SUM(s2.total_price)) OVER () AS revenue_diff_vs_previous
FROM
    sales s2
WHERE 
    s2.employee_id IN (
        SELECT 
            eg.employee_id
        FROM
            eg
        )
    AND 
    NULLIF(s2.sales_timestamp, '') IS NOT NULL
GROUP BY 
    DATE_TRUNC('month', NULLIF(s2.sales_timestamp, '')::TIMESTAMP)
ORDER BY
    sale_month
