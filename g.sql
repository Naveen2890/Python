CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20), 
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    discount DECIMAL(7,2),
    sales_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);
select * from df_orders

-- find top 10 heighest revenue genrated products
select product_id,sum(sales_price) as sales
from df_orders
group by product_id
order by sales desc

--top 5 heighest selling products in each region
with cte as(select region,product_id,sum(sales_price) as sales
from df_orders
group by region,product_id)
select * from (
	select *
	, row_number() over (partition by region order by sales desc) as rn
from cte) as A
	where rn<=5;

--find mont over month growth comparision from 2022 and 2023 sales eg:jan2022 vs jan2023
with cte as(select extract(year from order_date) as order_year,extract(month from order_date) as order_month,sum(sales_price) as sales
	from df_orders
group by order_year,order_month
--order by order_year,order_month
	)
select order_month
,sum(case when order_year=2022 then sales else 0 end) as sales_2022
,sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

--for each catagory which month had heighest sales
with cte as (select category,TO_CHAR(order_date,'yyyymm') as order_Ymonth,sum(sales_price) as sales
	from df_orders
group by category,order_Ymonth
order by category,sales desc)
	select * from(
select * ,
row_number() over(partition by category order by sales desc) as rn
from cte)
where rn=1;

--which sub category had highest growth by profit in 2023 compare to 2022
with cte as(select sub_category,extract(year from order_date) as order_year,sum(sales_price) as sales
from df_orders
group by sub_category,order_year)
, cte2 as(
select sub_category,
sum(case when order_year=2022 then sales else 0 end) as sales2022,
sum(case when order_year=2023 then sales else 0 end) as sales2023
from cte
group by sub_category
order by sub_category
	)
select * 
,(sales2023-sales2022)*100/sales2022 as np
from cte2
order by np desc limit 1