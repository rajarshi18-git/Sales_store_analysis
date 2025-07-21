DROP TABLE IF EXISTS sales_store;
CREATE TABLE sales_store(
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30),
customer_age INT,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR(15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR (15)
);

SELECT*FROM sales_store;

COPY sales_store
FROM 'D:\sales_store_data.csv'
DELIMITER ','
CSV HEADER

-- data cleaning .

SELECT*FROM sales_store

SELECT*INTO sales FROM sales_store
SELECT*FROM sales
DROP TABLE IF EXISTS sales

-- check for duplicate.
SELECT transaction_id,COUNT(*)
FROM sales
GROUP BY transaction_id
HAVING COUNT(transaction_id)>1

--0r,
CREATE TEMP TABLE temp_sales AS
SELECT*
FROM(
SELECT*,
ROW_NUMBER()OVER (PARTITION BY transaction_id  )AS rn
FROM sales)AS sub 
WHERE rn=1;

DELETE FROM sales;

 INSERT INTO sales 
 SELECT 
transaction_id,customer_id ,customer_name,customer_age,gender,product_id ,product_name ,
product_category ,quantiy,prce ,payment_mode,purchase_date ,time_of_purchase ,status
FROM temp_sales;

-- correction of headings.
SELECT*FROM sales
ALTER TABLE sales
RENAME COLUMN quantiy TO quantity;
ALTER TABLE sales
RENAME COLUMN prce TO price

--check null values 

SELECT *FROM sales 
WHERE transaction_id IS NULL 
OR customer_id IS NULL
OR customer_name IS NULL 
OR customer_age IS NULL
OR gender IS NULL
OR product_id IS NULL
OR product_name IS NULL
OR product_category IS NULL 
OR quantity IS NULL
OR price IS NULL 
OR payment_mode IS NULL
OR purchase_date IS NULL 
OR time_of_purchase IS NULL 
OR status IS NULL

DELETE FROM sales WHERE transaction_id IS NULL

SELECT *FROM sales 
WHERE customer_name ='Ehsaan Ram'

UPDATE sales
SET customer_id ='CUST9494'
WHERE transaction_id  ='TXN977900'

SELECT *FROM sales 
WHERE customer_name ='Damini Raju'

UPDATE sales
SET customer_id ='CUST1401'
WHERE transaction_id  ='TXN985663'

SELECT *FROM sales
WHERE customer_id ='CUST1003'

UPDATE sales
SET customer_name ='Mahika Saini',customer_age=35,gender= 'Male'
WHERE customer_id ='CUST1003'

--data cleaning 
SELECT DISTINCT gender FROM sales 

UPDATE sales 
SET gender ='M'
WHERE gender ='Male'

UPDATE sales 
SET gender ='F'
WHERE gender ='Female'

SELECT DISTINCT payment_mode FROM sales
UPDATE  payment_mode
SET payment_mode ='Credit Card'
WHERE payment_mode ='CC'

SELECT *FROM sales
-- solving business quetions.
-- Q1. what are the top 5 most selling products by quantity?
SELECT product_name ,SUM(quantity)AS total_count
FROM sales 
WHERE status = 'delivered'
GROUP BY product_name 
ORDER BY total_count DESC 
LIMIT 5;
-- INSIGHTS : from the qs we get which are the most demanding products . it helps to 
--            prioritize stock and boost sales through targrted promotions

-- Q2. which products are most frequently canceled ?
SELECT *FROM sales;

 SELECT product_name,status,COUNT(status) AS product_status
 FROM sales
 WHERE status ='cancelled'
 GROUP BY product_name,status
 ORDER BY product_status DESC
 -- frequent cancellation afectrevenue and customer trust .
 -- it helps to identify poorperforming products to improve the qulity or remove from 
 -- catalog.

 -- Q3. what time of the day has the highest number of purchase.
 SELECT 
 CASE
      WHEN EXTRACT(HOUR FROM  time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
      WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
      WHEN EXTRACT(HOUR FROM  time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
      WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
	END AS time_of_day,
	COUNT(*)AS total_order
	FROM sales 
	GROUP BY
	CASE
	WHEN EXTRACT(HOUR FROM  time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
      WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
      WHEN EXTRACT(HOUR FROM  time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
      WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
      
	END 
    ORDER BY total_order DESC;
 -- we can find peak sales time .
 -- optimize staffing, promotions,and server loads .

 -- Q4.who are the top 5 highest spending customer.
 
SELECT customer_name,SUM(quantity * price)AS total_spending
FROM sales
GROUP BY customer_name
ORDER BY total_spending DESC
LIMIT 5
 -- identify VIP customer ,we can provide them offer,discount.
 
 -- Q5. which product categories generate the highest revenue.
SELECT product_category,SUM(quantity * price)AS total_rev
FROM sales 
GROUP BY product_category
ORDER BY total_rev DESC
LIMIT 1
-- refine producr stratagy ,supply chain management promotion 
-- allowing the business to invest more in high margin or high demanded categories

-- Q6.What is the return /cancellation rate per product category? 
 
-- for cancelation 
SELECT product_category ,
COUNT(CASE WHEN status='cancelled' THEN 1 END )*100/COUNT(*)AS cancelled_percentage
FROM sales 
GROUP BY product_category
ORDER BY cancelled_percentage DESC 
-- for return 
SELECT product_category ,
COUNT(CASE WHEN status='returned' THEN 1 END )*100/COUNT(*)AS returned_percentage
FROM sales 
GROUP BY product_category
ORDER BY returned_percentage DESC

-- monitor dissatisfaction trends per category.help to identify and fixed category.

-- Q7. WHat is the most preffered payment mode .

SELECT 
payment_mode,COUNT(*)AS preferred_mode 
FROM sales 
GROUP BY payment_mode
ORDER BY preferred_mode DESC
LIMIT 1
-- insights: know which payment option customers prefer most .
       -- streamline payment processing ,prioritizing popular modes.

-- Q8.How does age group affect purchasing behaviour?

 SELECT 
 CASE
      WHEN customer_age BETWEEN 18 AND 30 THEN 'young'
      WHEN customer_age BETWEEN 31 AND 50 THEN 'middle age '
	  WHEN customer_age BETWEEN 51 AND 60 THEN 'senior'
	END AS age_group, SUM(price*quantity)AS total_purchase
	FROM sales 
	GROUP BY CASE
      WHEN customer_age BETWEEN 18 AND 30 THEN 'young'
      WHEN customer_age BETWEEN 31 AND 50 THEN 'middle age '
	  WHEN customer_age BETWEEN 51 AND 60 THEN 'senior'
	END
	ORDER BY total_purchase DESC

	-- Q9. what is the monthly trend?
	SELECT*FROM sales
	

SELECT 
       EXTRACT (YEAR FROM purchase_date)AS years,
       EXTRACT (MONTH FROM purchase_date)AS months,
	   SUM(price*quantity)AS total_sales
	   FROM sales
	   GROUP BY 1,2
	   ORDER BY 2 

--insights: sales flactuation can easily defined,plan inventory,and marketing stratagy .

-- Q10.gender wise product category buing behaviour?

-- method1
SELECT gender,product_category,COUNT(product_category)AS total_purchase
FROM sales
GROUP BY gender,product_category
ORDER BY gender 










