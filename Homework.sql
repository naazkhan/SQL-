USE sakila;

SELECT * 
FROM actor;

SELECT first_name
FROM actor;

SELECT * FROM actor
WHERE first_name='Joe';

#Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT CONCAT(first_name, ' ', last_name)
FROM actor;

#Find all actors whose last name contain the letters GEN
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE  "%GEN%";

#Find all actors whose last names contain the letters LI. Order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name FROM actor 
WHERE last_name LIKE  "%LI%"
ORDER BY first_name,last_name ASC;

#SELECT first_name, last_name FROM actor WHERE last_name LIKE  "%LI%" 
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE  "%LI%";

#Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ("Afghanistan", "Bangladesh", "China");

#You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description blob (50);

SELECT *
FROM actor;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS 'Number of Actors' 
FROM actor 
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'Number of Actors' 
FROM actor GROUP BY last_name HAVING count(*) >=2;

#4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor 
SET first_name = 'HARPO'
WHERE First_name = "Groucho" AND last_name = "Williams";

#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently`HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 

UPDATE actor 
SET first_name = 'GROUCHO'
WHERE actor_id = 172;

#5a.You cannot locate the schema of the address table. Which query would you use to re-create it?
Describe.sakila.address;

#6a.Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff
INNER JOIN address ON staff.address_id=address.address_id;

#6b.Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT payment.staff_id, staff.first_name, staff.last_name, payment.amount, payment.payment_date
FROM staff INNER JOIN payment ON
staff.staff_id = payment.staff_id AND payment_date LIKE '2005-08%'; 

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title,COUNT(film_actor.actor_id) AS NumberOfactors FROM film_actor
INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title,COUNT(film_actor.actor_id) AS NumberOfactors FROM film_actor
INNER JOIN film ON film_actor.film_id = film.film_id
WHERE title = "Hunchback Impossible"
GROUP BY title;

#6e.Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT last_name, first_name, SUM(amount)
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 

SELECT title
FROM film WHERE title 
LIKE 'K%' OR title LIKE 'Q%'
AND title IN 
(
SELECT title 
FROM film 
WHERE language_id = 1
);

#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
Select actor_id
FROM film_actor
WHERE film_id IN 
(
SELECT film_id
FROM film
WHERE title = 'Alone Trip'
));

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT country.country, customer.last_name, customer.first_name, customer.email
FROM country 
LEFT JOIN customer 
ON country.country_id = customer.customer_id
WHERE country = 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT title, description FROM film 
WHERE film_id IN
(
SELECT film_id FROM film_category
WHERE category_id IN
(
SELECT category_id FROM category
WHERE name = "Family"
));

#7e. Display the most frequently rented movies in descending order.
SELECT inventory.film_id, film_text.title, COUNT(rental.inventory_id)
FROM inventory 
INNER JOIN rental 
ON inventory.inventory_id = rental.inventory_id
INNER JOIN film_text 
ON inventory.film_id = film_text.film_id
GROUP BY rental.inventory_id
ORDER BY COUNT(rental.inventory_id) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount)
FROM store
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment 
ON payment.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(amount);


#7g Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city, country
FROM store 
INNER JOIN customer 
ON store.store_id = customer.store_id
INNER JOIN staff 
ON store.store_id = staff.store_id
INNER JOIN address 
ON customer.address_id = address.address_id
INNER JOIN city 
ON address.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;

#-8a. In your new role as an executive, you would like to have an easy way of viewing the top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_grossing_genres AS

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_grossing_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_grossing_genres;

