CREATE OR REPLACE PROCEDURE category_price_change (category_to_change varchar(50), price_change_percent numeric)
LANGUAGE plpgsql AS 
$$
BEGIN 
    UPDATE products
    SET price = ROUND((price * (1 + price_change_percent / 100.0)) :: numeric, 2)
    WHERE category_id = (SELECT c.category_id FROM categories c WHERE c.category_name = category_to_change); 
END;
$$

CALL category_price_change('Fruits', 10);