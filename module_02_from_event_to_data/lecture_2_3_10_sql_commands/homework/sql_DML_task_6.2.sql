UPDATE products p
SET "class" = 'A'
WHERE p.category_id IN (
    SELECT
        p.category_id
    FROM
        sales s
        JOIN products p ON s.product_id = p.product_id
    GROUP BY
        p.category_id
    HAVING
        sum(s.total_price) > 10000000
    ORDER BY
        p.category_id
);


SELECT
    p.category_id,
    count(p.product_id) AS number_of_products,
    count(DISTINCT p."class")  AS number_of_classes
FROM products p
GROUP BY p.category_id
ORDER BY category_id;