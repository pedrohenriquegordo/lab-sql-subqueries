use sakila;

#1
SELECT COUNT(inventory_id)
FROM inventory 
WHERE film_id 
	IN(
    SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible');

#2
SELECT title, length
FROM film 
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length ASC;

#3 
SELECT first_name, last_name
FROM actor
WHERE actor_id
	IN(
    SELECT actor_id
    FROM film_actor 
	WHERE film_id 
		IN(
        SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'));

#4
SELECT title 
FROM film 
WHERE film_id 
	IN(
    SELECT film_id
    FROM film_category 
	WHERE category_id
		IN(
        SELECT category_id
        FROM category
        WHERE name = 'family')); 

#5
SELECT first_name, last_name, email
FROM customer
WHERE address_id
	IN(
    SELECT address_id 
    FROM address 
    WHERE city_id
		IN(
        SELECT city_id
        FROM city
        WHERE country_id
			IN(
            SELECT country_id
            FROM country
            WHERE country = 'Canada')));

SELECT first_name, last_name, email
FROM customer
CROSS JOIN address ON customer.address_id = address.address_id
CROSS JOIN city ON address.city_id = city.city_id
CROSS JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Canada';

#6
SELECT title 
FROM film 
WHERE film_id IN(
	SELECT film_id 
    FROM film_actor 
    WHERE actor_id
		IN(
        SELECT actor_id 
        FROM film_actor 
        GROUP BY actor_id 
        ORDER BY COUNT(film_id) DESC 
        LIMIT 1));
-- It says: Error Code: 1235. This version of MySQL doesn't yet support 'LIMIT & IN/ALL/ANY/SOME subquery' 
-- but the subquery returns the right actor_id.
SELECT actor_id FROM film_actor GROUP BY actor_id ORDER BY COUNT(film_id) DESC LIMIT 1;
#7

SELECT title
FROM film
WHERE film_id IN(
	SELECT film_id
    FROM inventory
    WHERE inventory_id IN(
		SELECT inventory_id
        FROM rental
        WHERE customer_id IN(
			SELECT customer_id
			FROM customer
			WHERE customer_id
				IN(
				SELECT customer_id
				FROM payment 
				GROUP BY customer_id 
				ORDER BY SUM(AMOUNT) DESC
				LIMIT 1))));
    
-- It happens the same as in the #6.

#8

-- Total amount per customer
SELECT customer_id, SUM(amount) AS t_amount
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) ASC;

-- I created a table where I store the data of the total amount per customer since I couldn't find a way to do it only using subqueries.

DROP TABLE IF EXISTS total_amount;

CREATE TABLE total_amount
SELECT customer_id, SUM(amount) AS t_amount
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) ASC;

-- This query follows the same logic on the #2
SELECT customer_id, t_amount
FROM total_amount
WHERE t_amount > (SELECT AVG(t_amount) FROM total_amount)
ORDER BY t_amount ASC;






