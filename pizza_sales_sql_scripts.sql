-- Configuration info------------------------------------------------------------------------------------------------
--DB Name - MyPortfolioProjects
--Table Name - Pizza_Sales

---------------------------------------------------------------------------------------------------------------------

-- Table Modifications-----------------------------------------------------------------------------------------------
-- Data types changes------------------------------------------------------------------------------------------------

select *
from MyPortfolioProjects.dbo.Pizza_Sales;

alter table MyPortfolioProjects.dbo.Pizza_Sales
alter column 
	pizza_id int not null;

alter table MyPortfolioProjects.dbo.Pizza_Sales
alter column 
	order_id int not null;

alter table MyPortfolioProjects.dbo.Pizza_Sales
alter column 
	pizza_name_id nvarchar(100) not null;

alter table MyPortfolioProjects.dbo.Pizza_Sales
alter column 
	quantity tinyint not null;

alter table MyPortfolioProjects.dbo.Pizza_Sales
alter column 
	order_date date;

alter table MyPortfolioProjects.dbo.Pizza_Sales
alter column 
	order_time time(7);
	
---------------------------------------------------------------------------------------------------------------------
select * 
from MyPortfolioProjects..Pizza_Sales;

--verify row counts
select count(*)
from MyPortfolioProjects..Pizza_Sales;



------------------------------------------KPI Requirements------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------



 -- Total Revenue------------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------------------

 select round(sum(unit_price* quantity),2) as 'Total_Revenue'
 from MyPortfolioProjects..Pizza_Sales;
 --OR
  select round(sum(total_price),2) as 'Total_Revenue'
 from MyPortfolioProjects..Pizza_Sales;

 -- Average Order Value -----------------------------------------------------------------------------------------------
 -- Average Order Value = Total Revenue / Total Orders
 ----------------------------------------------------------------------------------------------------------------------

 select round(sum(unit_price* quantity) / count(distinct order_id),2) as 'Avg_Order_Value'
 from MyPortfolioProjects..Pizza_Sales;

 -- Total pizzas sold---------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------

 select sum(quantity) as 'Total_Pizzas_Sold'
 from MyPortfolioProjects..Pizza_Sales;

 -- Total orders--------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------

 select count(distinct order_id) as 'Total_Order_Count'
 from  MyPortfolioProjects..Pizza_Sales;

 -- Average Pizzas Per Order --------------------------------------------------------------------------------------------
 -- Average Pizzas Per Order = Total Pizzas Sold / Total Orders
 ------------------------------------------------------------------------------------------------------------------------

 select round (cast (sum(quantity) as float) / count(distinct order_id),2) as 'Avg_Pizzas_Per_Order'
 from  MyPortfolioProjects..Pizza_Sales;


 ------------------------------------------Charts Requirements-----------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------
 select * from MyPortfolioProjects..Pizza_Sales;

 -- Daily Trend for total orders----------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------------
 
 -- group by - date
 select order_date, count(distinct order_id)
 from MyPortfolioProjects..Pizza_Sales
 group by order_date
 order by order_date;

 -- group by - day of the week (Monday...)
 select DATENAME(WEEKDAY, order_date) AS 'Day_Of_Week', count(distinct order_id) as 'Order_Count'
 from MyPortfolioProjects..Pizza_Sales
 group by DATENAME(WEEKDAY, order_date), DATEPART(WEEKDAY,order_date)
 order by DATEPART(WEEKDAY,order_date);
 --order by Order_Count desc;

 -- verify order counts are correct
 WITH dw_order_cnt_CTE AS 
 (
	 select DATENAME(WEEKDAY, order_date) AS 'Day_Of_Week', count(distinct order_id) as 'Order_Count'
	 from MyPortfolioProjects..Pizza_Sales
	 group by DATENAME(WEEKDAY, order_date)
	 
 )
 SELECT sum(Order_Count)
 FROM dw_order_cnt_CTE;


 -- Monthly Trend for total orders----------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------
 select DATENAME(MONTH, order_date) AS 'Month', count(distinct order_id) as 'Order_Count' 
 from MyPortfolioProjects..Pizza_Sales
 group by DATENAME(MONTH, order_date), DATEPART(MONTH,order_date)
 order by Order_Count desc;


 -- Percentage of sales by pizza category--------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------
  select * from MyPortfolioProjects..Pizza_Sales;

  
  -- with CTE
  WITH percent_sales_by_cat_CTE AS
  (
    select pizza_category, sum(total_price) as 'total_revenue' 
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_category
  )
  select pizza_category, total_revenue, total_revenue / sum(total_revenue) OVER() * 100 as 'sales_percentage'
  from percent_sales_by_cat_CTE;

  --more efficient one line - query - without using CTE - using window functions
    select pizza_category, sum(total_price) as 'total_revenue',  sum( sum(total_price)) over() as 'grand_total_revenue',  round( sum(total_price) / sum( sum(total_price)) over()  * 100 ,2) as 'sales_percentage'
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_category
	order by sales_percentage desc;

  -- filtering the result by months 
    select pizza_category, sum(total_price) as 'total_revenue',  sum( sum(total_price)) over() as 'grand_total_revenue',  round( sum(total_price) / sum( sum(total_price)) over()  * 100 ,2) as 'sales_percentage'
	from MyPortfolioProjects..Pizza_Sales
	where MONTH(order_date) = 1
	group by pizza_category
	order by sales_percentage desc;



 -- Percentage of sales by pizza size------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------
   select * from MyPortfolioProjects..Pizza_Sales;


   select pizza_size, sum(total_price) as 'total_revenue',  sum( sum(total_price)) over() as 'grand_total_revenue',  round( sum(total_price) / sum( sum(total_price)) over()  * 100 ,2) as 'sales_percentage'
   from MyPortfolioProjects..Pizza_Sales
   group by pizza_size
   order by sales_percentage desc;

   --filter result by first quater
   select pizza_size, sum(total_price) as 'total_revenue',  sum( sum(total_price)) over() as 'grand_total_revenue',  round( sum(total_price) / sum( sum(total_price)) over()  * 100 ,2) as 'sales_percentage'
   from MyPortfolioProjects..Pizza_Sales
   where DATEPART(QUARTER,order_date) = 1
   group by pizza_size
   order by sales_percentage desc;


   -- Total pizzas sold by pizza category---------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------------------

    select pizza_category, sum(quantity) as 'total_pizzas_sold'
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_category
	order by total_pizzas_sold desc;	


   -- Top 5 best sellers by revenue, total quantity and total orders------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------------------------------------------------------------------
   

    -- by revenue
	select top 5 pizza_name, sum(total_price) as 'total_revenue'
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_name
	order by total_revenue desc;	

	-- by total pizzas sold(quantity)
	select top 5 pizza_name, sum(quantity) as 'total_pizzas_sold'
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_name
	order by total_pizzas_sold desc;	

	-- by total orders
	select top 5 pizza_name, count(distinct order_id) as 'total_order_count'
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_name
	order by total_order_count desc;	


   -- Bottom 5 worse sellers by revenue, total quantity and total orders- ------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------------------------------------------
    -- by revenue
	select top 5 pizza_name, sum(total_price) as 'total_revenue'
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_name
	order by total_revenue asc;	

	-- by total pizzas sold(quantity)
	select top 5 pizza_name, sum(quantity) as 'total_pizzas_sold'
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_name
	order by total_pizzas_sold asc;	

	-- by total orders
	select top 5 pizza_name, count(distinct order_id) as 'total_order_count'
	from MyPortfolioProjects..Pizza_Sales
	group by pizza_name
	order by total_order_count asc;		