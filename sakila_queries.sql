
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT *, CONCAT(first_name, ',', last_name) AS `Actor Name`  FROM sakila.actor; 

/* 2a. You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/

SELECT actor_id,first_name,last_name FROM sakila.actor where first_name = 'Joe';

-- 2b.  Find all actors whose last name contain the letters GEN:

SELECT first_name, last_name FROM sakila.actor where last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT last_name, first_name FROM sakila.actor where last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM sakila.country WHERE country IN ('Afghanistan','Bangladesh','China');

/* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
as the difference between it and VARCHAR are significant).*/

ALTER TABLE sakila.actor ADD column `Description` BLOB;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/

ALTER TABLE sakila.actor DROP COLUMN `Description`;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*) as count FROM sakila.actor group by last_name;

/* 4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors*/

SELECT last_name, COUNT(*) as count FROM sakila.actor 
GROUP BY last_name HAVING COUNT(*) > 1;

/* 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
Write a query to fix the record. */

UPDATE sakila.actor SET first_name = 'HARPO' 
	WHERE first_name = 'GROUCHO'
		AND last_name = 'WILLIAMS';

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, 
if the first name of the actor is currently HARPO, change it to GROUCHO. */

SET SQL_SAFE_UPDATES = 0;
	UPDATE sakila.actor 
		SET first_name = 'GROUCHO' 
			WHERE first_name = 'HARPO';

SET SQL_SAFE_UPDATES = 1;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

SELECT first_name, last_name, address.address FROM sakila.staff
	INNER JOIN sakila.address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.


SELECT staff.first_name, staff.last_name, sum(amount) aug_sales_amount
	FROM sakila.payment
		INNER JOIN sakila.staff ON staff.staff_id = payment.staff_id
			WHERE EXTRACT( YEAR_MONTH FROM payment_date ) = '200508'
				GROUP BY staff.first_name,staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

SELECT film.title, count(actor_id) num_actors_count FROM film 
	INNER JOIN film_actor ON film_actor.film_id = film.film_id
		GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT  count(inventory.film_id) copies_hunchback FROM film 
	INNER JOIN inventory ON inventory.film_id = film.film_id
		WHERE film.title = 'Hunchback Impossible';

/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:*/

SELECT customer.first_name, customer.last_name, sum(amount) as `Total Amount Paid `
	FROM customer
		INNER JOIN payment ON payment.customer_id = customer.customer_id
			GROUP BY customer.first_name, customer.last_name
			ORDER BY customer.last_name;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/

SELECT title as TITLE_KQ_ENG FROM film
WHERE film_id IN 
	(SELECT film_id FROM film
			JOIN language ON language.language_id = film.language_id
					WHERE ( title like 'K%' OR title like 'Q%')
                                   and language.name = 'ENGLISH');
								   
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

USE sakila;
SELECT first_name, last_name FROM actor
WHERE actor_id IN
	(SELECT actor_id FROM film_actor
		WHERE film_id IN
			(SELECT film_id FROM film 
				WHERE title = 'Alone Trip'
			)
	)
;

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
email addresses of all Canadian customers.  Use joins to retrieve this information.*/


USE sakila;
SELECT c.first_name as `First Name`, c.last_name as `Last Name`, c.email as `Custormer Email`
FROM customer c
	INNER JOIN address a ON a.address_id = c.address_id
		INNER JOIN city cy ON cy.city_id = a.city_id
			INNER JOIN country co ON co.country_id = cy.country_id
				WHERE co.country = 'Canada';
                
    
/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films. */

USE sakila;
SELECT f.title as `Family Films` FROM film f
	INNER JOIN film_category fc ON fc.film_id = f.film_id
		INNER JOIN category c ON c.category_id = fc.category_id
			WHERE c.name = 'family';

-- 7e. Display the most frequently rented movies in descending order.

USE sakila;
SELECT f.title, count(r.rental_id) rental_count FROM film f
	INNER JOIN inventory i ON i.film_id = f.film_id
		INNER JOIN rental r ON r.inventory_id = i.inventory_id
			GROUP BY f.title
			ORDER BY 2 DESC, 1 DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

USE sakila;
SELECT s.store_id as `Store ID`, sum(p.amount) as `Total Amount` FROM payment p
	INNER JOIN customer c ON c.customer_id = p.customer_id
		INNER JOIN store s ON s.store_id = c.store_id
			GROUP BY s.store_id;
			

-- 7g. Write a query to display for each store its store ID, city, and country.

USE sakila;
SELECT s.store_id as `Store ID`, c.city as `City`, co.country as `Country` FROM store s
	INNER JOIN address a ON a.address_id = s.address_id
		INNER JOIN city c ON c.city_id = a.city_id
			INNER JOIN country co ON co.country_id = c.country_id;

/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */

USE sakila;
SELECT c.name as `Genre`, sum(p.amount) as `Gross Revenue` FROM payment p
	INNER JOIN rental r ON r.rental_id = p.rental_id
		INNER JOIN inventory i ON i.inventory_id = r.inventory_id
			INNER JOIN film_category fc ON fc.film_id = i.film_id
				INNER JOIN category c ON c.category_id = fc.category_id
                GROUP BY c.name
                ORDER BY 2 desc limit 5;
                
/*8a. In your new role as an executive, you would like to have an easy 
way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
If you haven't solved 7h, you can substitute another query to create a view.*/
 
USE sakila;
CREATE VIEW  top_five_genres as 
	SELECT c.name as `Genre`, sum(p.amount) as `Gross Revenue` FROM payment p
	INNER JOIN rental r ON r.rental_id = p.rental_id
		INNER JOIN inventory i ON i.inventory_id = r.inventory_id
			INNER JOIN film_category fc ON fc.film_id = i.film_id
				INNER JOIN category c ON c.category_id = fc.category_id
                GROUP BY c.name
                ORDER BY 2 desc limit 5;
 

 -- 8b. How would you display the view that you created in 8a?
 
USE sakila;
SELECT * FROM view top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
 
DROP VIEW top_five_genres;
