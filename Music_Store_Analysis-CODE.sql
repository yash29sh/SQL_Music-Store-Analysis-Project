                                         ----EASY---
/* Q1: Who is the senior most employee based on job title? */
select employee_id , first_name , last_name , levels from employee Order By levels Desc limit 1;

/* Q2: Which countries have the most Invoices? */
SELECT   billing_country,count(billing_country) as cbc from invoice Group By billing_country Order By cbc Desc;

/* Q3: What are top 3 values of total invoice? */
SELECT invoice_id,total from invoice Order By total Desc Limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select billing_city , sum(total) as tbc from invoice Group By billing_city Order By tbc Desc LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select customer.customer_id , first_name , last_name  , SUM(total) as max_spend
from customer Inner Join invoice ON customer.customer_id = invoice.customer_id
Group By customer.customer_id Order By max_spend Desc Limit 1;

                                        ---MODERATE---
/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock')
ORDER BY email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id , artist.name ,count(artist.artist_id) as total_track_count from artist
JOIN album ON album.artist_id = artist.artist_id
JOIN track ON track.album_id = album.album_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
group by artist.artist_id
ORDER BY total_track_count DESC LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select track.name , track.milliseconds from track
where track.milliseconds > (select AVG(track.milliseconds) from track)
order by track.milliseconds desc;

								   ---Advance---
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
with bsa as (
	select artist.artist_id,artist.name,sum(invoice_line.unit_price*invoice_line.quantity) as sales
	from invoice_line join track on invoice_line.track_id = track.track_id
	join album on track.album_id = album.album_id
	join artist on album.artist_id = artist.artist_id
	group by 1
	order by sales desc
	limit 1
)
select customer.customer_id,customer.first_name,customer.last_name, bsa.name,
sum(invoice_line.unit_price*invoice_line.quantity) as sales_contri from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join bsa on bsa.artist_id = album.artist_id
group by 1,2,3,4
order by sales_contri desc
limit 10;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
