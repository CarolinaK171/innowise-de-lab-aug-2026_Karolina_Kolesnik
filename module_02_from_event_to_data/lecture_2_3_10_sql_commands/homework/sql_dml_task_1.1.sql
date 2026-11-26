INSERT
    INTO
    public.products
(
        product_id,
        product_name,
        price,
        category_id,
        "class",
        modify_timestamp,
        resistant,
        is_allergic,
        vitality_days
    )
VALUES ((SELECT MAX(product_id) + 1 FROM products), 'Grapefruit Morocco', 27.05, 1, 'C', '2025-11-24 21:51:39', 'Yes', 'Yes', 85),
    ((SELECT MAX(product_id) + 2 FROM products), 'Tomatoes Spain #35', 22.05, 2, 'B', '2025-11-24 21:51:39', 'No', 'No', 60);
