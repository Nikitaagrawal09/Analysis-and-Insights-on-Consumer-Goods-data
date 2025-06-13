/*Atliq Finance Analytics*/

/*1. first grab customer codes for Croma india*/

Use gdb0041;

Select * from dim_customer
Where customer like '%Croma%';

/* Now we got the croma customer code = 90002002*/

/*2. Search for transactions for that customer code*/

Select * from fact_sales_monthly
Where customer_code = 90002002;

/*Data needed only for year 2021*/

Select * from fact_sales_monthly
Where customer_code = 90002002 and Year(date) = 2021
order by date desc;

/*Converting calendar year into fiscal year*/

Year(Date_add(date, interval 4 Month))

Select * from fact_sales_monthly
Where customer_code = 90002002 and Year(Date_add(date, interval 4 Month)) = 2021
order by date desc;

/* Using function*/

Select * from fact_sales_monthly
Where customer_code = 90002002 and get_fiscal_year(date) = 2021 and
get_fiscal_quater(date) = "Q4"
order by date
limit 10000;

/*To get the product name and variation, we will be joining product table with fact sales table*/

Select s.date, s.product_code, p.product, p.variant, s.sold_quantity from fact_sales_monthly s
join dim_product p
on p.product_code = s.product_code
Where customer_code = 90002002 and get_fiscal_year(date) = 2021
order by date;

/*To get the gross price and total price, we will be joining this table with gross price table*/

Select s.date, s.product_code, p.product, p.variant, s.sold_quantity,
g.gross_price, Round((g.gross_price*s.sold_quantity),2) as total_price from fact_sales_monthly s
join dim_product p
on p.product_code = s.product_code
join fact_gross_price g
on g.product_code = s.product_code and g.fiscal_year = get_fiscal_year(s.date)
Where customer_code = 90002002 and get_fiscal_year(date) = 2021
order by date;

/*Monthly Gross report for Croma*/

Select s.date, SUM(Round((g.gross_price*s.sold_quantity),2)) as total_price from fact_sales_monthly s
join fact_gross_price g
on g.product_code = s.product_code and g.fiscal_year = get_fiscal_year(s.date)
Where customer_code = 90002002 and get_fiscal_year(date) = 2021
Group by s.date
order by date;

Select * from gross_sales;

/*Yearly gross report for croma*/

Select get_fiscal_year(s.date) as Fiscal_year, SUM(Round((g.gross_price*s.sold_quantity),2)) as total_price from fact_sales_monthly s
join fact_gross_price g
on g.product_code = s.product_code and g.fiscal_year = get_fiscal_year(s.date)
Where customer_code = 90002002
Group by get_fiscal_year(s.date);

/* Stored Procedure: Market Badge
Write a stored proc that can retrieve market badge. i.e. 
if total sold quantity > 5 million that market is considered "Gold" else "Silver"*/

Select SUM(sold_quantity) as total_quantity, c.market
from fact_sales_monthly s
join dim_customer c
on s.customer_code=c.customer_code
Where get_fiscal_year(s.date) = 2021
group by market;

/*Calculating the net sales*/

SELECT 
    	    s.date, 
            s.customer_code,
            s.product_code, 
            p.product, p.variant, 
            s.sold_quantity, 
            g.gross_price as gross_price_per_item,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
            pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
        	ON s.product_code=p.product_code
	JOIN fact_gross_price g
    		ON g.fiscal_year=s.fiscal_year
    		AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
        	ON pre.customer_code = s.customer_code AND
    		pre.fiscal_year=s.fiscal_year
	WHERE 
    		s.fiscal_year=2021     
	LIMIT 1500000;
    
    /*We will be creating view*/
    
    select * from sales_preinv_discount;
    
    SELECT 
    	    s.date, s.fiscal_year,
            s.customer_code, s.market,
            s.product_code, s.product, s.variant,
            s.sold_quantity, s.gross_price_total,
            s.pre_invoice_discount_pct,
            (s.gross_price_total-s.pre_invoice_discount_pct*s.gross_price_total) as net_invoice_sales,
            (po.discounts_pct+po.other_deductions_pct) as post_invoice_discount_pct
	FROM sales_preinv_discount s
	JOIN fact_post_invoice_deductions po
		ON po.customer_code = s.customer_code AND
   		po.product_code = s.product_code AND
   		po.date = s.date;

SELECT *, 
		net_invoice_sales*(1-post_invoice_discount_pct) as net_sales
	FROM sales_postinv;

/*Generate report for top 5 market based on their net sales in million in 2021*/

Select market, Round(SUM(net_sales)/1000000,2) as Net_sales_million from net_sales
Where fiscal_year = 2021
Group by market
order by net_sales_million desc
limit 5;

/*Generate report for top 5 customer based on their net sales in million in 2021*/

Select c.customer, Round(SUM(net_sales)/1000000,2) as Net_sales_million from net_sales n
Join dim_customer c
on n.customer_code = c.customer_code
Where fiscal_year = 2021
Group by c.customer
order by net_sales_million desc
limit 5;

/*Generate report for top 5 product based on their net sales in million in 2021*/

Select p.product, Round(SUM(net_sales)/1000000,2) as Net_sales_million from net_sales n
Join dim_product p
on n.product_code = p.product_code
Where fiscal_year = 2021
Group by p.product
order by net_sales_million desc
limit 5;

/*Top 10 markets by % net sales for 2021*/

With CTE1 as
(Select c.market, Round(SUM(net_sales)/1000000,2) as Net_sales_million from net_sales n
Join dim_customer c
on n.customer_code = c.customer_code
Where fiscal_year = 2021
Group by c.market)

Select market ,
net_sales_million*100/Sum(Net_sales_million) over() as pct
from CTE1
order by pct desc
limit 10;

/*top N products in each divison by their quantity sold in a given financial year*/

With CTE1 as (Select p.division, p.product, Sum(f.sold_quantity) as total_quantity
				from dim_product p
				join fact_sales_monthly f
				on p.product_code = f.Product_code
				Where f.fiscal_year = 2021
				group by p.product, p.division
				order by total_quantity desc),
                
CTE2 as (Select *,
dense_rank() over(partition by division order by total_quantity) as drk
from CTE1)

Select * from cte2
Where drk <=3;

/*Top 2 markets in every region by their gross sales amount in FY=2021*/

With CTE1 as (Select 
					c.market, 
                    c.region, 
                    Round(SUM((g.gross_price*s.sold_quantity)/1000000),2) as gross_sale_amount
				from dim_customer c
				join fact_sales_monthly s
				on c.customer_code = s.customer_code
				join fact_gross_price g
				on s.product_code = g.product_code
				and s.fiscal_year = g.fiscal_year
				Where s.fiscal_year = 2021
				Group by c.market, c.region),

CTE2 as (
			Select *,
					dense_rank() over (partition by region order by gross_sale_amount desc) as drk
			from CTE1)

Select * from CTE2
where drk <= 2;

/*Region wise % net sales breakdown by customers in respective region*/

With CTE1 as
(Select c.customer, c.region, Round(SUM(net_sales)/1000000,2) as Net_sales_million from net_sales n
Join dim_customer c
on n.customer_code = c.customer_code
Where fiscal_year = 2021
Group by c.region, c.customer),

CTE2 as (Select * ,
net_sales_million*100/Sum(Net_sales_million) over(partition by region) as pct
from CTE1)

Select *,
dense_rank() over(partition by region order by pct desc) as drk
from CTE2

/*Creating new table merging forecast and fact*/

	create table fact_act_est
	(
        	select 
                    s.date as date,
                    s.fiscal_year as fiscal_year,
                    s.product_code as product_code,
                    s.customer_code as customer_code,
                    s.sold_quantity as sold_quantity,
                    f.forecast_quantity as forecast_quantity
        	from 
                    fact_sales_monthly s
        	left join fact_forecast_monthly f 
        	using (date, customer_code, product_code)
	)
	union
	(
        	select 
                    f.date as date,
                    f.fiscal_year as fiscal_year,
                    f.product_code as product_code,
                    f.customer_code as customer_code,
                    s.sold_quantity as sold_quantity,
                    f.forecast_quantity as forecast_quantity
        	from 
		    fact_forecast_monthly  f
        	left join fact_sales_monthly s 
        	using (date, customer_code, product_code)
	);

select * from fact_act_est;

SET SQL_SAFE_UPDATES = 0;


update fact_act_est
	set sold_quantity = 0
	where sold_quantity is null;
    
update fact_act_est
	set forecast_quantity = 0
	where forecast_quantity is null;
    
/*Creating forecast report*/

with forecast_err_table as (
             select
                  s.customer_code as customer_code,
                  c.customer as customer_name,
                  c.market as market,
                  sum(s.sold_quantity) as total_sold_qty,
                  sum(s.forecast_quantity) as total_forecast_qty,
                  sum(s.forecast_quantity-s.sold_quantity) as net_error,
                  round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
                  sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
                  round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
             from fact_act_est s
             join dim_customer c
             on s.customer_code = c.customer_code
             where s.fiscal_year=2021
             group by customer_code
	)
	select 
            *,
            if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
	from forecast_err_table
        order by forecast_accuracy desc;

