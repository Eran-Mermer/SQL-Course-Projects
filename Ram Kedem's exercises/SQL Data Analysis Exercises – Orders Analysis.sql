------------------------------------------------
--SQL Data Analysis Exercises – Orders Analysis
------------------------------------------------

--Basic Analysis--

--1- Display the customers distribution by gender in percentage (for example : 20% Males and 80% Females)
SELECT CONCAT(CAST(SUM(CASE WHEN gender = 'male' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, '%') 'Male',
	   CONCAT(CAST(SUM(CASE WHEN gender = 'female' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, '%') 'Female'
FROM customers

--2- Which customer has ordered the highest amount of items ?
SELECT TOP 1 o.customer_id, COUNT(o.item_id) 'num_items'
FROM orders o
GROUP BY o.customer_id
ORDER BY num_items DESC

--3- What is the average item price ?
SELECT AVG(item_price) AVVERAGE
FROM items

--Advanced Analysis--

--1- What are the top-5 selling products?
SELECT TOP 5 item_id, COUNT(*) 'num_sold'
FROM orders
GROUP BY item_id
ORDER BY COUNT(*) DESC

--2- How many orders customer 4 has made, display it along with his/her gender?
SELECT c.gender, COUNT(DISTINCT o.order_id) 'cnt'
FROM orders o JOIN customers c
	ON c.id = o.customer_id
WHERE o.customer_id = 4
GROUP BY gender

--3- Active customer is a customer that ordered at least one item, list the non active male customers this grocery store has
SELECT *
FROM customers c LEFT JOIN orders O
	ON o.customer_id = c.id
WHERE gender = 'male' AND o.item_id IS NULL

--4- Display the customer who spent the highest amount of money
;WITH "cte-spend"
 AS
 (
  SELECT customer_id, order_id, i.item_price * o.order_quantity 'spent'
  FROM orders o JOIN items i
	  ON i.item_id = o.item_id
 )
SELECT TOP 1 c.id, SUM(ct.spent) 'total_spent'
FROM customers c JOIN [cte-spend] ct
	ON ct.customer_id = c.id
GROUP BY c.id
ORDER BY total_spent DESC

--5- Display the customers who purchased at least one of the products he/she made (using one query)
SELECT DISTINCT o1.customer_id
FROM orders o JOIN orders o1
	ON o1.item_id = o.item_id
WHERE o.customer_id = 27
ORDER BY o1.customer_id

--6- Disply the product whose price is closest to the average item price
SELECT TOP 1 ABS(item_price - (SELECT AVG(item_price)
						 FROM items)) 'avg_diff'
FROM items
ORDER BY avg_diff

--7- What is the most profitable day of the week (where the quantity of products-sold is the highest)
SELECT TOP 1 DATENAME(WEEKDAY, o.order_date) 'Day', SUM(o.order_quantity) 'total_ordered'
FROM orders o
GROUP BY DATENAME(WEEKDAY, o.order_date)
ORDER BY total_ordered DESC
