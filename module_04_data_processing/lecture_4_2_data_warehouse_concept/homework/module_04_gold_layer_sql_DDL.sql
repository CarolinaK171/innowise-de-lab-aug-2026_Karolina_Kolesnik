-- Создание схемы для Gold-слоя DWH
CREATE SCHEMA IF NOT EXISTS gold;

-- 1. Измерение дат (dim_date)
CREATE TABLE gold.dim_date (
    date_key        INTEGER PRIMARY KEY, -- Формат YYYYMMDD
    full_date       DATE NOT NULL UNIQUE,
    day_of_week     INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    week_num        INTEGER NOT NULL CHECK (week_num BETWEEN 1 AND 53),
    month_num       INTEGER NOT NULL CHECK (month_num BETWEEN 1 AND 12),
    month_name      VARCHAR(15) NOT NULL,
    quarter_num     INTEGER NOT NULL CHECK (quarter_num BETWEEN 1 AND 4),
    year_num        INTEGER NOT NULL CHECK (year_num >= 1900)
);

-- 2. Измерение клиентов (dim_customer - SCD Type 1)
CREATE TABLE gold.dim_customer (
    customer_key    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     INTEGER NOT NULL UNIQUE, -- BK
    first_name      VARCHAR(100) NOT NULL,
    middle_initial  VARCHAR(10),
    last_name       VARCHAR(100) NOT NULL,
    address         VARCHAR(255) NOT NULL,
    city_name       VARCHAR(100) NOT NULL,
    zipcode         INTEGER CHECK (zipcode > 0),
    country_name    VARCHAR(100) NOT NULL
);

-- 3. Измерение сотрудников (dim_employee - SCD Type 1)
CREATE TABLE gold.dim_employee (
    employee_key    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id     INTEGER NOT NULL UNIQUE, -- BK
    first_name      VARCHAR(100) NOT NULL,
    middle_initial  VARCHAR(10),
    last_name       VARCHAR(100) NOT NULL,
    birth_date      DATE NOT NULL,
    gender          VARCHAR(20) NOT NULL,
    hire_date       DATE NOT NULL,
    shop_id         INTEGER NOT NULL,
    city_name       VARCHAR(100) NOT NULL,
    CHECK (hire_date > birth_date)
);

-- 4. Измерение товаров (dim_product - SCD Type 2)
CREATE TABLE gold.dim_product (
    product_key     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id      INTEGER NOT NULL, -- BK
    product_name    VARCHAR(255) NOT NULL,
    price           NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    class           VARCHAR(50) NOT NULL,
    resistant       BOOLEAN NOT NULL DEFAULT FALSE,
    is_allergic     BOOLEAN NOT NULL DEFAULT FALSE,
    vitality_days   INTEGER CHECK (vitality_days >= 0),
    valid_from_dt   TIMESTAMP NOT NULL,
    valid_to_dt     TIMESTAMP NOT NULL DEFAULT '9999-12-31',
    is_current      BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (valid_to_dt > valid_from_dt)
);

-- Индекс для гарантии уникальности текущей версии каждого продукта в таблице dim_product
CREATE UNIQUE INDEX ux_dim_product_current 
    ON gold.dim_product (product_id) 
    WHERE is_current;

-- 5. Измерение категорий (dim_category - SCD Type 1)
CREATE TABLE gold.dim_category (
    category_key    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id     INTEGER NOT NULL UNIQUE, -- BK
    category_name   VARCHAR(100) NOT NULL
);

-- 6. Измерение магазинов (dim_shop - SCD Type 1)
CREATE TABLE gold.dim_shop (
    shop_key        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shop_id         INTEGER NOT NULL UNIQUE, -- BK
    address         VARCHAR(255) NOT NULL,
    city_name       VARCHAR(100) NOT NULL,
    zipcode         INTEGER CHECK (zipcode > 0),
    country_name    VARCHAR(100) NOT NULL
);

-- 7. Измерение локаций (dim_location - SCD Type 1)
CREATE TABLE gold.dim_location (
    location_key    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_id         INTEGER NOT NULL UNIQUE, -- BK
    city_name       VARCHAR(100) NOT NULL,
    zipcode         INTEGER CHECK (zipcode > 0),
    country_id      INTEGER NOT NULL,        -- BK
    country_name    VARCHAR(100) NOT NULL,
    country_code    VARCHAR(10) NOT NULL
);

-- 8. Таблица фактов продаж (fact_sales)
CREATE TABLE gold.fact_sales (
    sales_key           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sales_id            INTEGER NOT NULL UNIQUE, -- BK
    date_key            INTEGER NOT NULL REFERENCES gold.dim_date(date_key),
    customer_key        INTEGER NOT NULL REFERENCES gold.dim_customer(customer_key),
    employee_key        INTEGER NOT NULL REFERENCES gold.dim_employee(employee_key),
    product_key         INTEGER NOT NULL REFERENCES gold.dim_product(product_key),
    category_key        INTEGER NOT NULL REFERENCES gold.dim_category(category_key),
    shop_key            INTEGER NOT NULL REFERENCES gold.dim_shop(shop_key),
    location_key        INTEGER NOT NULL REFERENCES gold.dim_location(location_key),
    transaction_number  VARCHAR(100) NOT NULL,
    sales_timestamp     TIMESTAMP NOT NULL,
    quantity            INTEGER NOT NULL CHECK (quantity > 0),
    gross_amount        NUMERIC(14, 2) NOT NULL CHECK (gross_amount >= 0),
    discount            NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (discount >= 0),
    total_price         NUMERIC(14, 2) NOT NULL CHECK (total_price >= 0),
    CHECK (total_price <= gross_amount)
);

-- Индексы по внешним ключам в таблице фактов для ускорения JOIN
CREATE INDEX idx_fact_sales_date_key     ON gold.fact_sales (date_key);
CREATE INDEX idx_fact_sales_customer_key ON gold.fact_sales (customer_key);
CREATE INDEX idx_fact_sales_employee_key ON gold.fact_sales (employee_key);
CREATE INDEX idx_fact_sales_product_key  ON gold.fact_sales (product_key);
CREATE INDEX idx_fact_sales_category_key ON gold.fact_sales (category_key);
CREATE INDEX idx_fact_sales_shop_key     ON gold.fact_sales (shop_key);
CREATE INDEX idx_fact_sales_location_key ON gold.fact_sales (location_key);
