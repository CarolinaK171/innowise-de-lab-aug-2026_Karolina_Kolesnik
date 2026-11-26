    UPDATE data_layers dl
    SET
        manager_email = v.new_email
    FROM (VALUES 
        (1, 'anna.smith@ecomarket.com'),
        (2, 'george.davis@ecomarket.com'),
        (3, 'tom.adams@ecomarket.com')
    ) AS v(target_id, new_email)
    WHERE dl.layer_id = v.target_id;
    
    SELECT * FROM data_layers dl;
    
    ALTER TABLE data_layers ADD CONSTRAINT unique_manager_email UNIQUE (manager_email);
    
    
    