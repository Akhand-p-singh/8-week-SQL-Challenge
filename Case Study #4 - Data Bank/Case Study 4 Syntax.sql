					    --  A. Customer Nodes Exploration

--1. How many unique nodes are there on the Data Bank system?

SELECT count(DISTINCT node_id) no_of_nodes
from customer_nodes

--2. What is the number of nodes per region?
SELECT cn.region_id,r.region_name, COUNT(node_id) as no_of_nodes
from customer_nodes cn
join regions r
on cn.region_id = r.region_id
group by cn.region_id, region_name
order by region_id

--3. How many customers are allocated to each region?

SELECT region_id, COUNT(Distinct customer_id) as no_of_customers
from customer_nodes
group by region_id
order by region_id


--4. How many days on average are customers reallocated to a different node?
/*
With cte as 
(
 Select  node_id, datediff(day, start_date, end_date ) day_diff
from customer_nodes
where end_date != '9999-12-31' 

)
SELECT AVG(day_diff)
from cte
*/

--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

					   
					  -- B. Customer Transactions

--1 What is the unique count and total amount for each transaction type?
SELECT txn_type, COUNT( customer_id) as no_of_customer, SUM(txn_amount) as txn_amount
from customer_transactions
group by txn_type



--2 What is the average total historical deposit counts and amounts for all customers?
with cte as (
Select  customer_id,
		COUNT(customer_id) ttl_cust,
		avg(txn_amount) ttl_amt
from customer_transactions
where txn_type = 'deposit'
group by customer_id
)

select AVG(ttl_cust) deposit_count , AVG(ttl_amt) total_money
from cte


--3   For each month - how many Data Bank customers make more than 1 deposit and either
--        1 purchase or 1 withdrawal in a single month?

with cte as (
SELECT 
	MONTH(txn_date) month, customer_id,
	sum(case when txn_type = 'deposit' then 0 else 1 END) as deposit,
	sum(case when txn_type = 'puchase' then 0 else 1 END) as purchase,
	sum(case when txn_type = 'withdrawal' then 0 else 1 END) as withdrawal
from customer_transactions
group by customer_id,MONTH(txn_date)
)

SELECT
  month,
  COUNT(DISTINCT customer_id) AS customer_count
FROM cte
WHERE deposit > 1 
  AND (purchase >= 1 OR withdrawal >= 1)
GROUP BY month
ORDER BY month;

--4 What is the closing balance for each customer at the end of the month?
/*
 SELECT * from customer_transactions
SELECT customer_id, 
     Sum(Case when txn_type = 'deposit' then txn_amount else -txn_amount  end)
from customer_transactions
order by customer_id

*/

--5 What is the percentage of customers who increase their closing balance by more than 5%?
SELECT * from customer_transactions
                   