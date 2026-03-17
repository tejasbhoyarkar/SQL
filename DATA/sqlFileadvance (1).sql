USE dql;


-- Joins 
SELECT count(*) FROM customers_sql;
SELECT count(*) FROM orders_sql;
SELECT * FROM products_sql;


SELECT c.city, round(avg(pro.price),0) as avg_price, count(o.order_id) as count         -- o.order_id, c.customer_name, pro.product_name, pro.price, c.city
FROM 
orders_sql  as o
LEFT JOIN 
customers_sql as c
on o.customer_id = c.customer_id

LEFT JOIN 
products_sql as pro
on o.product_id = pro.product_id

GROUP BY c.city
HAVING count>5
ORDER BY avg_price desc
;



-- inner join extaract all the common rows from two table
SELECT c.customer_name, o.amount, o.order_id, c.customer_id        -- o.order_id, c.customer_name, pro.product_name, pro.price, c.city
FROM 
orders_sql  as o
inner JOIN 
customers_sql as c
on o.customer_id = c.customer_id
order by o.order_id;


-- FULL JOIN
SELECT *
FROM 
orders_sql  as o
left JOIN 
customers_sql as c
on o.customer_id = c.customer_id

union

SELECT * 
FROM 
orders_sql  as o
right JOIN 
customers_sql as c
on o.customer_id = c.customer_id;

-- cartesian join
--  3 rows in one tbale and 100 rows in another --> 300 rows
SELECT * 
FROM 
orders_sql  as o
cross JOIN 
customers_sql as c;
-- on o.customer_id = c.customer_id;


SELECT c.city, avg(amount) as avg
FROM 
orders_sql  as o
left JOIN 
customers_sql as c
on o.customer_id = c.customer_id
WHERE o.amount > 2000 and o.amount <4000
GROUP by c.city 
order by avg;



-- SELF JOin
insert into new_table values 
(1, "Pinku", NULL, "IT"),
(2, "Chinku", 1,"IT"),
(3, "Tinku", 1,"IT"),
(4, "Rinku", 2,"IT");

SELect * from new_table;

SELECT e.emp_id,e.name, e.manager_id, m.name as manager_name
from 
new_table as e
left join 
new_table as m 
on e.manager_id = m.emp_id;




-- Table1		  Table2
-- 1 a 10        2 b IT
-- 2 b 20        3 c HR
-- 3 c 25  	  4 d HR

-- INNER JOIN
-- > 2 b IT 20
--   3 c HR 25
   
-- LEFT JOIN					RIGHT JOiN				FULL OUTER JOIN
-- 1 10 NULL					2 b 20
-- 2 20 IT						3 c 25
-- 3 25 HR						4 d NULL

-- FULL OUTER JOIN (left join union right join)
-- 1 a 10 N N N
-- 2 b 20 2 b IT
-- 3 c 25 3 c HR
-- 2 b 20 2 b IT
-- 3 c 25 3 c HR
-- N N N  4 d HR


-- Sub Queries
SELECT * from orders_sql
WHERE amount > (SELECT avg(amount) from orders_sql)
order by amount;

SELECT year from orders_sql group by year;

SELECT * from orders_sql
WHERE year IN (SELECT year from orders_sql group by year)
order by amount;


-- task: get all fearures/columns for top three cities by total amount

SELECT 
    *
FROM
    (SELECT 
        c.city,
            AVG(o.amount) AS avg_amount,
            COUNT(o.order_id) AS count
    FROM
        orders_sql AS o
    LEFT JOIN customers_sql AS c ON o.customer_id = c.customer_id
    GROUP BY c.city
    ORDER BY c.city) AS hey
WHERE
    count = 2;
    
    
    
-- CTE --> common table expression --> its a temp table use with any query it ia an alternate to yoyr sub queries
-- select * from orders_sql where amount <1000 and year = 2025;

with temp as (
select * from orders_sql where amount <1000 and year = 2025)
Select order_id from temp order by order_id;

select order_id from orders_sql  where amount <1000 and year = 2025 order by order_id desc;



with temp as (
Select p.category as cat, avg(o.amount) as amt from orders_sql o left join products_sql p 
on o.product_id = p.product_id
group by p.category)

select * from temp
where amt <5000;



-- Window functions 
-- a 10 17
-- b 11 17 
-- a 5  17
-- b 6  17
-- c 7  14
-- c 7  14 
-- a 2  17         a 17 b 17 c 

-- over (partition by order by range -->  row between unbounded precedent to current

with comb as (
select
	o.order_id,
    o.amount, 
    o.order_date,
    o.year,
    c.customer_id,
    c.customer_name,
    c.city,
    p.product_id,
    p.product_name,
    p.category,
    p.price
from orders_sql o left join customers_sql c on o.customer_id =c.customer_id
left join products_sql p on o.product_id = p.product_id)
Select *, row_number() over(order by product_id) from comb ; 


SELECT *, row_number() over(partition by category order by product_id desc) as cat_count from products_sql;

SELECT *,round(price,0), rank() over(partition by category order by product_name desc) as cat_rank from products_sql;

SELECT *,round(price,0), dense_rank() over(partition by category order by product_name desc) as cat_rank from products_sql;

SELECT *,round(price,0), 
sum(price) over(partition by category order by product_name desc rows between 1 preceding and current row) as cat_rank from products_sql;

-- rank 1 2 2 2 5  3   2  5  7
		1 3 5 7 12 15 17 23 30
        1 3 4 4 7  8   6  7  12
        30 30 30 30 30 30 30 30 
SELECt category, sum(price) from products_sql group by category;


SELECT *,round(price,0), lag(price,3) over(partition by category order by product_name desc) as cat_rank from products_sql;

SELECT year,order_date, amount, 
lag(amount,1,0) over(partition by year order by order_date) as previous
from orders_sql;


create view combine2023 as
SELECT 
    o.order_id,
    o.amount, 
    o.order_date,
    o.year,
    c.customer_id,
    c.customer_name,
    c.city,
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM 
orders_sql  as o
LEFT JOIN 
customers_sql as c
on o.customer_id = c.customer_id
LEFT JOIN 
products_sql as p
on o.product_id = p.product_id where o.year = 2023;


SELECT * FROM combine2023;