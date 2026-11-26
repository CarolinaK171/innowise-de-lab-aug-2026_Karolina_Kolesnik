INSERT
    INTO
    public.sales
(sales_id,
    employee_id,
    customer_id,
    product_id,
    quantity,
    discount,
    total_price,
    sales_timestamp,
    transaction_number)
SELECT
    MAX(sales_id) + 1,
    223,
    68389,
    79,
    2,
    0.05,
    26.05,
    '2022-07-29 21:08:15',
    concat('T000',(MAX(sales_id) + 1)::text)
FROM public.sales;


UPDATE sales s
SET 
    product_id = 302
WHERE 
    s.sales_id = (SELECT MAX(s2.sales_id) FROM sales s2);