CREATE VIEW Peliculas_Info AS
SELECT 
    f.title AS Titulo,
    f.length AS Duracion,
    f.rating AS Clasificacion_Edades,
    l1.name AS Idioma_Original,
    l2.name AS Idioma_Doblado
FROM 
    film f
JOIN 
    language l1 ON f.original_language_id = l1.language_id
JOIN 
    language l2 ON f.language_id = l2.language_id;

select * from Peliculas_Info;

CREATE VIEW Alquileres_Info AS
SELECT 
    f.title AS Titulo_Pelicula,
    CONCAT(c.first_name, ' ', c.last_name) AS Nombre_Cliente,
    r.rental_date AS Fecha_Alquiler,
    r.return_date AS Fecha_Retorno,
    s.store_id AS ID_Tienda,
    a.address AS Direccion_Tienda,
    cty.city AS Ciudad
FROM 
    rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN store s ON i.store_id = s.store_id
    JOIN address a ON s.address_id = a.address_id
    JOIN city cty ON a.city_id = cty.city_id
WHERE 
    c.active = TRUE;
    

CREATE VIEW Clientes_Info AS
SELECT 
    customer_id AS ID_Cliente,
    CONCAT(first_name, ' ', LEFT(last_name, 1)) AS Nombre_Completo,
    email AS Email,
    active AS Activo
FROM 
    customer;
    
    CREATE VIEW Empleados_Info AS
SELECT 
    staff_id AS ID_Empleado,
    username AS Nombre_Usuario,
    email AS Email,
    password AS Password,
    active AS Activo
FROM 
    staff;
    
    
    select * from Clientes_info;
    select * from Empleados_info;
    
    
