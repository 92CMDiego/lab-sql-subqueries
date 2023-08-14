USE sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(inventory_id) AS num_copies
FROM sakila.inventory
WHERE film_id IN (SELECT film_id
FROM sakila.film
WHERE film.title = 'Hunchback Impossible');

-- 2.List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT film_id, title, length
FROM sakila.film
WHERE length >
(SELECT AVG(length)
FROM sakila.film);

-- 3.Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT first_name, last_name FROM sakila.actor
WHERE actor_id IN(
SELECT actor_id
FROM sakila.film_actor WHERE film_id IN (SELECT film_id
FROM sakila.film
WHERE film.title = 'Alone Trip'));

-- 4.Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT film_id, title
FROM sakila.film
WHERE film_id IN
(SELECT film_id
FROM sakila.film_category
WHERE category_id IN
(SELECT category_id
FROM sakila.category
WHERE name = 'Family'));

-- 5.Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT customer_id, first_name, last_name, email FROM sakila.customer
WHERE address_id IN
(SELECT address_id FROM sakila.address
WHERE city_id IN
(SELECT city_id FROM sakila.city
WHERE country_id IN
(SELECT country_id FROM sakila.country
WHERE country = 'Canada')))
GROUP BY customer_id;

-- (Using JOIN).
SELECT customer_id, first_name, last_name, email, ci.city, co.country
FROM sakila.customer c
JOIN sakila.address a
USING (address_id)
JOIN sakila.city ci
USING (city_id)
JOIN sakila.country co
USING (country_id)
WHERE country = 'Canada'
GROUP BY customer_id;

-- 6.Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT film_id, title FROM sakila.film
WHERE film_id IN (
SELECT film_id FROM sakila.film_actor
WHERE actor_id IN (
SELECT actor_id FROM (
SELECT actor_id, COUNT(film_id) AS count_films
FROM sakila.film_actor
GROUP BY actor_id
ORDER BY count_films DESC
LIMIT 1) sub));

-- 7.Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT film_id, title FROM sakila.film
WHERE film_id IN
(SELECT film_id FROM sakila.inventory
WHERE inventory_id IN
(SELECT inventory_id FROM rental
WHERE customer_id IN
(SELECT customer_id FROM
(SELECT customer_id, SUM(amount) AS tot_amount FROM sakila.payment
GROUP BY customer_id
ORDER BY tot_amount DESC
LIMIT 1) sub)));

-- 8.Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM sakila.payment
GROUP BY customer_id
HAVING total_amount_spent > (
SELECT AVG(tot_amount)
FROM (SELECT customer_id, SUM(amount) AS tot_amount
FROM sakila.payment
GROUP BY customer_id) AS sub)
ORDER BY total_amount_spent DESC;

-- (Check average of total amount per client).
SELECT AVG(tot_amount) AS avg_tot_amount
FROM (SELECT customer_id, SUM(amount) AS tot_amount
FROM sakila.payment
GROUP BY customer_id) sub;