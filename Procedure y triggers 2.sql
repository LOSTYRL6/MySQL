    CREATE TABLE log_staff (
    ID INT AUTO_INCREMENT,
    Accion ENUM('actualitzacio', 'esborrat'),
    Empleat INT,
    DataYHora DATETIME,
    EmailModificat BOOLEAN,
    PRIMARY KEY (ID),
    FOREIGN KEY (Empleat) REFERENCES staff(staff_id)
);
    ALTER TABLE customer
ADD COLUMN warnings SMALLINT;erroresdades_producte


DELIMITER //

CREATE TRIGGER encrypt_password_and_update_last_update
AFTER INSERT ON staff
FOR EACH ROW
BEGIN
    SET NEW.password = SHA1(NEW.password); 
    SET NEW.last_update = NOW();
END;
//

DELIMITER ;

INSERT INTO staff (staff_id,first_name, last_name, address_id, picture, email, store_id, active, username, password, last_update)
VALUES (3,'John', 'Doe', 1, NULL, 'john@example.com', 1, 1, 'johndoe', 'password123', NOW());

select * from staff















DELIMITER //

CREATE TRIGGER capitalize_actor_name_and_lastname
AFTER INSERT ON actor
FOR EACH ROW
BEGIN
    SET NEW.first_name = UPPER(TRIM(NEW.first_name)); 
    SET NEW.last_name = UPPER(TRIM(NEW.last_name)); 
END;
//

DELIMITER ;
INSERT INTO actor (actor_id,first_name, last_name)
VALUES (201,'John', 'Doe');
select * from actor WHERE first_name = 'JOHN' AND last_name = 'DOE';















DELIMITER //

CREATE TRIGGER check_return_date
AFTER UPDATE ON rental
FOR EACH ROW
BEGIN
    IF NEW.return_date <= NEW.rental_date THEN 
        SET NEW.return_date = DATE_ADD(NEW.rental_date, INTERVAL 3 DAY);
    END IF;
END;
//

DELIMITER ;

UPDATE rental
SET return_date = '2024-05-10'
WHERE rental_id = 1;
SELECT * FROM rental WHERE rental_id = 1;










DELIMITER //

CREATE TRIGGER update_last_update_staff
AFTER UPDATE ON staff
FOR EACH ROW
BEGIN
    SET NEW.last_update = NOW(); 
END;
//

DELIMITER ;
UPDATE staff
SET first_name = 'Jane', last_name = 'Doe'
WHERE staff_id = 1;
SELECT * FROM staff WHERE staff_id = 1;








DELIMITER //

CREATE TRIGGER log_staff_update
AFTER UPDATE ON staff
FOR EACH ROW
BEGIN
    DECLARE email_modified BOOLEAN;
    IF OLD.email != NEW.email THEN
        SET email_modified = TRUE;
    ELSE
        SET email_modified = FALSE;
    END IF;
    INSERT INTO log_staff (Accion, Empleat, DataYHora, EmailModificat)
    VALUES ('actualitzacio', OLD.staff_id, NOW(), email_modified);
END;
//

CREATE TRIGGER log_staff_delete
AFTER DELETE ON staff
FOR EACH ROW
BEGIN
    INSERT INTO log_staff (Accion, Empleat, DataYHora, EmailModificat)
    VALUES ('esborrat', OLD.staff_id, NOW(), false);
END;
//

DELIMITER ;

UPDATE staff
SET first_name = 'Jane', last_name = 'Doe', email = 'jane.doe@example.com'
WHERE staff_id = 1; 
DELETE FROM staff
WHERE staff_id = 2;
SELECT * FROM log_staff;
















DELIMITER //

CREATE TRIGGER check_rental_return
AFTER UPDATE ON rental
FOR EACH ROW
BEGIN
    DECLARE rental_week DATE;
    DECLARE customer_warnings INT;
    
    SET rental_week = DATE_ADD(NEW.rental_date, INTERVAL 1 WEEK);

    IF NEW.return_date > rental_week THEN
        SELECT warnings INTO customer_warnings FROM customer WHERE customer_id = NEW.customer_id;
        IF customer_warnings < 3 THEN
            UPDATE customer SET warnings = customer_warnings + 1 WHERE customer_id = NEW.customer_id;
        ELSE
            UPDATE customer SET active = false WHERE customer_id = NEW.customer_id;
        END IF;
    END IF;
END;
//
UPDATE rental
SET return_date = '2024-05-15' 
WHERE rental_id = 1;
SELECT * FROM customer WHERE customer_id = (SELECT customer_id FROM rental WHERE rental_id = 1);


DELIMITER ;













DELIMITER //

CREATE PROCEDURE total_income_between_dates(
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    SELECT SUM(amount) AS total_income
    FROM payment
    WHERE payment_date BETWEEN start_date AND end_date;
END;
//

DELIMITER ;

CALL total_income_between_dates('2000-01-01', '2024-12-31');







DELIMITER //

CREATE PROCEDURE calculate_category_income(
    IN category_name VARCHAR(50),
    OUT category_income DECIMAL(10, 2)
)
BEGIN
    SELECT SUM(p.amount) INTO category_income
    FROM payment p
    INNER JOIN rental r ON p.rental_id = r.rental_id
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = category_name;
END;
//

DELIMITER ;

SET @category_name = 'Action';
SET @category_income = 0;
CALL calculate_category_income(@category_name, @category_income);

SELECT @category_income AS category_income;







DELIMITER //

CREATE PROCEDURE check_movie_availability(
    IN store_id INT,
    IN film_id INT,
    OUT availability_message VARCHAR(100)
)
BEGIN
    DECLARE movie_count INT;
    SELECT COUNT(*) INTO movie_count
    FROM inventory
    WHERE store_id = store_id AND film_id = film_id;
    
 
    IF movie_count > 0 THEN
        SET availability_message = 'La película está disponible para alquilar en esta tienda.';
    ELSE
        SET availability_message = 'La película no está disponible para alquilar en esta tienda.';
    END IF;
END;
//

DELIMITER ;


DELIMITER ;
SET @store_id = 1;
SET @film_id = 1;
SET @availability_message = '';
CALL check_movie_availability(@store_id, @film_id, @availability_message);
SELECT @availability_message AS availability_message;


DELIMITER //

CREATE PROCEDURE delete_inactive_customers(
    IN inactive_days INT,
    OUT delete_message VARCHAR(100)
)
BEGIN
    DECLARE deleted_count INT;
    DELETE FROM customer
    WHERE active = true AND DATEDIFF(CURRENT_DATE(), last_update) > inactive_days;
    SELECT ROW_COUNT() INTO deleted_count;
    IF deleted_count > 0 THEN
        SET delete_message = CONCAT('S\'han esborrat ', deleted_count, ' clients.');
    ELSE
        SET delete_message = 'No s\'ha esborrat cap client per inactivitat.';
    END IF;
END;
//

DELIMITER ;

SET @inactive_days = 30; 
SET @delete_message = '';

CALL delete_inactive_customers(@inactive_days, @delete_message);

SELECT @delete_message AS delete_message;

