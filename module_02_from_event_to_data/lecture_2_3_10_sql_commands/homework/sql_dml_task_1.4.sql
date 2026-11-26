DELETE
FROM
    public.products
WHERE
    product_id = (SELECT MAX(product_id) FROM products)
