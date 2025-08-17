create Database Pizzahut;
use pizzahut;

create table orders (
order_id int not null primary key,
order_date datetime not null,
order_time time not null
);


CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT
);


LOAD DATA LOCAL INFILE 'C:/Users/User/Desktop/Final_Projects/Project2/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_details_id, order_id, pizza_id, quantity);

#------------------------------------------------------------------------------------#

## Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS TOTAL_NUMBER_OF_Orders
FROM
    orders;



##Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS TOTAL_SALES
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;


##Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;  




##Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;




##List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

#--------------------------------------------#


##Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS TOTAL_QUANTITY
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY TOTAL_QUANTITY desc; 



#Determine the distribution of orders by hour of the day.
select hour(order_time) as Hour_NO, count(order_id) as order_count from orders group by hour(order_time);





## Join relevant tables to find the category-wise distribution of pizzas.

Select category, count(name) from pizza_types group by category;








## Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity1), 0) as AVG_Pizza_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity1
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS ORDER_QUANTITY;






##Determine the top 3 most ordered pizza types based on revenue.

Select pizza_types.name, sum(order_details.quantity*pizzas.price) as Revenue from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id join order_details on order_details.pizza_id= pizzas.pizza_id group by pizza_types.name
order by Revenue desc limit 3;

#--------------------------------------------------------------------#

##Calculate the percentage contribution of each pizza type to total revenue.
Select pizza_types.category, round((sum(order_details.quantity*pizzas.price)/( SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS TOTAL_SALES
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id))*100,2) as Revenue
  
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id join order_details on order_details.pizza_id= pizzas.pizza_id group by pizza_types.category 
 order by Revenue;






##Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over (order by order_date) as Cum_Revenue
from
(Select orders.order_date, sum(order_details.quantity*pizzas.price) as revenue from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id join orders on orders.order_id=order_details.order_id
group by  orders.order_date) Sales ;









##Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(Select category, name,revenue, rank() over (partition by category order by revenue desc) as RN from
(
SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas 
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) as A) as B
 where RN <=3;











