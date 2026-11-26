CREATE SCHEMA IF NOT EXISTS silver;


CREATE TABLE silver.silver_categories (
    category_id serial,
    category_name varchar(50)
);


CREATE TABLE silver.silver_cities (
    city_id serial,
    city_name varchar(50),
    zipcode int,
    country_id int
);


CREATE TABLE silver.silver_countries (
    country_id serial,
    country_name varchar(50),
    country_code int
);


CREATE TABLE silver.silver_customers (
    customer_id serial,
    first_name varchar(50),
    middle_initial varchar(50),
    last_name varchar(50),
    city_id int,
    address varchar(50)
);


CREATE TABLE silver.silver_employees (
    employee_id serial,
    first_name varchar(50),
    middle_initial varchar(50),
    last_name varchar(50),
    birth_date date,
    gender varchar(50),
    city_id int,
    shop_id int,
    hire_date date
);


CREATE TABLE silver.silver_products (
    product_id serial,
    product_name varchar(50),
    price NUMERIC(10, 2),
    category_id int,
    "class" varchar(50),
    modify_timestamp timestamp,
    resistant bool,
    is_allergic bool,
    vitality_days int
);


CREATE TABLE silver.silver_shops (
    shop_id serial,
    city_id int,
    address varchar(50)
);


CREATE TABLE silver.silver_sales (
    sales_id serial,
    employee_id int,
    customer_id int,
    product_id int,
    quantity int,
    discount NUMERIC(10, 2),
    total_price NUMERIC(10, 2),
    sales_timestamp timestamp,
    transaction_number varchar(50)
);


ALTER TABLE silver.silver_sales
ADD city_id int,
ADD shop_id int;



