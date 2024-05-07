CREATE DATABASE music_store;
USE music_store;

/* Q1. Who is the senior most employee based on each job title? */ 

SELECT first_name,last_name,title FROM(
SELECT first_name,last_name,title,
ROW_NUMBER() OVER(PARTITION BY title ORDER BY birthdate ASC) AS rn
FROM employee) AS senior_emp WHERE rn = 1;


/* Q2. Which countries have the most invoices ? */

SELECT billing_country,COUNT(invoice_id) AS invoice_count FROM invoice 
GROUP BY billing_country 
ORDER BY invoice_count DESC LIMIT 1;

/* Q3. What are the top 3 values of total invoice ? */

SELECT invoice_id, ROUND(total,2) AS total FROM invoice
ORDER BY total DESC LIMIT 3;

/* Q4. Which city has the best customer( The city from which customers have spent the most amount) ? */

SELECT billing_city, ROUND(SUM(total),2) AS total_amount_spent FROM invoice
GROUP BY billing_city 
ORDER BY total_amount_spent DESC LIMIT 1;

/* Q5. Identify the best customer ( based on spending of amount) */

SELECT CONCAT(first_name,' ', last_name) AS name,ROUND(SUM(total),2) AS amount_spent FROM (
SELECT c.first_name,c.last_name,i.total FROM customer AS c
INNER JOIN invoice AS i ON c.customer_id = i.customer_id) AS a 
GROUP BY name ORDER BY amount_spent DESC LIMIT 1;

/* Q6. Provide the country,email & name of all Rock Music listeners ordered alphabetically by name. */

SELECT DISTINCT CONCAT(first_name,' ', last_name) AS name, c.email, c.country FROM customer AS c
INNER JOIN invoice AS i ON c.customer_id = i.customer_id
INNER JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
WHERE track_id IN 
( SELECT track_id FROM track INNER JOIN genre ON track.genre_id = genre.genre_id WHERE genre.name LIKE 'Rock')
ORDER BY name ;

/* Q7. Find the Artist name and total track count of the top 5 rock bands */

SELECT DISTINCT artist.name AS artist_name,COUNT(track.name) AS song_count FROM artist 
INNER JOIN album ON artist.artist_id = album.artist_id
INNER JOIN track ON album.album_id = track.album_id
INNER JOIN genre ON track.genre_id = genre.genre_id
WHERE track.track_id IN 
( SELECT track_id FROM track INNER JOIN genre ON track.genre_id = genre.genre_id WHERE genre.name LIKE 'Rock')
GROUP BY artist_name
ORDER BY song_count DESC LIMIT 5;

/* Q8. Return the Name and Milliseconds for each track that have a song length longer than the average song length.
 Order by the song length with the longest songs listed first.*/

SELECT name,milliseconds FROM track 
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

/* Q9. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. */

WITH popular_genre AS(
SELECT DISTINCT genre.name AS name,invoice.billing_country AS country,ROUND(SUM(invoice.total),2) AS amount FROM genre
INNER JOIN track ON genre.genre_id = track.genre_id
INNER JOIN invoice_line ON track.track_id = invoice_line.track_id
INNER JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
GROUP BY name,country
 ),
 ranked_genre AS(
SELECT *,DENSE_RANK() OVER(PARTITION BY country ORDER BY amount DESC) AS rnk FROM popular_genre
)
SELECT name,country,amount FROM ranked_genre WHERE rnk=1;

/* Q10. Find the customer that has spent the most on music for each country. For countries where the top amount spent is shared, provide all
customers who spent this amount. */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,ROUND(SUM(total),2) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT customer_id,first_name,last_name,billing_country,total_spending FROM Customter_with_country WHERE RowNo <= 1;
