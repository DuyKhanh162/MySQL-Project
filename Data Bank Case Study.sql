-- ======================--CASE STUDY QUESTIONS--===============================


-- 1. How many unique nodes are there on the Data Bank system?


select count(distinct node_id) as unique_nodes
from customer_nodes;


-- 2. What is the number of nodes per region?


select r.region_id, r.region_name, count(n.node_id) as total_nodes
from regions r 
	join customer_nodes n on r.region_id = n.region_id
group by r.region_name, r.region_id
order by r.region_id, r.region_name;


-- 3. How many customers are allocated to each region?


select r.region_id, r.region_name, count(distinct n.customer_id) as customers_allocated
from regions r
	join customer_nodes n on r.region_id = n.region_id
group by r.region_id, r.region_name;


-- 4. How many days on average are customers reallocated to a different node?


select round(avg(datediff(end_date, start_date)), 2) as avg_days_reallocated
from customer_nodes
where year(end_date) != 9999;


-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?


-- UPDATING


-- 6. What is the unique count and total amount for each transaction type?


select txn_type
	, count(customer_id) as unique_count
    , concat('$' ,sum(txn_amount)) as total_amount
from customer_transactions
group by txn_type;


-- 7. What is the average total historical deposit counts and amounts for all customers?


select 
	round(count(customer_id)/ (select count(distinct customer_id) from customer_transactions)) as avg_deposit
    , concat('$' ,round(avg(txn_amount), 2)) as avg_amount
from customer_transactions
where txn_type = 'deposit';


-- 8. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?


with transactions_activites_cte as
	(
select customer_id
	, month(txn_date) as txn_month
    , sum(if(txn_type = 'deposit', 1, 0)) as deposit_count
    , sum(if(txn_type = 'purchase', 1, 0)) as purchase_count
    , sum(if(txn_type = 'withdrawal', 1, 0)) as withdrawal_count
from customer_transactions
group by customer_id, txn_month
	)
    
select txn_month, count(customer_id) as total_customer
from transactions_activites_cte
where deposit_count > 1 and (purchase_count = 1 or withdrawal_count = 1)
group by txn_month
order by txn_month;


-- 9. What is the closing balance for each customer at the end of the month?


with net_transactions_cte as
	(
select customer_id
	, month(txn_date) as txn_month
    , sum(case
		when txn_type = 'deposit' then txn_amount
        else -txn_amount
	end) as net_transaction_amount
from customer_transactions
group by customer_id, txn_month
order by customer_id
	)

select *
	, sum(net_transaction_amount) 
		over (partition by customer_id order by txn_month rows between unbounded preceding and current row) as closing_balance
from net_transactions_cte


-- 10. What is the percentage of customers who increase their closing balance by more than 5%?


-- UPDATING

