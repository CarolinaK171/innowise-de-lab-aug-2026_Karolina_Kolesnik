BEGIN;

-- 1. Загрузка изменения дат (gold.dim_date)
WITH bounds AS (
    SELECT 
        COALESCE(MIN(sales_timestamp)::date, '2020-01-01'::date) AS min_dt,
        COALESCE(MAX(sales_timestamp)::date + INTERVAL '1 year', CURRENT_DATE + INTERVAL '1 year')::date AS max_dt
    FROM silver.silver_sales
),
dates AS (
    SELECT generate_series(min_dt, max_dt, '1 day'::interval)::date AS dt
    FROM bounds
)
INSERT INTO gold.dim_date (
    date_key, full_date, day_of_week, week_num, 
    month_num, month_name, quarter_num, year_num
)
SELECT 
    TO_CHAR(dt, 'YYYYMMDD')::integer AS date_key,
    dt AS full_date,
    EXTRACT(ISODOW FROM dt)::integer AS day_of_week,
    EXTRACT(WEEK FROM dt)::integer AS week_num,
    EXTRACT(MONTH FROM dt)::integer AS month_num,
    TRIM(TO_CHAR(dt, 'Month')) AS month_name,
    EXTRACT(QUARTER FROM dt)::integer AS quarter_num,
    EXTRACT(YEAR FROM dt)::integer AS year_num
FROM dates
ON CONFLICT (date_key) DO NOTHING;


-- 2. Загрузка категорий (gold.dim_category - SCD Type 1
INSERT INTO gold.dim_category (category_id, category_name)
SELECT 
    category_id,
    COALESCE(NULLIF(TRIM(category_name), ''), 'Unknown')
FROM silver.silver_categories
ON CONFLICT (category_id) DO UPDATE SET
    category_name = EXCLUDED.category_name
WHERE gold.dim_category.category_name IS DISTINCT FROM EXCLUDED.category_name;


-- 3. Загрузка локаций (gold.dim_location - SCD Type 1)
INSERT INTO gold.dim_location (
    city_id, city_name, zipcode, country_id, country_name, country_code
)
SELECT 
    ci.city_id,
    COALESCE(NULLIF(TRIM(ci.city_name), ''), 'Unknown'),
    CASE WHEN ci.zipcode > 0 THEN ci.zipcode ELSE NULL END, -- Соблюдение CHECK (zipcode > 0)
    COALESCE(co.country_id, -1),
    COALESCE(NULLIF(TRIM(co.country_name), ''), 'Unknown'),
    COALESCE(NULLIF(TRIM(co.country_code), ''), 'N/A')
FROM silver.silver_cities ci
LEFT JOIN silver.silver_countries co ON ci.country_id = co.country_id
ON CONFLICT (city_id) DO UPDATE SET
    city_name    = EXCLUDED.city_name,
    zipcode      = EXCLUDED.zipcode,
    country_id   = EXCLUDED.country_id,
    country_name = EXCLUDED.country_name,
    country_code = EXCLUDED.country_code
WHERE (gold.dim_location.city_name, gold.dim_location.zipcode, gold.dim_location.country_id, gold.dim_location.country_name, gold.dim_location.country_code)
   IS DISTINCT FROM (EXCLUDED.city_name, EXCLUDED.zipcode, EXCLUDED.country_id, EXCLUDED.country_name, EXCLUDED.country_code);


-- 4. Загрузка магазинов (gold.dim_shop - SCD Type 1)
INSERT INTO gold.dim_shop (
    shop_id, address, city_name, zipcode, country_name
)
SELECT 
    s.shop_id,
    COALESCE(NULLIF(TRIM(s.address), ''), 'Unknown'),
    COALESCE(NULLIF(TRIM(ci.city_name), ''), 'Unknown'),
    CASE WHEN ci.zipcode > 0 THEN ci.zipcode ELSE NULL END,
    COALESCE(NULLIF(TRIM(co.country_name), ''), 'Unknown')
FROM silver.silver_shops s
LEFT JOIN silver.silver_cities ci ON s.city_id = ci.city_id
LEFT JOIN silver.silver_countries co ON ci.country_id = co.country_id
ON CONFLICT (shop_id) DO UPDATE SET
    address      = EXCLUDED.address,
    city_name    = EXCLUDED.city_name,
    zipcode      = EXCLUDED.zipcode,
    country_name = EXCLUDED.country_name
WHERE (gold.dim_shop.address, gold.dim_shop.city_name, gold.dim_shop.zipcode, gold.dim_shop.country_name)
   IS DISTINCT FROM (EXCLUDED.address, EXCLUDED.city_name, EXCLUDED.zipcode, EXCLUDED.country_name);


-- 5. Загрузка клиентов (gold.dim_customer - SCD Type 1)
INSERT INTO gold.dim_customer (
    customer_id, first_name, middle_initial, last_name, 
    address, city_name, zipcode, country_name
)
SELECT 
    c.customer_id,
    COALESCE(NULLIF(TRIM(c.first_name), ''), 'Unknown'),
    NULLIF(TRIM(c.middle_initial), ''),
    COALESCE(NULLIF(TRIM(c.last_name), ''), 'Unknown'),
    COALESCE(NULLIF(TRIM(c.address), ''), 'Unknown'),
    COALESCE(NULLIF(TRIM(ci.city_name), ''), 'Unknown'),
    CASE WHEN ci.zipcode > 0 THEN ci.zipcode ELSE NULL END,
    COALESCE(NULLIF(TRIM(co.country_name), ''), 'Unknown')
FROM silver.silver_customers c
LEFT JOIN silver.silver_cities ci ON c.city_id = ci.city_id
LEFT JOIN silver.silver_countries co ON ci.country_id = co.country_id
ON CONFLICT (customer_id) DO UPDATE SET
    first_name     = EXCLUDED.first_name,
    middle_initial = EXCLUDED.middle_initial,
    last_name      = EXCLUDED.last_name,
    address        = EXCLUDED.address,
    city_name      = EXCLUDED.city_name,
    zipcode        = EXCLUDED.zipcode,
    country_name   = EXCLUDED.country_name
WHERE (gold.dim_customer.first_name, gold.dim_customer.middle_initial, gold.dim_customer.last_name, gold.dim_customer.address, gold.dim_customer.city_name, gold.dim_customer.zipcode, gold.dim_customer.country_name)
   IS DISTINCT FROM (EXCLUDED.first_name, EXCLUDED.middle_initial, EXCLUDED.last_name, EXCLUDED.address, EXCLUDED.city_name, EXCLUDED.zipcode, EXCLUDED.country_name);


-- 6. Загрузка сотрудников (gold.dim_employee - SCD Type 1)
INSERT INTO gold.dim_employee (
    employee_id, first_name, middle_initial, last_name, 
    birth_date, gender, hire_date, shop_id, city_name
)
SELECT 
    e.employee_id,
    COALESCE(NULLIF(TRIM(e.first_name), ''), 'Unknown'),
    NULLIF(TRIM(e.middle_initial), ''),
    COALESCE(NULLIF(TRIM(e.last_name), ''), 'Unknown'),
    COALESCE(e.birth_date, '1970-01-01'::date),
    COALESCE(NULLIF(TRIM(e.gender), ''), 'Unknown'),
    -- Соблюдение CHECK (hire_date > birth_date)
    GREATEST(
        COALESCE(e.hire_date, '2000-01-01'::date), 
        (COALESCE(e.birth_date, '1970-01-01'::date) + INTERVAL '1 day')::date
    ),
    COALESCE(e.shop_id, -1),
    COALESCE(NULLIF(TRIM(ci.city_name), ''), 'Unknown')
FROM silver.silver_employees e
LEFT JOIN silver.silver_cities ci ON e.city_id = ci.city_id
ON CONFLICT (employee_id) DO UPDATE SET
    first_name     = EXCLUDED.first_name,
    middle_initial = EXCLUDED.middle_initial,
    last_name      = EXCLUDED.last_name,
    birth_date     = EXCLUDED.birth_date,
    gender         = EXCLUDED.gender,
    hire_date      = EXCLUDED.hire_date,
    shop_id        = EXCLUDED.shop_id,
    city_name      = EXCLUDED.city_name
WHERE (gold.dim_employee.first_name, gold.dim_employee.middle_initial, gold.dim_employee.last_name, gold.dim_employee.birth_date, gold.dim_employee.gender, gold.dim_employee.hire_date, gold.dim_employee.shop_id, gold.dim_employee.city_name)
   IS DISTINCT FROM (EXCLUDED.first_name, EXCLUDED.middle_initial, EXCLUDED.last_name, EXCLUDED.birth_date, EXCLUDED.gender, EXCLUDED.hire_date, EXCLUDED.shop_id, EXCLUDED.city_name);


-- 7. Загрузка товаров (gold.dim_product - SCD Type 2)
BEGIN;

UPDATE gold.dim_product d
SET valid_to_dt = now(),
    is_current  = false
FROM silver.silver_products s
WHERE d.product_id = s.product_id
  AND d.is_current
  AND (
      d.product_name, d.price, d."class",
      d.resistant, d.is_allergic, d.vitality_days
  ) IS DISTINCT FROM (
      s.product_name,
      s.price,
      s."class",
      s.resistant,
      s.is_allergic,
      s.vitality_days
      );

INSERT INTO gold.dim_product (
    product_id, product_name, price, class,
    resistant, is_allergic, vitality_days,
    valid_from_dt, valid_to_dt, is_current
)
SELECT 
    s.product_id,
    s.product_name,
    s.price,
    s."class",
    s.resistant,
    s.is_allergic,
    s.vitality_days,
    now(),
    '9999-12-31',
    true
FROM silver.silver_products s
WHERE NOT EXISTS (
    SELECT 1 
    FROM gold.dim_product d
    WHERE d.product_id = s.product_id 
      AND d.is_current
);

COMMIT;




/*COALESCE(NULLIF(TRIM(s.product_name), ''), 'Unknown'),
      GREATEST(COALESCE(s.price, 0), 0)::numeric(12, 2),
      COALESCE(NULLIF(TRIM(s.class), ''), 'Unknown'),
      COALESCE(s.resistant, false),
      COALESCE(s.is_allergic, false),
      CASE WHEN s.vitality_days >= 0 THEN s.vitality_days ELSE NULL END

/*COALESCE(NULLIF(TRIM(s.product_name), ''), 'Unknown'),
    GREATEST(COALESCE(s.price, 0), 0)::numeric(12, 2),
    COALESCE(NULLIF(TRIM(s.class), ''), 'Unknown'),
    COALESCE(s.resistant, false),
    COALESCE(s.is_allergic, false),
    CASE WHEN s.vitality_days >= 0 THEN s.vitality_days ELSE NULL END,


