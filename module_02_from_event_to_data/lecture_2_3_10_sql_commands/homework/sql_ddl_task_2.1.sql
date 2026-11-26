CREATE TABLE data_layers (
    layer_id serial PRIMARY KEY,
    layer_name varchar(50) UNIQUE NOT NULL,
    description text
    );

SELECT * FROM data_layers dl;
    
    

