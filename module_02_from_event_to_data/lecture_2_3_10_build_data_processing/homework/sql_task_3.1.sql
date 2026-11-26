SELECT
    c.country_name,
    COUNT(*) AS shops_count
FROM
    countries c
LEFT JOIN cities c2 ON c.country_id = c2.country_id
LEFT JOIN shops s ON c2.city_id = s.city_id
GROUP BY
    c.country_name;