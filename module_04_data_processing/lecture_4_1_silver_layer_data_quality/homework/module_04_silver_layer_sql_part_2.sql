--Этап 3. SQL (Структурная гигиена и очистка)
--3.1 Удаление дублей (Employees)

DELETE FROM silver.silver_employees
WHERE employee_id IN ( WITH duplicates_employees AS (
            SELECT
                se.employee_id,
                se.first_name,
                se.middle_initial,
                se.last_name,
                se.shop_id,
                row_number() OVER (PARTITION BY se.first_name,
                    se.middle_initial,
                    se.last_name,
                    se.shop_id) AS row_duplicate_number
            FROM
                silver.silver_employees se
)
            SELECT
                de.employee_id
            FROM
                duplicates_employees de
            WHERE
                de.row_duplicate_number > 1);

--Проверяем, корректно ли был выполнен скрипт и удалены ли все дубли:

SELECT se.first_name,
       se.middle_initial,
       se.last_name,
       se.birth_date,
       se.shop_id,
       count(*) AS duplicates_number
FROM silver.silver_employees se
GROUP BY se.first_name,
         se.middle_initial,
         se.last_name,
         se.birth_date,
         se.shop_id
ORDER BY count(*) DESC;


--3.2 Обработка NULL: проверяем поле employee_id в таблицах silver_employees и silver.silver_sales на NULL, удаляем строки с NULL

SELECT *
FROM silver.silver_employees se
WHERE se.employee_id IS NULL;

SELECT *
FROM silver.silver_sales ss
WHERE ss.employee_id IS NULL;

-- Значения NULL в поле employee_id в таблицах silver_employees и silver.silver_sales не найдены

--3.3 Чистка "Сирот": проверяем наличие в таблице silver_employees сотрудников без продаж (через NOT EXISTS) и удаляем их, если такие сотрудники есть

DELETE FROM silver.silver_employees
WHERE employee_id IN (
        SELECT
            se.employee_id
        FROM
            silver.silver_employees se
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    silver.silver_sales ss
                WHERE
                    ss.employee_id = se.employee_id));

--Проверяем, корректно ли был выполнен скрипт и удалены ли все сотрудники без продаж:

SELECT
    se.employee_id
FROM
    silver.silver_employees se
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            silver.silver_sales ss
        WHERE
            ss.employee_id = se.employee_id);


--Этап 4. Обогащение данных / Enrichment (SQL):
--заполняем поля shop_id и city_id в таблице silver_sales данными из таблиц silver_employees (поле shop_id) и silver_shops (поле city_id)

UPDATE
    silver.silver_sales ss
SET
    shop_id = (
        SELECT
            se.shop_id
        FROM
            silver.silver_employees se
        WHERE
            se.employee_id = ss.employee_id);


UPDATE
    silver.silver_sales ss
SET
    city_id = (
        SELECT
            ss2.city_id
        FROM
            silver.silver_shops ss2
        WHERE
            ss2.shop_id = ss.shop_id);











