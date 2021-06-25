/*
Group MA1
Ahmed Mohamed H A Nassar - 28901797
Grace Nathania - 30241510
Kelvin Kan Jia Yaw - 29764920

Submitted on: November 4 2020

Data Import and Cleaning
1. null value in category_id (category)
2. duplicate data (product)
3. null value in product_name and product_price (product)
4. there is a staff with negative salary and working hours, address_id also does not exist for STAFF_ID: ST051 (staff)
5. duplicate data (customer)
6. there is an order from year 2021 that is delivered in year 2019 for SC_ORDERID: S1905 (school_canteen_order)
7. there is a delivery date that is smaller than order date and payment type does not exist for SC_ORDERID: S1906.
   Besides that, its type_id doenst exist in paymet_type entity (school_canteen_order)
8. duplicate ca_orderid (catering_order)
9. there is an order from year 2035 (catering_order)
10. CA_ORDERID: C1890 doestn't exist as well as the ordered product (catering_orderline)
11. Product Review Error, FK product_id does not exist in parent table (for review_no: R1606)
*/
--drop tables commands 
DROP TABLE category CASCADE CONSTRAINTS; 
DROP TABLE product_category CASCADE CONSTRAINTS; 
DROP TABLE product CASCADE CONSTRAINTS; 
DROP TABLE product_review CASCADE CONSTRAINTS; 
DROP TABLE school_canteen_orderline CASCADE CONSTRAINTS; 
DROP TABLE catering_orderline CASCADE CONSTRAINTS; 
DROP TABLE catering_order CASCADE CONSTRAINTS; 
DROP TABLE delivery_type CASCADE CONSTRAINTS; 
DROP TABLE school_canteen_order CASCADE CONSTRAINTS; 
DROP TABLE promotion CASCADE CONSTRAINTS; 
DROP TABLE order_status CASCADE CONSTRAINTS; 
DROP TABLE payment_type CASCADE CONSTRAINTS; 
DROP TABLE delivery_provider CASCADE CONSTRAINTS; 
DROP TABLE staff CASCADE CONSTRAINTS; 
DROP TABLE customer_type CASCADE CONSTRAINTS; 
DROP TABLE address CASCADE CONSTRAINTS; 
DROP TABLE customer CASCADE CONSTRAINTS; 

--creating local tables 
---------------- category (1 Error: null value in category_id) ----------------- 
-- select the whole table to see if there is an error (the table is small) 
desc monchef.category; 
SELECT * 
FROM   monchef.category; 

CREATE TABLE category AS 
  SELECT * 
  FROM   monchef.category 
  WHERE  category_id IS NOT NULL 
         AND category_description != 'Unknown'; 

---------------------------------- product_category (OK) ----------------------- 
desc monchef.product_category; 
-- check if any duplicates records 
SELECT product_id, 
       category_id, 
       Count(*) 
FROM   monchef.product_category 
GROUP  BY product_id, 
          category_id 
HAVING Count(*) > 1; 

CREATE TABLE product_category AS 
  SELECT * 
  FROM   monchef.product_category; 

---------------------------------- product (2 Errors) -------------------------- 
SELECT * 
FROM   monchef.product; 

-- check if there is any duplicate data 
SELECT Count (DISTINCT product_id) 
FROM   monchef.product; -- 191 

SELECT Count (*) 
FROM   monchef.product; -- 195: duplicate exist 

SELECT product_id, 
       product_name, 
       product_price, 
       Count(*) 
FROM   monchef.product 
GROUP  BY product_id, 
          product_name, 
          product_price 
HAVING Count(*) > 1; 

-- check if there is any null value (null exists in product_name and product_price) 
desc monchef.product; 
SELECT DISTINCT * 
FROM   monchef.product 
WHERE  product_name IS NULL 
        OR product_price IS NULL 
ORDER  BY product_id; 

-- check if any product_price is < 0 
SELECT DISTINCT * 
FROM   monchef.product 
WHERE  product_price < 0; 

CREATE TABLE product AS 
  SELECT DISTINCT * 
  FROM   monchef.product 
  WHERE  product_name IS NOT NULL 
         AND product_price IS NOT NULL 
  ORDER  BY product_id; 

---------------------------- product review (1 Error) ------------------------------- 
-- check if there is duplicate review 
SELECT Count (*) 
FROM   monchef.product_review; -- 1606 

SELECT Count (DISTINCT review_no) 
FROM   monchef.product_review; -- 1606 
-- check if there is any null value (all comlumn consist of not null constraint) 
desc monchef.product_review; 
-- check if there is ordered product that does not exist 
SELECT product_id 
FROM   monchef.product_review 
WHERE  product_id NOT IN (SELECT product_id 
                          FROM   product); -- R1606 
CREATE TABLE product_review AS 
  SELECT * 
  FROM   monchef.product_review 
  WHERE  product_id IN (SELECT product_id 
                        FROM   product); 

---------------------------------- delivery_type (OK) -------------------------- 
SELECT * 
FROM   monchef.delivery_type; 

-- creating table 
CREATE TABLE delivery_type AS 
  SELECT * 
  FROM   monchef.delivery_type; 

---------------------------------- promotion (OK) ------------------------------ 
SELECT * 
FROM   monchef.promotion; 

-- creating table 
CREATE TABLE promotion AS 
  SELECT * 
  FROM   monchef.promotion; 

---------------------------------- order status (OK) --------------------------- 
SELECT * 
FROM   monchef.order_status; 

-- creating table 
CREATE TABLE order_status AS 
  SELECT * 
  FROM   monchef.order_status; 

---------------------------------- payment_type (OK) --------------------------- 
SELECT * 
FROM   monchef.payment_type; 

-- creating table 
CREATE TABLE payment_type AS 
  SELECT * 
  FROM   monchef.payment_type; 

---------------------------------- delivery_provider (OK) ---------------------- 
SELECT * 
FROM   monchef.delivery_provider; 

-- creating table 
CREATE TABLE delivery_provider AS 
  SELECT * 
  FROM   monchef.delivery_provider; 

---------------------------------- address (OK) -------------------------------- 
SELECT * 
FROM   monchef.address; 

-- check if there is any null value 
desc monchef.address; 
-- check if there is any duplicate data 
SELECT Count(*) 
FROM   monchef.address; -- 249 

SELECT Count (DISTINCT address_id) 
FROM   monchef.address; -- 249 
-- check if there is any street number or postcode that does not make sense 
SELECT * 
FROM   monchef.address 
WHERE  address_streetno <= 0 
        OR address_postcode <= 0; 

-- creating table 
CREATE TABLE address AS 
  SELECT * 
  FROM   monchef.address; 

---------------------------------- staff (1 ERROR) ---------------------------------- 
SELECT * 
FROM   monchef.staff; 

-- check if there is any null value 
desc monchef.staff; 
-- check if there is any staff_title and staff_gender that do not align 
SELECT * 
FROM   monchef.staff 
WHERE  staff_title = 'Mr' 
       AND staff_gender = 'F'; 

SELECT * 
FROM   monchef.staff 
WHERE  staff_title = 'Mrs' 
       AND staff_gender = 'M'; 

-- check if there is any duplicate data 
SELECT Count(*) 
FROM   monchef.staff; -- 51 

SELECT Count (DISTINCT staff_id) 
FROM   monchef.staff; -- 51 
-- check if there is any staff_salaryperhour and staff_weeklyworkinghours that are < 0 
SELECT * 
FROM   monchef.staff 
WHERE  staff_salaryperhour < 0 
        OR staff_weeklyworkinghours < 0; -- ST051 
-- check if address_id exists  
SELECT * 
FROM   monchef.staff 
WHERE  address_id NOT IN (SELECT DISTINCT address_id 
                          FROM   address); -- ST051 
-- creating table 
CREATE TABLE staff AS 
  SELECT * 
  FROM   monchef.staff 
  WHERE  staff_id != 'ST051'; 

---------------------------------- customer_type (OK) ---------------------------------- 
SELECT * 
FROM   monchef.customer_type; 

-- creating table 
CREATE TABLE customer_type AS 
  SELECT * 
  FROM   monchef.customer_type; 

---------------------------------- customer (1 ERROR) ---------------------------------- 
SELECT * 
FROM   monchef.customer; 

-- check if there is any null value 
desc monchef.customer; 
-- check if there is any duplicate value 
SELECT Count(*) 
FROM   monchef.customer; -- 57 

SELECT Count (DISTINCT customer_id) 
FROM   monchef.customer; -- 50  duplicate exists
-- check if there is any customer type_id that does not exist 
SELECT * 
FROM   monchef.customer 
WHERE  type_id NOT IN (SELECT type_id 
                       FROM   customer_type); 

-- check if there is any adress that does not exist 
SELECT * 
FROM   monchef.customer 
WHERE  address_id NOT IN (SELECT DISTINCT address_id 
                          FROM   address); 

-- creating table 
CREATE TABLE customer AS 
  SELECT DISTINCT * 
  FROM   monchef.customer; 

------------------------- school_canteen_order (2 Errors) ---------------------- 
SELECT * 
FROM   monchef.school_canteen_order; 

-- check if there is any null value (all comlumn consist of not null constraint except promo_code)
desc monchef.school_canteen_order; 
-- check if there is any duplicate value 
SELECT Count(*) 
FROM   monchef.school_canteen_order; -- 1502 

SELECT Count(DISTINCT sc_orderid) 
FROM   monchef.school_canteen_order; --1502 
-- check if delivery_type exists 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  delivery_id NOT IN (SELECT delivery_id 
                           FROM   delivery_type); 

-- check if there is any order date that does not make sense 
SELECT DISTINCT To_char(sc_orderdate, 'YYYY') 
FROM   monchef.school_canteen_order; -- there is year 2021 which does not make sense 

SELECT DISTINCT To_char(sc_orderdate, 'MM') AS MM 
FROM   monchef.school_canteen_order 
ORDER  BY mm; 

SELECT DISTINCT To_char(sc_orderdate, 'DD') AS DD 
FROM   monchef.school_canteen_order 
ORDER  BY dd; 

-- check if there is any delivery date that does not make sense 
SELECT DISTINCT To_char(sc_deliverydate, 'YYYY') 
FROM   monchef.school_canteen_order; 

SELECT DISTINCT To_char(sc_deliverydate, 'MM') AS MM 
FROM   monchef.school_canteen_order 
ORDER  BY mm; 

SELECT DISTINCT To_char(sc_deliverydate, 'DD') AS DD 
FROM   monchef.school_canteen_order 
ORDER  BY dd; 

-- check if there is any delivery date that is smaller than order date 
-- S1905: orderdate: 12-05-2019, deliverydate: 12-04-2019 
-- S1906: orderdate: 02-05-2021, deliverydate: 02-05-2019 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  sc_deliverydate < sc_orderdate; 

-- check if there is any status_id that does not exist 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  status_id NOT IN (SELECT status_id 
                         FROM   order_status); 

-- check if there is any promo_code that does not exist 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  promo_code NOT IN (SELECT promo_code 
                          FROM   promotion); 

-- check if there is any payment type_id that does not exist 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  type_id NOT IN (SELECT type_id 
                       FROM   payment_type); -- S1906 
-- check if there is any delivery_id that does not exist 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  delivery_id NOT IN (SELECT delivery_id 
                           FROM   delivery_type); 

-- check if there is any staff_id that does not exist 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  staff_id NOT IN (SELECT staff_id 
                        FROM   staff); 

-- check if there is any customer_id that does not exist 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  customer_id NOT IN (SELECT customer_id 
                           FROM   customer); 

-- check if there is any price that doesnt make sense 
SELECT * 
FROM   monchef.school_canteen_order 
WHERE  sc_totalprice < 0 
        OR sc_finalprice < 0; 

-- creating the table 
CREATE TABLE school_canteen_order AS 
  SELECT * 
  FROM   monchef.school_canteen_order 
  WHERE  sc_orderid NOT IN ( 'S1905', 'S1906' ); 

---------------------- school_canteen_orderline (OK)  -------------------------- 
-- check if there is any duplicate order 
SELECT Count (sc_orderid 
              || product_id) 
FROM   monchef.school_canteen_orderline; -- 4346 

SELECT Count (DISTINCT sc_orderid 
                       || product_id) 
FROM   monchef.school_canteen_orderline; -- 4346 
-- check if there is ordered product that does not exist 
SELECT Count (product_id) 
FROM   monchef.school_canteen_orderline 
WHERE  product_id NOT IN (SELECT product_id 
                          FROM   product); -- 0 
-- check if there is ordered product that does not exist 
SELECT Count (sc_orderid) 
FROM   monchef.school_canteen_orderline 
WHERE  sc_orderid NOT IN (SELECT sc_orderid 
                          FROM   school_canteen_order); -- 0 
-- check if there is null value (all comlumn consist of not null constraint) 
desc monchef.school_canteen_orderline; 
-- check if there is any lineprice/quantitysold that doesnt make sense 
SELECT * 
FROM   monchef.school_canteen_orderline 
WHERE  sol_quantitysold < 0 
        OR sol_lineprice < 0; 

CREATE TABLE school_canteen_orderline AS 
  SELECT * 
  FROM   monchef.school_canteen_orderline; 

---------------------------------- catering_order (2 Errors) ------------------- 
SELECT * 
FROM   monchef.catering_order; 

-- check if there is any duplicate data  
SELECT Count(*) 
FROM   monchef.catering_order; -- 1504 

SELECT Count (DISTINCT ca_orderid) 
FROM   monchef.catering_order; -- 1500 duplicate exists
-- check if there is any null value 
desc monchef.catering_order; 
-- check if there is date that does not make sense 
SELECT DISTINCT To_char(ca_orderdate, 'YYYY') 
FROM   monchef.catering_order; -- there is year 2035 which does not make sense 

SELECT DISTINCT To_char(ca_orderdate, 'MM') AS MM 
FROM   monchef.catering_order 
ORDER  BY mm; 

SELECT DISTINCT To_char(ca_orderdate, 'DD') AS DD 
FROM   monchef.catering_order 
ORDER  BY dd; 

-- check if there is any promo_code that does not exist 
SELECT * 
FROM   monchef.catering_order 
WHERE  promo_code NOT IN (SELECT promo_code 
                          FROM   promotion); 

-- check if there is any provider_id that does not exist 
SELECT * 
FROM   monchef.catering_order 
WHERE  provider_id NOT IN (SELECT provider_id 
                           FROM   delivery_provider); 

-- check if there is any staff_id that does not exist 
SELECT * 
FROM   monchef.catering_order 
WHERE  staff_id NOT IN (SELECT staff_id 
                        FROM   staff); 

-- check if there is any status_id that does not exist 
SELECT * 
FROM   monchef.catering_order 
WHERE  status_id NOT IN (SELECT status_id 
                         FROM   order_status); 

-- creating table 
CREATE TABLE catering_order AS 
  SELECT DISTINCT * 
  FROM   monchef.catering_order 
  WHERE  To_char(ca_orderdate, 'YYYY') != '2035'; 

---------------------------------- catering_orderline (1 Error) ----------------------------------
SELECT * 
FROM   monchef.catering_orderline; 

-- check if there is any duplicate order 
SELECT Count (ca_orderid 
              || product_id) 
FROM   monchef.catering_orderline; -- 4495 

SELECT Count (DISTINCT ca_orderid 
                       || product_id) 
FROM   monchef.catering_orderline; -- 4495 
-- check if there is ordered product that does not exist 
SELECT * 
FROM   monchef.catering_orderline 
WHERE  product_id NOT IN (SELECT product_id 
                          FROM   product); -- CA_ORDERID: C1890 
-- check if there is order that does not exist 
SELECT * 
FROM   monchef.catering_orderline 
WHERE  ca_orderid NOT IN (SELECT ca_orderid 
                          FROM   catering_order); -- CA_ORDERID: C1890 
SELECT * 
FROM   monchef.catering_orderline 
WHERE  ca_orderid = 'C1890'; -- only 1 order is wrong 
-- check if there is null value: null does not exist 
desc monchef.catering_orderline; 
-- check if there is any lineprice/quantitysold that doesnt make sense 
SELECT * 
FROM   monchef.catering_orderline 
WHERE  col_quantitysold < 0 
        OR col_lineprice < 0; 

-- creating table 
CREATE TABLE catering_orderline AS 
  SELECT * 
  FROM   monchef.catering_orderline 
  WHERE  ca_orderid != 'C1890'; 