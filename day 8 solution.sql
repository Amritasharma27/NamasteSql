--1- write a sql to find top 3 products in each category by highest rolling 3 months total sales for Jan 2020.
	 with xxx as (
		select category,
			   product_id,
			   datepart(year,order_date) as yo,
			   datepart(month,order_date) as mo, 
			   sum(sales) as sales
		from orders 
		group by category,
				 product_id,
				 datepart(year,order_date),
				 datepart(month,order_date))
	,yyyy as (
		select *,
			  sum(sales) over(partition by category,
			  product_id order by yo,
			  mo rows between 2 preceding and current row ) as roll3_sales
		from xxx)
	select * from (
		select *,
				rank() over(partition by category order by roll3_sales desc) as rn from yyyy 
		where yo=2020 and mo=1) A
	where rn<=3

--2- write a query to find products for which month over month sales has never declined.
	 with xxx as (
		select product_id,
			   datepart(year,order_date) as yo,
			   datepart(month,order_date) as mo, sum(sales) as sales
		from orders 
		group by product_id,
				 datepart(year,order_date),
				 datepart(month,order_date))
	,yyyy as (
		select *,
			   lag(sales,1,0) over(partition by product_id order by yo,mo) as prev_sales
		from xxx)
	select distinct product_id 
	from yyyy 
	where product_id not in(
						select product_id 
						from yyyy 
						where sales<prev_sales 
						group by product_id)

/*3- write a query to find month wise sales for each category for months where sales is more than 
	 the combined sales of previous 2 months for that category.*/
	 with xxx as (
		select category,
			   datepart(year,order_date) as yo,
			   datepart(month,order_date) as mo, 
			   sum(sales) as sales
		from orders 
		group by category,
				 datepart(year,order_date),
				 datepart(month,order_date))
	,yyyy as (
		select *,
				sum(sales) over(partition by category order by yo,mo rows between 2 preceding and 1 preceding ) as prev2_sales
		from xxx)
	select * 
	from yyyy 
	where  sales>prev2_sales


