--5. Аналитические запросы c использованием Gold слоя данных

--5.1. Запрос для анализа топ 5 товаров в каждой категории по выручке, а также доли каждого товара в общей выручке категории

WITH product_data AS (
    SELECT dc.category_name, dp.product_name,
    SUM(t.total_price) AS product_total_revenue,
    SUM(SUM(t.total_price)) OVER (PARTITION BY dc.category_name) AS category_total_revenue,
    ROUND(SUM(t.total_price) / SUM(SUM(t.total_price)) OVER (PARTITION BY dc.category_name) * 100, 2) AS product_revenue_share,
    DENSE_RANK() OVER (PARTITION BY dc.category_name ORDER BY SUM(t.total_price) DESC) AS product_revenue_rank
    FROM gold.fact_sales t
    JOIN gold.dim_category dc ON t.category_key = dc.category_key
    JOIN gold.dim_product dp ON t.product_key = dp.product_key
    GROUP BY dc.category_name, dp.product_name
    ORDER BY dc.category_name, product_total_revenue DESC
)
SELECT *
FROM product_data
WHERE product_revenue_rank <= 5;


--5.2. Запрос для анализа результативности магазинов в рамках каждой страны и сети Ecomarket в целом по показателю выручки

SELECT ds.shop_id, ds.address, ds.city_name, ds.country_name,
SUM(t.total_price) AS shop_revenue,
SUM(SUM(t.total_price)) OVER (PARTITION BY ds.country_name) AS country_revenue,
SUM(SUM(t.total_price)) OVER () AS total_revenue,
ROUND(SUM(t.total_price) / SUM(SUM(t.total_price)) OVER (PARTITION BY ds.country_name) * 100, 2) AS share_in_country_revenue,
ROUND(SUM(t.total_price) / SUM(SUM(t.total_price)) OVER () * 100, 2) AS share_in_total_revenue
FROM gold.fact_sales t
JOIN gold.dim_shop ds ON t.shop_key = ds.shop_key
GROUP BY ds.shop_id, ds.address, ds.city_name, ds.country_name
ORDER BY shop_revenue DESC;


--5.3. Запрос для анализа динамики квартальной выручки магазинов (сравнениt с выручкой магазина предыдущего квартала)
WITH q_revenue AS (
    SELECT ds.shop_id, ds.address, ds.city_name, ds.country_name, dd.year_num, dd.quarter_num, 
    SUM(t.total_price) AS shop_quarter_revenue,
    LAG(SUM(t.total_price)) OVER (PARTITION BY ds.shop_id ORDER BY dd.year_num, dd.quarter_num) AS previous_quarter_revenue
    FROM gold.fact_sales t
    JOIN gold.dim_date dd ON t.date_key = dd.date_key
    JOIN gold.dim_shop ds ON t.shop_key = ds.shop_key
    GROUP BY ds.shop_id, ds.address, ds.city_name, ds.country_name, dd.year_num, dd.quarter_num
)
SELECT *,
ROUND((shop_quarter_revenue - previous_quarter_revenue) / previous_quarter_revenue * 100, 2) AS qoq_revenue_growth_pct
FROM q_revenue;


--5.4. Запрос для для анализа топ 5 продавцов по итогам каждого года по показателю выручки (с дополнительным расчетом
-- количества продаж и средним чеком по каждому продавцу)

WITH e_revenue AS (
    SELECT dd.year_num, de.employee_id, de.first_name, de.last_name,
    SUM(t.total_price) AS yearly_revenue_by_employee,
    DENSE_RANK() OVER (PARTITION BY dd.year_num ORDER BY SUM(t.total_price) DESC) AS rank_by_revenue,
    COUNT(t.sales_id) AS number_of_sales,
    AVG(t.total_price) AS avg_cheque
    FROM gold.fact_sales t
    JOIN gold.dim_date dd ON t.date_key = dd.date_key
    JOIN gold.dim_employee de ON t.employee_key = de.employee_key
    GROUP BY dd.year_num, de.employee_id, de.first_name, de.last_name
    ORDER BY dd.year_num, yearly_revenue_by_employee DESC
)
SELECT *
FROM e_revenue
WHERE rank_by_revenue <= 5;

