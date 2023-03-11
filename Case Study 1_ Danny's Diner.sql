
CREATE TABLE IF NOT EXISTS sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

Select * from sales;

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select * from sales;
  select * from menu;
  select * from members;  
  
  #Master_Table
  
  create table  master_table(
  select s.customer_id,s.order_date,s.product_id, m.product_name, m.price, mb.join_date,
  case
	   when s.order_date >= mb.join_date then 'Y'
       else 'N' end as `Member`
  from sales as s left join menu as m on s.product_id = m.product_id
 left join members as mb on s.customer_id = mb.customer_id);
 
  select * from master_table;
  
 
 #------------------------Task-1---------------------------------------------------
 Q.1) What is the total amount each customer spent at the restaurant?
 
 select customer_id, sum(price) as Total_Amount from master_table
 group by 1;
 #-----------------------Task-2----------------------------------------------------
 Q.2) How many days has each customer visited the restaurant?

 select customer_id ,count(distinct(order_date)) from master_table
 group by 1;
 #-----------------------Task-3----------------------------------------------------
 Q.3) What was the first item from the menu purchased by each customer?

 with sales_cte as(
 select customer_id ,order_date,product_name,
 dense_rank() over(partition by customer_id order by order_date) as ranks
 from master_table)
 select * from sales_cte
 where ranks = 1
 group by 1,3;
 
  #-----------------------Task-4-----------------------------------------------------
 Q.4) What is the most purchased item on the menu and how many times was it purchased by all customers?
  
  select product_name, count(product_name) as top from master_table
  group by product_name order by top desc limit 1;
  
  #-----------------------Task-5------------------------------------------------------
 Q.5) Which item was the most popular for each customer?
  
  select * from(
  select customer_id,product_name, count(product_name) as Popular_Item, 
  dense_rank() over( partition by customer_id order by count(product_name) desc) as ranks from master_table 
  group by product_name,customer_id) as favourite where ranks = 1 order by customer_id;
  
  #-----------------------Task-6-----------------------------------------------------
 Q.6) Which item was purchased first by the customer after they became a member?

  select * from (select customer_id, product_name ,order_date,
  dense_rank() over(partition by customer_id order by product_name) as rank1
 from master_table where order_date >= join_date group by customer_id ) as first_order where rank1 = 1;
 
   #-----------------------Task-7---------------------------------------------------------------------------------------------
  Q.7) Which item was purchased just before the customer became a member?
   select * from (select customer_id, product_name ,order_date,
  dense_rank() over(partition by customer_id order by order_date desc) as rank1
 from master_table where order_date < join_date  ) as just_before_order where rank1 = 1;
 
  #-----------------------Task-8-----------------------------------------------------------------------------------------------
  Q.8) What is the total items and amount spent for each member before they became a member?

select customer_id, count(product_name) as Total_Items, sum(price) as Total_Amount
 from master_table where order_date < join_date group by 1;
 
  #-----------------------Task-9------------------------------------------------------------------------------------------------
  Q.9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
  
   select customer_id, sum(case
							    when product_id = 1 then price * 20
								else price*10
								end) as Total_Points 
	from master_table group by customer_id;
  
  #-----------------------Task-10------------------------------------------------------------------------------------------------
  Q.10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
  not just sushi - how many points do customer A and B have at the end of January?
  
  select * from (select customer_id, order_date, product_name, price, join_date, 
  adddate(join_date,interval 6 day) as valid_date, LAST_DAY(order_date) as lastdate,
  monthname(order_date) as Month_name,
  sum(case
			when product_name='sushi' then price*20
            when order_date between join_date and 'valid_date' then price*20
            else price*10 end) as Points
  from master_table group by customer_id ,product_name,valid_date)as Point_table where order_date<lastdate;
  
   #-----------------------Bonous Question-2------------------------------------------------------------------------------------
   
   select *, case 
					when `member`='N' then 'NULL'
                    else rank() over( partition by customer_id,`member` order by order_date) end as Ranking
	from master_table;
