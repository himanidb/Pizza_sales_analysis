create database pizza_stop;

use pizza_stop;

-- Basic:

-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) Total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(price * quantity), 2) Total_pizza_revenue
FROM
    pizzas
        NATURAL JOIN
    order_details;

-- Identify the highest-priced pizza.

SELECT 
    name, price
FROM
    pizzas
        NATURAL JOIN
    pizza_types
WHERE
    price = (SELECT 
            MAX(price)
        FROM
            pizzas);

-- Identify the most common pizza size ordered.

SELECT 
    size, COUNT(quantity) count
FROM
    order_details
        NATURAL JOIN
    pizzas
GROUP BY size
ORDER BY count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    name, sum(quantity) quantity
FROM
    order_details
        NATURAL JOIN
    pizzas
        NATURAL JOIN
    pizza_types
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity) count
FROM
    pizza_types
        NATURAL JOIN
    pizzas
        NATURAL JOIN
    order_details
GROUP BY category;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) hour, COUNT(order_id) quantity
FROM
    orders
GROUP BY hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(*) quantity
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) avg_no_of_pizzas_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) quantity
    FROM
        orders
    NATURAL JOIN order_details
    GROUP BY order_date) dt;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    name, ROUND(SUM(price * quantity), 2) revenue
FROM
    order_details
        NATURAL JOIN
    pizzas
        NATURAL JOIN
    pizza_types
GROUP BY name
ORDER BY SUM(price) DESC
LIMIT 3;

-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    category,
    ROUND(SUM(price * quantity) / (SELECT 
                    SUM(price * quantity)
                FROM
                    pizzas
                        NATURAL JOIN
                    order_details) * 100,
            4) contribution
FROM
    pizza_types
        NATURAL JOIN
    pizzas
        NATURAL JOIN
    order_details
GROUP BY category;

-- Analyze the cumulative revenue generated over time.

SELECT 
	order_date, 
	ROUND(SUM(revenue) OVER (ORDER BY order_date),2) cum_revenue 
FROM 
	(SELECT 
		order_date,
		SUM(quantity*price) revenue
	FROM 
		orders 
			NATURAL JOIN  
		order_details 
			NATURAL JOIN pizzas
	GROUP BY order_date) dt;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
	category, name, revenue 
FROM 
	(SELECT 
		category, name, revenue, RANK() OVER(PARTITION BY  category ORDER BY revenue DESC) rn 
	FROM
		(SELECT 
			category, name, SUM(quantity*price) revenue
		FROM 
			order_details 
				NATURAL JOIN 
			pizzas 
				NATURAL JOIN 
			pizza_types
		GROUP BY category,name) dt ) dt2
WHERE rn<=3;


