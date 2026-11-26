--Этап 5. Ограничения / Constraints (SQL):
-- 5.1 Устанавливаем PRIMARY KEY, добавляем бизнес-констрейнтна таблицу employees (hire_date > birth_date)

ALTER TABLE silver.silver_categories
    ADD CONSTRAINT category_id_pk PRIMARY KEY (category_id);


ALTER TABLE silver.silver_cities 
    ADD CONSTRAINT city_id_pk PRIMARY KEY (city_id);


ALTER TABLE silver.silver_countries
    ADD CONSTRAINT country_id_pk PRIMARY KEY (country_id);


ALTER TABLE silver.silver_customers
    ADD CONSTRAINT customer_id_pk PRIMARY KEY (customer_id);


ALTER TABLE silver.silver_employees
    ADD CONSTRAINT employee_id_pk PRIMARY KEY (employee_id),
    ADD CONSTRAINT hire_birth_dates_check CHECK (hire_date > birth_date);


ALTER TABLE silver.silver_products
    ADD CONSTRAINT product_id_pk PRIMARY KEY (product_id);


ALTER TABLE silver.silver_shops
    ADD CONSTRAINT shop_id_pk PRIMARY KEY (shop_id);


ALTER TABLE silver.silver_sales
    ADD CONSTRAINT sales_id_pk PRIMARY KEY (sales_id);


-- 5.2 Устанавливаем FOREIGN KEY

ALTER TABLE silver.silver_cities 
    ADD CONSTRAINT country_id_fk FOREIGN KEY (country_id) REFERENCES silver.silver_countries (country_id);

ALTER TABLE silver.silver_customers
    ADD CONSTRAINT city_id_fk FOREIGN KEY (city_id) REFERENCES silver.silver_cities (city_id);


ALTER TABLE silver.silver_employees
    ADD CONSTRAINT city_id_fk FOREIGN KEY (city_id) REFERENCES silver.silver_cities (city_id),
    ADD CONSTRAINT shop_id_fk FOREIGN KEY (shop_id) REFERENCES silver.silver_shops (shop_id);


ALTER TABLE silver.silver_products
    ADD CONSTRAINT category_id_fk FOREIGN KEY (category_id) REFERENCES silver.silver_categories (category_id);


ALTER TABLE silver.silver_shops
    ADD CONSTRAINT city_id_fk FOREIGN KEY (city_id) REFERENCES silver.silver_cities (city_id);


ALTER TABLE silver.silver_sales
    ADD CONSTRAINT employee_id_fk FOREIGN KEY (employee_id) REFERENCES silver.silver_employees (employee_id),
    ADD CONSTRAINT customer_id_fk FOREIGN KEY (customer_id) REFERENCES silver.silver_customers (customer_id),
    ADD CONSTRAINT product_id_fk FOREIGN KEY (product_id) REFERENCES silver.silver_products (product_id),
    ADD CONSTRAINT city_id_fk FOREIGN KEY (city_id) REFERENCES silver.silver_cities (city_id),
    ADD CONSTRAINT shop_id_fk FOREIGN KEY (shop_id) REFERENCES silver.silver_shops (shop_id);

