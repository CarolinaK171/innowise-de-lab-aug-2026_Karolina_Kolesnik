SELECT 
    *
FROM 
    products p
WHERE 
    is_allergic = 'Yes'
    AND 
    p.resistant = 'Yes'