CREATE DATABASE raw_db;

SELECT datname FROM pg_database WHERE datistemplate = false;
