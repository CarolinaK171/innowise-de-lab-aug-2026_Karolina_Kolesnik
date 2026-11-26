SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    sum(s.total_price) AS total_income
FROM
    sales s
    JOIN employees e ON s.employee_id = e.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
HAVING 
    sum(s.total_price) > 500000
ORDER BY
    total_income DESC