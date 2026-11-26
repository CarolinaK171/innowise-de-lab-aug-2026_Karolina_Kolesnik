
-- 8. Загрузка таблицы фактов (gold.fact_sales)
-- 8.1. Инкрементальная загрузка строк с sales_id до 1 000 000
BEGIN;

INSERT INTO gold.fact_sales (
    sales_id, date_key, customer_key, employee_key,
    product_key, category_key, shop_key, location_key,
    transaction_number, sales_timestamp, quantity,
    gross_amount, discount, total_price
)
SELECT 
    s.sales_id,
    to_char(s.sales_timestamp, 'YYYYMMDD')::int,
    dc.customer_key,
    de.employee_key,
    dp.product_key,
    dcat.category_key,
    ds.shop_key,
    dl.location_key,
    COALESCE(NULLIF(TRIM(s.transaction_number), ''), 'UNKNOWN'),
    s.sales_timestamp,
    s.quantity,
    ROUND(s.quantity * dp.price, 2) AS gross_amount,
    GREATEST(COALESCE(s.discount, 0), 0)::numeric(14, 2),
    LEAST(
        GREATEST(COALESCE(s.total_price, 0), 0),
        ROUND(s.quantity * dp.price, 2)
    )::numeric(14, 2)
FROM silver.silver_sales s
JOIN silver.silver_products sp ON sp.product_id  = s.product_id
JOIN gold.dim_customer     dc  ON dc.customer_id = s.customer_id
JOIN gold.dim_employee     de  ON de.employee_id = s.employee_id
JOIN gold.dim_product      dp  ON dp.product_id  = s.product_id 
                              AND (
                                  (s.sales_timestamp >= dp.valid_from_dt AND s.sales_timestamp < dp.valid_to_dt)
                                  OR (dp.valid_from_dt = (SELECT MIN(valid_from_dt) FROM gold.dim_product WHERE product_id = s.product_id) 
                                      AND s.sales_timestamp < dp.valid_from_dt)
                              )
JOIN gold.dim_category     dcat ON dcat.category_id = sp.category_id
JOIN gold.dim_shop         ds   ON ds.shop_id     = s.shop_id
JOIN gold.dim_location     dl   ON dl.city_id     = s.city_id
WHERE s.sales_id <= 1000000
  -- AND s.quantity > 0
  -- AND s.sales_timestamp IS NOT NULL
ON CONFLICT (sales_id) DO NOTHING;

COMMIT;


-- 8.2. Проверка количества строк в fact_sales после частичной загрузки
SELECT count(*)
FROM gold.fact_sales t;

SELECT count(*)
FROM silver.silver_sales;


-- 8.3. Полная загрузка всех строк для проверки идемподентности скрипта
BEGIN;

INSERT INTO gold.fact_sales (
    sales_id, date_key, customer_key, employee_key,
    product_key, category_key, shop_key, location_key,
    transaction_number, sales_timestamp, quantity,
    gross_amount, discount, total_price
)
SELECT 
    s.sales_id,
    to_char(s.sales_timestamp, 'YYYYMMDD')::int,
    dc.customer_key,
    de.employee_key,
    dp.product_key,
    dcat.category_key,
    ds.shop_key,
    dl.location_key,
    COALESCE(NULLIF(TRIM(s.transaction_number), ''), 'UNKNOWN'),
    s.sales_timestamp,
    s.quantity,
    ROUND(s.quantity * dp.price, 2) AS gross_amount,
    GREATEST(COALESCE(s.discount, 0), 0)::numeric(14, 2),
    LEAST(
        GREATEST(COALESCE(s.total_price, 0), 0),
        ROUND(s.quantity * dp.price, 2)
    )::numeric(14, 2)
FROM silver.silver_sales s
JOIN silver.silver_products sp ON sp.product_id  = s.product_id
JOIN gold.dim_customer     dc  ON dc.customer_id = s.customer_id
JOIN gold.dim_employee     de  ON de.employee_id = s.employee_id
JOIN gold.dim_product      dp  ON dp.product_id  = s.product_id 
                              AND (
                                  (s.sales_timestamp >= dp.valid_from_dt AND s.sales_timestamp < dp.valid_to_dt)
                                  OR (dp.valid_from_dt = (SELECT MIN(valid_from_dt) FROM gold.dim_product WHERE product_id = s.product_id) 
                                      AND s.sales_timestamp < dp.valid_from_dt)
                              )
JOIN gold.dim_category     dcat ON dcat.category_id = sp.category_id
JOIN gold.dim_shop         ds   ON ds.shop_id     = s.shop_id
JOIN gold.dim_location     dl   ON dl.city_id     = s.city_id
WHERE s.sales_id > (SELECT COALESCE(MAX(sales_id), 0) FROM gold.fact_sales)
  AND s.quantity > 0
  AND s.sales_timestamp IS NOT NULL
ON CONFLICT (sales_id) DO NOTHING;

COMMIT;


-- 8.4. Повторная проверка количества строк в fact_sales после повторной полной загрузки
SELECT count(sales_id)
FROM gold.fact_sales t;

SELECT count(sales_id)
FROM silver.silver_sales;
