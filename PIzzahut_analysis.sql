create database pizaahut;

CREATE TABLE orders (
    order_ID INT NOT NULL,
    order_Date DATE NOT NULL,
    order_Time TIME NOT NULL,
    PRIMARY KEY (order_ID)
);

CREATE TABLE orders_Details (
    order_details_id INT NOT NULL,
    order_ID INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Retrieve the total number of orders placed.
CREATE VIEW total_order AS
    SELECT 
        COUNT(order_ID) AS total_order
    FROM
        orders;
SELECT 
    *
FROM
    total_order;

-- Calculate the total revenue generated from pizza sales.
CREATE VIEW total_revenue AS
    SELECT 
        ROUND(SUM(a.quantity * b.price), 2) AS total_revenue
    FROM
        orders_details a
            JOIN
        pizzas b ON a.pizza_id = b.pizza_id;
SELECT 
    *
FROM
    total_revenue;

-- Identify the highest-priced pizza.
CREATE VIEW highest_priced_pizza AS
    SELECT 
        a.name, b.price
    FROM
        pizza_types a
            JOIN
        pizzas b ON a.pizza_type_id = b.pizza_type_id
    ORDER BY price DESC
    LIMIT 1;

SELECT 
    *
FROM
    highest_priced_pizza;

-- Identify the most common pizza size ordered. 
CREATE VIEW pizza_size_ordered AS
    SELECT 
        a.size, COUNT(b.order_details_id) AS order_count
    FROM
        pizzas a
            JOIN
        orders_details b ON a.pizza_id = b.pizza_id
    GROUP BY size
    ORDER BY order_count DESC;

SELECT 
    *
FROM
    pizza_size_ordered;

-- List the top 5 most ordered pizza types along with their quantities.
CREATE VIEW 5_most_ordered_pizza AS
    SELECT 
        a.name, SUM(c.quantity) AS quantity
    FROM
        pizza_types a
            JOIN
        pizzas b ON a.pizza_type_id = b.pizza_type_id
            JOIN
        orders_details c ON c.pizza_id = b.pizza_id
    GROUP BY name
    ORDER BY quantity DESC
    LIMIT 5;

select * from 5_most_ordered_pizza;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
create view quantity_of_each_pizza as
select a.category , sum(c.quantity) as quantity 
from pizza_types a 
join pizzas b 
on a.pizza_type_id = b.pizza_type_id
join orders_details c
on c.pizza_id = b.pizza_id
group by category 
order by quantity desc;

select * from quantity_of_each_pizza;

-- Determine the distribution of orders by hour of the day.
create view orders_by_hour as
select hour(order_Time) as hour , count(order_ID) as orders from orders
group by hour(order_Time)
order by hour(order_Time) asc ;

select * from orders_by_hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
create view category_wise_distribution as
select category, count(name) from pizza_types 
group by category;

select * from category_wise_distribution;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
create view pizzas_ordered_per_day as
select avg(quantity)
from (
select a.order_Date , sum(b.quantity) as quantity  
from orders a 
join orders_details b 
on a.order_ID = b.order_ID
group by a.order_Date) as daily_totals;

select * from pizzas_ordered_per_day;
select * from orders_by_date;

create view orders_by_date as
select a.order_Date , sum(b.quantity) as quantity  
from orders a 
join orders_details b 
on a.order_ID = b.order_ID
group by a.order_Date;

-- Determine the top 3 most ordered pizza types based on revenue.
create view 3_most_ordered_pizza as
select a.name , sum(c.quantity*b.price) as revenue
from pizza_types a
join pizzas b
on a.pizza_type_id = b.pizza_type_id
join orders_details c
on c.pizza_id = b.pizza_id
group by name 
order by revenue desc 
limit 3 ;

select * from 3_most_ordered_pizza;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
create view 3_most_ordered_pizza_types as
select name , revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn 
from 
(select a.category ,a.name , sum(c.quantity*b.price) as revenue 
from pizza_types a 
join pizzas b 
on a.pizza_type_id = b.pizza_type_id
join orders_details c
on c.pizza_id = b.pizza_id
group by category , name ) as a) as b
where rn <=3;

select * from 3_most_ordered_pizza_types;

















