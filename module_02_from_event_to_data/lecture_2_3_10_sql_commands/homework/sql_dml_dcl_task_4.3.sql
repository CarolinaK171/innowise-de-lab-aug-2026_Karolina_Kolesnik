BEGIN;

--Шаг 1. Добавляем нового сотрудника в таблицу employees
INSERT
    INTO
    public.employees
(
        employee_id,
        first_name,
        middle_initial,
        last_name,
        birth_date,
        gender,
        city_id,
        shop_id,
        hire_date
    )
SELECT
    MAX(employee_id) + 1,
        'John',
        'R',
        'Smith',
        '1975-06-25',
        'M',
        5,
        56,
        '2025-10-25'
FROM
    public.employees;

--Шаг 2. Добавляем продажу нового сотрудника в таблицу sales
INSERT
    INTO
    public.sales
(
        sales_id,
        employee_id,
        customer_id,
        product_id,
        quantity,
        discount,
        total_price,
        sales_timestamp,
        transaction_number
    )
SELECT
    MAX(sales_id) + 1, (
        SELECT
            max(e2.employee_id)
        FROM employees e2),
    99000,
    400,
    5,
    0.12,
    36.52,
    '2023-10-05 3:09:00',
    concat('T000', (MAX(sales_id) + 1)::text)
FROM
    public.sales;

COMMIT;

-- Проверяем исполнение транзакции
SELECT * FROM employees e ORDER BY employee_id DESC;

SELECT * FROM sales ORDER BY sales_id DESC;
