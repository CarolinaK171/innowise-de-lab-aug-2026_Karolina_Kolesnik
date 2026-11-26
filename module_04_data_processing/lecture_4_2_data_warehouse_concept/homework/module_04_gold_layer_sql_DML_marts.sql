--9. Cоздание схемы mart и проектирование Data Marts

--9.1. Cоздание схемы mart
CREATE SCHEMA IF NOT EXISTS mart;

--9.2. Витрина mart_daily_anomaly

CREATE OR REPLACE VIEW mart.mart_daily_anomaly AS
WITH daily AS (
    SELECT dd.full_date, dl.city_id, ds.shop_id, ds.address, ds.city_name, ds.country_name, sum(t.total_price) AS revenue
    FROM gold.fact_sales t
    JOIN gold.dim_date dd ON t.date_key = dd.date_key
    JOIN gold.dim_shop ds ON t.shop_key = ds.shop_key
    JOIN gold.dim_location dl ON t.location_key = dl.location_key
    GROUP BY dd.full_date, ds.shop_id, dl.city_id, ds.address, ds.city_name, ds.country_name
)
SELECT *,
    AVG(revenue) OVER w AS expected_revenue,
    revenue / NULLIF(AVG(revenue) OVER w, 0) - 1 AS uplift    
FROM daily
WINDOW w AS (PARTITION BY shop_id ORDER BY full_date ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING)
ORDER BY full_date, city_id, shop_id;


--9.3. Витрина mart_shop_daily

CREATE OR REPLACE VIEW mart.mart_shop_daily AS
WITH daily AS (
    SELECT dd.full_date, dl.city_id, ds.shop_id, ds.address, ds.city_name, ds.country_name, sum(t.total_price) AS revenue
    FROM gold.fact_sales t
    JOIN gold.dim_date dd ON t.date_key = dd.date_key
    JOIN gold.dim_shop ds ON t.shop_key = ds.shop_key
    JOIN gold.dim_location dl ON t.location_key = dl.location_key
    GROUP BY dd.full_date, ds.shop_id, dl.city_id, ds.address, ds.city_name, ds.country_name
)
SELECT *,
    SUM(revenue) OVER (PARTITION BY full_date, city_id) AS sum_daily_revenue_by_city,
    AVG(revenue) OVER (PARTITION BY full_date, city_id) AS avg_daily_revenue_by_city    
FROM daily
ORDER BY full_date, city_id, shop_id;


--9.4. Витрина mart_customer_behavior

CREATE OR REPLACE VIEW mart.mart_customer_behavior AS
WITH customer_data AS (
    SELECT t2.customer_key, max(dd.full_date) AS last_purchase_date, 
    (SELECT max(t1.sales_timestamp)::date FROM gold.fact_sales t1) - max(dd.full_date) AS last_purchase_days_count,
    count(t2.sales_id) AS number_of_purchases, sum(t2.total_price) AS total_revenue, avg(t2.total_price) AS avg_cheque 
    FROM gold.fact_sales t2
    JOIN gold.dim_date dd ON t2.date_key = dd.date_key
    JOIN gold.dim_customer dc ON t2.customer_key = dc.customer_key
    JOIN gold.dim_location dl ON dc.city_name = dl.city_name
    GROUP BY t2.customer_key
    ORDER BY t2.customer_key
)
SELECT cd.customer_key, dl.city_id, cd.last_purchase_date, cd.last_purchase_days_count, cd.number_of_purchases, cd.total_revenue, cd.avg_cheque, 
    CASE
        WHEN last_purchase_days_count <= 90 THEN 'Active'
        ELSE 'Inactive'
    END AS activity_status,
    CASE
        WHEN NTILE(3) OVER (ORDER BY total_revenue DESC) = 1 THEN 'High'
        WHEN NTILE(3) OVER (ORDER BY total_revenue DESC) = 3 THEN 'Low'
        ELSE 'Medium'
    END AS revenue_segment
FROM customer_data cd
JOIN gold.dim_customer dc ON cd.customer_key = dc.customer_key
JOIN gold.dim_location dl ON dc.city_name = dl.city_name
ORDER BY cd.customer_key, dl.city_id;


--9.5. Витрина mart_employee_performance

CREATE OR REPLACE VIEW mart.mart_employee_performance AS
WITH employees_data AS (
    SELECT de.employee_id, de.first_name, de.last_name, de.shop_id, dl.city_id, count(t2.sales_id) AS number_of_sales, sum(t2.total_price) AS total_revenue, avg(t2.total_price) AS avg_cheque
        FROM gold.fact_sales t2
        JOIN gold.dim_date dd ON t2.date_key = dd.date_key
        JOIN gold.dim_employee de ON t2.employee_key = de.employee_key
        JOIN gold.dim_location dl ON t2.location_key = dl.location_key
        GROUP BY de.employee_id, de.first_name, de.last_name, de.shop_id, dl.city_id
    )
SELECT employee_id, first_name, last_name, shop_id, city_id, number_of_sales, total_revenue, avg_cheque,
DENSE_RANK () OVER (ORDER BY total_revenue DESC) AS total_revenue_ranking
FROM employees_data
ORDER BY total_revenue_ranking;


--9.6. Витрина mart_product_seasonality

--DROP VIEW mart.mart_product_seasonality;

CREATE OR REPLACE VIEW mart.mart_product_seasonality AS
WITH categories_data AS (
    SELECT dd.full_date, dd.year_num, dd.month_num, dd.month_name, dl.city_id, dc.category_name, sum(t.total_price) AS monthly_revenue_by_category
        FROM gold.fact_sales t
        JOIN gold.dim_date dd ON t.date_key = dd.date_key
        JOIN gold.dim_category dc ON t.category_key = dc.category_key
        JOIN gold.dim_location dl ON t.location_key = dl.location_key
    GROUP BY dd.full_date, dd.year_num, dd.month_num, dd.month_name, dl.city_id, dc.category_name
)
SELECT full_date, month_name, year_num, city_id, category_name, monthly_revenue_by_category,
dense_rank() OVER (PARTITION BY year_num, month_name, city_id ORDER BY monthly_revenue_by_category DESC) AS monthly_revenue_ranking,
SUM(monthly_revenue_by_category) OVER (PARTITION BY city_id, category_name) AS total_revenue_by_category
FROM categories_data
ORDER BY year_num, month_num, city_id, monthly_revenue_ranking;


ORDER BY year_num, month_num, city_id, monthly_revenue_ranking;



