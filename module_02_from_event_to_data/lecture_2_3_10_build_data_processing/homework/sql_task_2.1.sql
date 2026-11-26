SELECT 
	s.shop_id,
	s.address,
	c.city_name,
	c2.country_name
FROM
	shops s
LEFT JOIN cities c ON s.city_id = c.city_id
LEFT JOIN countries c2 ON c.country_id = c2.country_id
WHERE
	c2.country_name ILIKE '%poland%';