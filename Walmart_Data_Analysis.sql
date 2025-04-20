-- Businees Problems


	 -- 1. What are the different payment methods, and how many transactions and items were sold with each method?

select 
	payment_method,
	count(*) as no_payments,
    sum(quantity) as no_of_qty_sold
from walmart
group by payment_method ;


	-- 2. Which category received the highest average rating in each branch?

SELECT * 
FROM (
    SELECT 
        branch, 
        category, 
        AVG(rating) AS avg_rating, 
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS _rank 
    FROM walmart 
    GROUP BY branch, category
) AS ranked_data
WHERE _rank = 1;

	-- 3. What is the busiest day of the week for each branch based on transaction volume?

SELECT * 
FROM (
    SELECT 
        branch,
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
        COUNT(*) AS no_of_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS _rank
    FROM walmart
    GROUP BY branch, day_name
) AS ranked_data
WHERE _rank = 1;

	-- 4. How many items were sold through each payment method, list payment method and total quantity?
    
select 
	payment_method,
    sum(quantity) as no_of_qty_sold
from walmart
group by payment_method ;

		-- 5.  What are the average, minimum, and maximum ratings of category in each city,
		-- list the city, average_rating, min_rating and max_rating

select 
    city,
    category,
    min(rating)as min_rating,
    max(rating) as max_rating,
    avg(rating) as AVG_rating
from walmart
group by city, category;
    


	-- 6.What is the total profit for each category, ranked from highest to lowest?
    
select
     category,
     sum(total) as revenue,
     sum(total*profit_margin) as profit
from walmart
group by category;

	-- 7.What is the most frequently used payment method in each branch?
  
with cte
as
(
select 
		branch,
        payment_method,
        Count(*) as total_transactions,
        rank() over(partition by branch order by count(*) desc) as _rank
	from walmart
    group by Branch, payment_method
)
select *
from cte
where _rank = 1;
    
		-- 8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
        
select 
    lower(branch) as branch,
    lower(day_time) as day_time, 
    count(*) as total_transactions
from (
    select 
        branch,
        case 
            when hour(time(time)) < 12 then 'morning'
            when hour(time(time)) between 12 and 17 then 'afternoon'
            else 'evening'
        end as day_time
    from walmart
) as time_slots
group by lower(branch), lower(day_time)
order by branch, total_transactions desc;



	-- 9. Which branches experienced the largest decrease in revenue compared to the previous year?
   
  
  
select *, 
       extract(year from str_to_date(date, '%d/%m/%y')) as year_extracted
from walmart;

with revenue_2022 as (
    select 
        branch, 
        sum(total) as revenue_2022
    from walmart
    where extract(year from str_to_date(date, '%d/%m/%y')) = 2022
    group by branch
),
revenue_2023 as (
    select 
        branch, 
        sum(total) as revenue_2023
    from walmart
    where extract(year from str_to_date(date, '%d/%m/%y')) = 2023
    group by branch
)
select 
    r22.branch,
    r22.revenue_2022,
    r23.revenue_2023,
    r23.revenue_2023 - r22.revenue_2022 as revenue_growth,
    round((r22.revenue_2022 - r23.revenue_2023) / r22.revenue_2022 * 100, 2) as revenue_drop_percent
from revenue_2022 as r22
join revenue_2023 as r23 
    on r22.branch = r23.branch
where r22.revenue_2022 > r23.revenue_2023
order by revenue_drop_percent desc
limit 5;

    
    


    


