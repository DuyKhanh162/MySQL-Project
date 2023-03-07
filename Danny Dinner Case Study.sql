-- ======================--CASE STUDY QUESTIONS--===============================


-- 1. What is the total amount each customer spent at the restaurant?


select s.customer_id, sum(m.price) as total_amount
from sales s join menu m on s.product_id = m.product_id
group by s.customer_id;


-- 2. How many days has each customer visited the restaurant?


select customer_id, count(distinct order_date) as days_visited
from sales
group by customer_id;


-- 3. What was the first item from the menu purchased by each customer?


with order_rank_cte as
	(
select s.customer_id as customer_id, s.order_date, m.product_name as product_name
	,dense_rank() over(partition by s.customer_id order by s.order_date) as order_rank
from sales s join menu m on s.product_id = m.product_id
	)
    
select customer_id, product_name
from order_rank_cte
where order_rank = 1
group by customer_id, product_name;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?


select m.product_name, count(m.product_id) as most_purchased 
from sales s join menu m on s.product_id = m.product_id
group by m.product_name
order by most_purchased desc
limit 1;


-- 5. Which item was the most popular for each customer?


with item_rank_cte as
	(
select s.customer_id as customer_id, m.product_name as product_name, count(m.product_id) as count_item
	,dense_rank() over(partition by s.customer_id order by count(m.product_id) desc) as item_rank
from sales s join menu m on s.product_id = m.product_id
group by s.customer_id, m.product_name
	)
    
select customer_id, product_name
from item_rank_cte
where item_rank = 1
group by customer_id, product_name;


-- 6. Which item was purchased first by the customer after they became a member?


with item_rank_cte as
	(
select s.customer_id as customer_id, menu.product_name
	, dense_rank() over(partition by s.customer_id order by s.order_date) as item_rank
from sales s 
	join members m on s.customer_id = m.customer_id
    join menu on s.product_id = menu.product_id
where s.order_date > m.join_date
order by s.customer_id, item_rank
	)
    
select customer_id, product_name
from item_rank_cte
where item_rank = 1
group by customer_id, product_name;


-- 7. Which item was purchased just before the customer became a member?


with item_rank_cte as
	(
select s.customer_id as customer_id, menu.product_name
	, dense_rank() over(partition by s.customer_id order by s.order_date desc) as item_rank
from sales s 
	join members m on s.customer_id = m.customer_id
    join menu on s.product_id = menu.product_id
where s.order_date < m.join_date
order by s.customer_id, item_rank
	)
    
select customer_id, product_name
from item_rank_cte
where item_rank = 1
group by customer_id, product_name;


-- 8. What is the total items and amount spent for each member before they became a member?


select s.customer_id, menu.product_name
	, count(distinct s.product_id) as total_items
	, sum(menu.price) as amount_spent
from sales s 
	join menu on s.product_id = menu.product_id
	join members m on s.customer_id = m.customer_id
where s.order_date < m.join_date
group by s.customer_id, menu.product_name;


-- 9. If each $1 spent equates to 10 points and sushi has a x2 points multiplier — how many points would each customer have?


with item_point_cte as
	(
select *,
	case 
		when product_name = 'sushi' then price*20
		else price*10
	end as points
from menu
    )
    
select s.customer_id, sum(i.points) as total_points
from sales s join item_point_cte i on s.product_id = i.product_id
group by s.customer_id;

