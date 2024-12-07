show databases;
use walmart_db;
show tables;
select * from walmart;
select count(*) from walmart;
select distinct payment_method from walmart;
select payment_method, count(*) from walmart group by payment_method;
select count(distinct Branch) from walmart;
select min(quantity) from walmart;

-- Business Problems solve 

-- Que-1 Find the different payment method and number of transactions, number of qty sold

select 
	payment_method, 
    count(*) as no_payments, 
    sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Que-2 Identify the highest-rated category in each branch, displaying the branch, category AVG RATING

select 
	Branch,
    category,
    avg(rating) as avg_rating,
    rank() over(partition by Branch order by avg(rating) desc) as ranks
from walmart
group by 1, 2;

-- Que-3 Identify the busiest day for each branch on the number of transactions

select *
from
(
	select
		Branch,
		char(date(date, 'DD/MM/YY'), 'Day') as day_name,
		count(*) as no_transactions,
		rank() over(partition by Branch order by count(*) desc) as ranks
	from walmart
	group by 1, 2
)
where ranks = 1;

-- Que-4 Calculate the total quantity of items sold per payment method, list payment_method and total_quantity

select 
	payment_method,
	sum(quantity) as no_qty_sold
from walmart
group by payment_method; 

-- Que-5 Determine the avg,min, and max rating of products for each city.
-- List the city, avg_rating, min_rating, and max_rating.  

select 
	City,
    category,
    avg(rating) as avg_rating,
    min(rating) as min_rating, 
    max(rating) as max_rating 
from walmart
group by 1, 2;

-- Que-6 Calculate the total profit for each category by considering total_profit as (unit_prices * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.

select 
	category,
    sum(unit_price * quantity * profit_margin) as total_profit
from walmart
group by 1
order by 2 desc;

-- Que-7 Determine the most common payment method for each branch. Display branch and the preferred_payment_method.

with cte
as
(
select
	Branch,
    payment_method,
    count(*) as total_trans,
    rank() over(partition by Branch order by count(*) desc) as ranks
from walmart
group by 1, 2
)
select *
from cte
where ranks = 1;

-- Que-8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which if the shift and number of invoices

select 
	Branch,
case 
		when (hour (time)) < 12 then 'Morning'
		when (hour (time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end day_time,
    count(*) as total_sales
from walmart
group by 1, 2
order by 1, 3 desc;

-- Que-9 Identify 5 branch with highest decrease ratio in revenue compare to last year(Current year 2023 and last year 2022)

select * from walmart;
-- rdr = last_rev - cur_rev / last_rev * 100

SELECT 
    date,
    YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS year_extracted
FROM walmart;

-- 2022 sales
with revenue_2022
as
(
	select 
		Branch,
		sum(total) as revenue
	from walmart
	where YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
	group by 1
),


revenue_2023
as
(
select 
	Branch,
	sum(total) as revenue
from walmart
where YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
group by 1
)

select 
	ls.Branch,
    ls.revenue as last_year_revenue,
    cs.revenue as cs_year_revenue,
    round(
		((ls.revenue - cs.revenue) / ls.revenue * 100),2) as revenue_desc_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.Branch = cs.Branch
where
	ls.revenue > cs.revenue
order by 4 desc
limit 5;