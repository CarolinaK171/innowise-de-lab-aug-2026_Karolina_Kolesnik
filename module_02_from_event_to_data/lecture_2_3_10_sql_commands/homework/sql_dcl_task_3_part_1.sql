CREATE USER trainee_alex WITH PASSWORD 'pg_de_access';
CREATE ROLE data_engineer_trainee;
GRANT SELECT ON sales TO data_engineer_trainee;
GRANT data_engineer_trainee TO trainee_alex;

GRANT INSERT, UPDATE ON sales TO data_engineer_trainee;
