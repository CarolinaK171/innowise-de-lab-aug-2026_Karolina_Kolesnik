CREATE OR REPLACE FUNCTION AvgSalesPerEmployee (employee_id_avg_sales int)
    RETURNS numeric
    AS $$
BEGIN2
    RETURN (
        SELECT
            avg(s.total_price)
        FROM
            sales s
        WHERE
            s.employee_id = employee_id_avg_sales);
END;
$$
LANGUAGE plpgsql;


SELECT AvgSalesPerEmployee(5);