CREATE TEMP TABLE temp_employees AS
SELECT
    e.*
FROM
    employees e
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            sales s
        WHERE
            s.employee_id = e.employee_id);


DELETE FROM employees e
WHERE e.employee_id IN (
        SELECT
            te.employee_id
        FROM
            temp_employees te);

SELECT
    *
FROM
    employees e
WHERE
    e.employee_id IN (
        SELECT
            te.employee_id
        FROM
            temp_employees te);


INSERT INTO employees
SELECT
    *
FROM
    temp_employees;


SELECT
    *
FROM
    employees e
ORDER BY e.employee_id DESC;


DROP TABLE temp_employees;




/*DELETE FROM employees e
WHERE e.employee_id IN (
        SELECT
            ens.employee_id
        FROM
            employees_with_no_sales ens);
*/


SELECT * FROM employees e
WHERE e.employee_id IN (
        SELECT
            ens.employee_id
        FROM
            employees_with_no_sales ens);

INSERT INTO employees
SELECT *
FROM employees_with_no_sales;

ROLLBACK;

SELECT * FROM employees e;
