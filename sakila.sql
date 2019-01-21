use sakila;
-- 1a. Display the first and last names of all actors from the table actor-- 
select first_name,last_name from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
select upper(concat(first_name, ' ',  last_name)) as "Actor Name"  from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
select actor_id, first_name, last_name from actor where first_name = "Joe";
-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like '%GEN%';
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like '%LI%' order by last_name, first_name;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in('Afghanistan' , 'Bangladesh', 'China');
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table 
-- actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor add column description blob null;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor drop column description;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name , count(*) from actor group by last_name order by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name , count(*) from actor group by last_name having count(*) > 1 order by last_name;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor set first_name = 'HARPO' where first_name = 'GROUCHO'  and last_name = 'WILLIAMS';
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name = 'GROUCHO'  where first_name = 'HARPO';
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address from staff as s join address as a on s.address_id = a.address_id;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, sum(p.amount) as 'total amount' from staff as s 
join payment as p on s.staff_id = p.staff_id
and date(p.payment_date) >= '2005-08-01' and date(p.payment_date) <= '2005-08-31'
group by  s.first_name;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(fc.actor_id) as actor_count from film as f 
inner join film_actor as fc on f.film_id = fc.film_id group by f.title;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.inventory_id) as inventory_count from film as f 
inner join inventory as i on f.film_id = i.film_id 
where f.title = 'Hunchback Impossible'
group by f.title;
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name , sum(p.amount) as total_amount from customer c
inner join payment p on c.customer_id = p.customer_id 
group by c.customer_id 
order by c.last_name;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and 
-- Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select f.title from film f where f.title like 'Q%' or f.title like 'K%'
and f.language_id in (select language_id from language l where l.name = 'English');
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.-- 
select a.first_name, a.last_name from actor a
where a.actor_id in
(select fa.actor_id from film_actor fa where fa.film_id in 
(select f.film_id from film f where title = 'Alone Trip'));
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select c.first_name, c.last_name, c.email from customer c
inner join address a on a.address_id = c.address_id
inner join city ci on ci.city_id = a.city_id
inner join country co on co.country_id = ci.country_id
where co.country = 'Canada';
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select f.title, fc.category_id, ca.name from film f 
inner join film_category fc on f.film_id = fc.film_id
inner join category ca on ca.category_id = fc.category_id
where ca.name = 'Family';
-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id) as rent_count from film f
inner join inventory inv on f.film_id = inv.film_id
inner join rental r on inv.inventory_id = r.inventory_id
group by f.title
order by rent_count desc;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select a.address as store_address, sum(p.amount ) as revenue from store s
inner join staff st on s.store_id = st.store_id
inner join address a on s.address_id = a.address_id
inner join rental r on st.staff_id = r.staff_id
inner join payment p on r.rental_id = p.rental_id
group by a.address;
-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, s.address_id, a.city_id, ci.city, co.country from store s
inner join address a on s.address_id = a.address_id
inner join city ci on a.city_id = ci.city_id
inner join country co on co.country_id = ci.country_id;
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following 
-- tables: category, film_category, inventory, payment, and rental.)
select ca.name, sum(p.amount) as gross_revenue from category ca
inner join film_category fc on ca.category_id = fc.category_id
inner join inventory inv on fc.film_id = inv.film_id
inner join rental r on inv.inventory_id = r.inventory_id
inner join payment p on r.rental_id = p.rental_id
group by ca.name
order by gross_revenue desc limit 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create  view top_five_genres as 
select ca.name, sum(p.amount) as gross_revenue from category ca
inner join film_category fc on ca.category_id = fc.category_id
inner join inventory inv on fc.film_id = inv.film_id
inner join rental r on inv.inventory_id = r.inventory_id
inner join payment p on r.rental_id = p.rental_id
group by ca.name
order by gross_revenue desc limit 5;
-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;
























