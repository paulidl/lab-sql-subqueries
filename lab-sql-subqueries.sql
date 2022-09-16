/* Lab | SQL Subqueries.

In this lab, you will be using the Sakila database of movie rentals. Create appropriate joins wherever necessary.

Instructions:

1. How many copies of the film Hunchback Impossible exist in the inventory system?
2. List all films whose length is longer than the average of all the films.
3. Use subqueries to display all actors who appear in the film Alone Trip.
4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
7. Films rented by most profitable customer.
You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments.
8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
*/

USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system? 

SELECT * FROM sakila.inventory;				# inventory_id, film_id
SELECT * FROM sakila.film;					# film_id, title

-- SUBQUERY:
SELECT film_id FROM sakila.film WHERE title = 'Hunchback Impossible';			# film_id = 439

-- FINALQUERY:
SELECT f.title, count(inventory_id) AS number_of_copies
FROM sakila.inventory i
JOIN sakila.film f ON i.film_id = f.film_id
WHERE f.film_id = 
(SELECT film_id 
FROM sakila.film 
WHERE title = 'Hunchback Impossible'
)
GROUP BY f.title;						# number_of_copies = 6

-- 2. List all films whose length is longer than the average of all the films.

SELECT * FROM sakila.film;		# film_id, title, length

-- SUBQUERIE:
SELECT AVG(length) AS average_length FROM sakila.film;			# average_length = 115.2720

-- FINAL QUERY:
SELECT film_id, title, length
FROM sakila.film
WHERE length > (SELECT AVG(length) FROM sakila.film)
ORDER BY length DESC;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT * FROM sakila.film_actor;		# actor_id, film_id
SELECT * FROM sakila.film;				# film_id, title
SELECT * FROM sakila.actor;				# actor_id, frist_name, last_name

-- SUBQUERIE1:
SELECT film_id FROM sakila.film WHERE title = 'Alone Trip';			# film_id = 17

-- SUBQUERIE2: 
SELECT actor_id FROM sakila.film_actor
WHERE film_id = (SELECT film_id FROM sakila.film WHERE title = 'Alone Trip');

-- FINAL QUERY:
SELECT fa.film_id, f.title, fa.actor_id, a.first_name, a.last_name
FROM sakila.film_actor fa
JOIN sakila.film f ON fa.film_id = f.film_id
JOIN sakila.actor a ON fa.actor_id = a.actor_id
WHERE fa.film_id = (SELECT film_id FROM sakila.film WHERE title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT * FROM sakila.category;			# category_id, name
SELECT * FROM sakila.film_category;		# category_id, film_id
SELECT * FROM sakila.film;				# film_id, title 

-- SUBQUERIE:
SELECT category_id FROM sakila.category WHERE name = 'Family';			# category_id = 8

-- FINAL QUERY:
SELECT fc.category_id, name AS category, f.film_id, f.title
FROM sakila.film_category fc
JOIN sakila.category c ON fc.category_id = c.category_id
JOIN sakila.film f ON fc.film_id = f.film_id
WHERE fc.category_id = (SELECT category_id FROM sakila.category WHERE name = 'Family');

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

SELECT * FROM sakila.customer;			# customer_id, first_name, last_name, email, address_id
SELECT * FROM sakila.address;			# address_id, district, city_id
SELECT * FROM sakila.city;				# city_id, country_id
SELECT * FROM sakila.country;			# country_id, country

-- SUBQUERIE:
SELECT country_id FROM sakila.country WHERE country = 'Canada';			# Country_id = 20

-- FINAL QUERY:
SELECT co.country_id, co.country, cu.customer_id, cu.first_name, cu.last_name, email
FROM sakila.country co
JOIN sakila.city ci ON ci.country_id = co.country_id 
JOIN sakila.address a ON a.city_id = ci.city_id
JOIN sakila.customer cu ON cu. address_id = a.address_id
WHERE co.country_id = (SELECT country_id FROM sakila.country WHERE country = 'Canada');

-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT * FROM sakila.film_actor;				# actor_id, film_id
SELECT * FROM sakila.film;						# film_id, title
	
-- SUBQUERY:
SELECT actor_id, count(film_id) FROM sakila.film_actor GROUP BY actor_id ORDER BY count(film_id) DESC limit 1;		# actor_id = 107

-- FINAL QUERY:
SELECT title
FROM sakila.film f
JOIN 
(SELECT fa.film_id 
FROM sakila.film_actor fa
WHERE actor_id = 
	(SELECT actor_id 
    FROM 
		(SELECT actor_id, count(film_id) 
		FROM sakila.film_actor 
		GROUP BY actor_id 
		ORDER BY count(film_id) DESC 
		limit 1
        ) AS most_prolific_actor 
	)
) f1
ON f1.film_id = f.film_id;

-- 7. Films rented by most profitable customer.
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments.

SELECT * FROM sakila.rental;			# customer_id, inventory_id
SELECT * FROM sakila.inventory;			# inventory_id, film_id
SELECT * FROM sakila.film;				# film_id, title

-- SUBQUERIE:
SELECT customer_id, sum(amount) AS sum_of_payments FROM sakila.payment GROUP BY customer_id ORDER BY sum_of_payments DESC limit 1;			# customer_id = 526

-- FINAL QUERY:
SELECT r.customer_id, f.title
FROM sakila.film f
JOIN sakila.inventory i ON f.film_id = i.film_id
JOIN sakila.rental r ON i.inventory_id = r.inventory_id
WHERE customer_id = 
(SELECT customer_id 
FROM (SELECT customer_id, sum(amount) AS sum_of_payments 
	  FROM sakila.payment
	  GROUP BY customer_id 
	  ORDER BY sum_of_payments DESC 
	  LIMIT 1
	 ) AS most_profitable_customer
);

-- 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

SELECT * FROM sakila.payment;			# payment_id, customer_id, amount

-- SUBQUERIE1:
SELECT customer_id, sum(amount) AS total_amount_spent FROM sakila.payment GROUP BY customer_id ORDER BY total_amount_spent DESC;		

-- SUBQUERIE2:
SELECT ROUND(AVG(total_amount_spent) ,2) AS average_of_total_amount
FROM 
(SELECT customer_id, sum(amount) AS total_amount_spent 
FROM sakila.payment 
GROUP BY customer_id 
ORDER BY total_amount_spent DESC
) AS sq1;										# average_of_total_amount = 112.53
 
-- FINAL QUERY:
SELECT customer_id, sum(amount) AS total_amount_spent 
FROM sakila.payment 
GROUP BY customer_id 
HAVING total_amount_spent > 
(SELECT ROUND(AVG(total_amount_spent) ,2) AS average_of_total_amount
FROM 
	(SELECT customer_id, sum(amount) AS total_amount_spent 
	FROM sakila.payment 
	GROUP BY customer_id 
	ORDER BY total_amount_spent DESC
	) AS sq1
);
