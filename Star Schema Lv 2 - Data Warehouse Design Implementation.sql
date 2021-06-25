/*
Group MA1
Ahmed Mohamed H A Nassar - 28901797
Grace Nathania - 30241510
Kelvin Kan Jia Yaw - 29764920

Submitted on: November 4 2020

Star Schema Level 2 Implementation
*/
--Drop Statement:  
--dimensions:
DROP TABLE suburbdim; 

DROP TABLE customertypedim; 

DROP TABLE paymenttypedim; 

DROP TABLE promotiondim; 

DROP TABLE orderstatusdim; 

DROP TABLE genderdim; 

DROP TABLE deliveryproviderdim; 

DROP TABLE productpricescaledim; 

DROP TABLE orderpricescaledim; 

DROP TABLE temptimedim; 

DROP TABLE timedim; 

DROP TABLE tempseasondim; 

DROP TABLE seasondim; 

DROP TABLE productcategorybridgedim; 

DROP TABLE categorydim; 

DROP TABLE tempproductdim; 

DROP TABLE productdim; 

DROP TABLE canteenorderdim; 

DROP TABLE canteenorderlinedim; 

DROP TABLE cateringorderdim; 

DROP TABLE cateringorderlinedim; 

--fact tables:  
DROP TABLE customerfact; 

DROP TABLE tempcanteenservicefact; 

DROP TABLE canteenservicefact; 

DROP TABLE tempcateringservicefact; 

DROP TABLE cateringservicefact; 

DROP TABLE tempproductfact; 

DROP TABLE productfact; 

/*-----------------------------------------------  
Dimension 1: SuburbDIM 
------------------------------------------------*/ 
CREATE TABLE suburbdim AS 
  SELECT DISTINCT address_suburb 
  FROM   address; 

/*-----------------------------------------------  
Dimension 2: CustomerTypeDIM  
------------------------------------------------*/ 
CREATE TABLE customertypedim AS 
  SELECT type_id AS cust_type_id, 
         type_description 
  FROM   customer_type; 

/*-----------------------------------------------  
Dimension 3: PaymentTypeDIM  
------------------------------------------------*/ 
CREATE TABLE paymenttypedim AS 
  SELECT type_id AS payment_type_id, 
         type_description 
  FROM   payment_type; 

/*-----------------------------------------------  
Dimension 4: PromotionDIM  
------------------------------------------------*/ 
CREATE TABLE promotiondim AS 
  SELECT * 
  FROM   promotion; 

INSERT INTO promotiondim 
VALUES      ('no_pr', 
             'no promotion used'); 

/*-----------------------------------------------  
Dimension 5: orderStatusDIM  
------------------------------------------------*/ 
CREATE TABLE orderstatusdim AS 
  SELECT * 
  FROM   order_status; 

/*-----------------------------------------------  
Dimension 6: GenderDIM  
------------------------------------------------*/ 
CREATE TABLE genderdim AS 
  SELECT DISTINCT staff_gender 
  FROM   staff; 

ALTER TABLE genderdim 
  ADD ( description VARCHAR2(6)); 

UPDATE genderdim 
SET    description = 'Female' 
WHERE  staff_gender = 'F'; 

UPDATE genderdim 
SET    description = 'Male' 
WHERE  staff_gender = 'M'; 

/*-----------------------------------------------  
Dimension 7: DeliveryProviderDIM  
------------------------------------------------*/ 
CREATE TABLE deliveryproviderdim AS 
  SELECT * 
  FROM   delivery_provider; 

/*-----------------------------------------------  
Dimension 8: productPriceScaleDIM  
------------------------------------------------*/ 
CREATE TABLE productpricescaledim 
  ( 
     product_price_scaleid CHAR(1), 
     description           VARCHAR2(50), 
     minprice              NUMBER(5, 2), 
     maxprice              NUMBER(5, 2) 
  ); 

INSERT INTO productpricescaledim 
VALUES      ('l', 
             'low price range', 
             0.00, 
             9.99); 

INSERT INTO productpricescaledim 
VALUES      ('m', 
             'medium price range', 
             10.00, 
             20.00); 

INSERT INTO productpricescaledim 
VALUES      ('h', 
             'high price range', 
             20.01, 
             NULL); 

/*-----------------------------------------------  
Dimension 9: orderPriceScaleDIM  
------------------------------------------------*/ 
CREATE TABLE orderpricescaledim 
  ( 
     order_price_scaleid CHAR(1), 
     description         VARCHAR2(50), 
     minprice            NUMBER(6, 2), 
     maxprice            NUMBER(6, 2) 
  ); 

INSERT INTO orderpricescaledim 
VALUES      ('l', 
             'low price range', 
             0.00, 
             49.99); 

INSERT INTO orderpricescaledim 
VALUES      ('m', 
             'medium price range', 
             50.00, 
             150.00); 

INSERT INTO orderpricescaledim 
VALUES      ('e', 
             'expensive price range', 
             150.01, 
             NULL); 

/*-----------------------------------------------  
Dimension 10: TimeDIM  
------------------------------------------------*/ 
-- first: create the temporary dimension  
CREATE TABLE temptimedim AS 
  SELECT DISTINCT To_char(sc_orderdate, 'Day')  AS weeklyDay, 
                  To_char(sc_orderdate, 'DD')   AS the_day, 
                  To_char(sc_orderdate, 'MM')   AS the_month, 
                  To_char(sc_orderdate, 'YYYY') AS the_year 
  FROM   school_canteen_order 
  UNION 
  SELECT DISTINCT To_char(ca_orderdate, 'Day')  AS weeklyDay, 
                  To_char(ca_orderdate, 'DD')   AS the_day, 
                  To_char(ca_orderdate, 'MM')   AS the_month, 
                  To_char(ca_orderdate, 'YYYY') AS the_year 
  FROM   catering_order; 

-- adding timeID  
ALTER TABLE temptimedim 
  ADD ( timeid CHAR(8)); 

-- filling the time id in the following format: YYYYMMDD  
UPDATE temptimedim 
SET    timeid = the_year 
                ||the_month 
                ||the_day; 

-- Final Dimension Table: TimeDIM  
CREATE TABLE timedim AS 
  SELECT timeid, 
         weeklyday, 
         the_day, 
         the_month, 
         the_year 
  FROM   temptimedim; 

/*-----------------------------------------------  
Dimension 11: Season  
------------------------------------------------*/ 
-- temp dimension  
CREATE TABLE tempseasondim AS 
  SELECT DISTINCT To_char(sc_orderdate, 'MM') AS the_month 
  FROM   school_canteen_order 
  UNION 
  SELECT DISTINCT To_char(ca_orderdate, 'MM') AS the_month 
  FROM   catering_order; 

ALTER TABLE tempseasondim 
  ADD ( season VARCHAR2(6)); 

UPDATE tempseasondim 
SET    season = 'summer' 
WHERE  the_month = '12' 
        OR the_month <= '02'; 

UPDATE tempseasondim 
SET    season = 'winter' 
WHERE  the_month >= '06' 
       AND the_month <= '08'; 

UPDATE tempseasondim 
SET    season = 'autumn' 
WHERE  the_month >= '03' 
       AND the_month <= '05'; 

UPDATE tempseasondim 
SET    season = 'spring' 
WHERE  the_month >= '09' 
       AND the_month <= '11'; 

-- Final Dimension:  
CREATE TABLE seasondim AS 
  SELECT DISTINCT season 
  FROM   tempseasondim; 

/*-----------------------------------------------  
Dimension 12: ProductDIM  
------------------------------------------------*/ 
CREATE TABLE tempproductdim AS 
  SELECT p.product_id, 
         p.product_name, 
         p.product_price, 
         Nvl(r.review_star, 0) AS Star 
  FROM   product p, 
         product_review r 
  WHERE  p.product_id = r.product_id(+); 

CREATE TABLE productdim AS 
  SELECT product_id, 
         product_name, 
         product_price, 
         Round(Avg(star)) AS Avg_Star 
  FROM   tempproductdim 
  GROUP  BY product_id, 
            product_name, 
            product_price; 

/*-----------------------------------------------  
BRIDGE DIMENSION TABLE: ProductCategoryBridgeDIM  
------------------------------------------------*/ 
-- temp dimension: tempProductwithStar  
CREATE TABLE productcategorybridgedim AS 
  SELECT * 
  FROM   product_category; 

/*-----------------------------------------------  
Dimension 13: CategoryDIM  
------------------------------------------------*/ 
CREATE TABLE categorydim AS 
  SELECT * 
  FROM   category; 

ALTER TABLE categorydim 
  ADD ( category_type VARCHAR2(10)); 

-- setting category type to Meal  
UPDATE categorydim 
SET    category_type = 'meal' 
WHERE  category_description IN ( 'Main', 'Starter', 'Dessert', 'Drink' ); 

UPDATE categorydim 
SET    category_type = 'flavour' 
WHERE  category_description IN ( 'Sweet', 'Savoury' ); 

UPDATE categorydim 
SET    category_type = 'cuisine' 
WHERE  category_description IN ( 'Indonesian', 'Korean', 'Thai' ); 

/*------------------------------------------------  
Dimension 14: CanteenOrderDIM  
------------------------------------------------*/ 
CREATE TABLE canteenorderdim AS 
  SELECT o.sc_orderid, 
         o.sc_totalprice, 
         1.0 / Count(ol.product_id)              AS sc_weight_factor, 
         Listagg (ol.product_id, '_') 
           within GROUP (ORDER BY ol.product_id) AS sc_product_list 
  FROM   school_canteen_order o, 
         school_canteen_orderline ol 
  WHERE  o.sc_orderid = ol.sc_orderid 
  GROUP  BY o.sc_orderid, 
            sc_totalprice; 

/*------------------------------------------------  
Dimension 15: CanteenOrderLineDIM  
------------------------------------------------*/ 
CREATE TABLE canteenorderlinedim AS 
  SELECT sc_orderid, 
         product_id, 
         sol_lineprice 
  FROM   school_canteen_orderline; 

/*------------------------------------------------  
Dimension 16: CateringOrderDIM  
------------------------------------------------*/ 
CREATE TABLE cateringorderdim AS 
  SELECT o.ca_orderid, 
         o.ca_totalprice, 
         1.0 / Count(ol.product_id)              AS ca_weight_factor, 
         Listagg (ol.product_id, '_') 
           within GROUP (ORDER BY ol.product_id) AS ca_product_list 
  FROM   catering_order o, 
         catering_orderline ol 
  WHERE  o.ca_orderid = ol.ca_orderid 
  GROUP  BY o.ca_orderid, 
            o.ca_totalprice; 

/*------------------------------------------------  
Dimension 17: CateringOrderLineDIM  
------------------------------------------------*/ 
CREATE TABLE cateringorderlinedim AS 
  SELECT ca_orderid, 
         product_id, 
         col_lineprice 
  FROM   catering_orderline; 

--- END of dimensions  
/*--------------------------------------------------  
CustomerFact  
--------------------------------------------------*/ 
CREATE TABLE customerfact AS 
  SELECT a.address_suburb AS suburd, 
         type_id          AS cust_type_id, 
         Count(*)         AS total_number_of_customer 
  FROM   customer c 
         join address a 
           ON c.address_id = a.address_id 
  GROUP  BY a.address_suburb, 
            type_id; 

/*-------------------------------------------------  
CanteenServiceFACT  
-------------------------------------------------*/ 
CREATE TABLE tempcanteenservicefact AS 
  SELECT sc_orderid, 
         To_char(sc_orderdate, 'YYYY') 
         || To_char(sc_orderdate, 'MM') 
         || To_char(sc_orderdate, 'DD') AS timeID, 
         To_char(sc_orderdate, 'MM')    AS order_month, 
         sc.type_id                     AS payment_type_id, 
         sc.promo_code, 
         c.type_id                      AS cust_type_id, 
         s.staff_gender, 
         sc.status_id, 
         sc.sc_finalprice 
  FROM   school_canteen_order sc 
         join customer c 
           ON sc.customer_id = c.customer_id 
         join staff s 
           ON sc.staff_id = s.staff_id; 

ALTER TABLE tempcanteenservicefact 
  ADD ( season VARCHAR2(10)); 

UPDATE tempcanteenservicefact 
SET    season = 'summer' 
WHERE  order_month = '12' 
        OR order_month <= '02'; 

UPDATE tempcanteenservicefact 
SET    season = 'winter' 
WHERE  order_month >= '06' 
       AND order_month <= '08'; 

UPDATE tempcanteenservicefact 
SET    season = 'autumn' 
WHERE  order_month >= '03' 
       AND order_month <= '05'; 

UPDATE tempcanteenservicefact 
SET    season = 'spring' 
WHERE  order_month >= '09' 
       AND order_month <= '11'; 

ALTER TABLE tempcanteenservicefact 
  ADD ( order_price_scaleid VARCHAR2(10)); 

UPDATE tempcanteenservicefact 
SET    order_price_scaleid = 'l' 
WHERE  sc_finalprice >= 0.00 
        OR sc_finalprice <= 49.99; 

UPDATE tempcanteenservicefact 
SET    order_price_scaleid = 'm' 
WHERE  sc_finalprice >= 50.00 
       AND sc_finalprice <= 150.00; 

UPDATE tempcanteenservicefact 
SET    order_price_scaleid = 'e' 
WHERE  sc_finalprice >= 150.01; 

CREATE TABLE canteenservicefact AS 
  SELECT sc_orderid, 
         timeid, 
         season, 
         order_price_scaleid, 
         payment_type_id, 
         Nvl(promo_code, 'no_pr') AS promo_code, 
         status_id, 
         staff_gender, 
         cust_type_id, 
         SUM(sc_finalprice)       AS total_sales, 
         Count(*)                 AS total_order_number 
  FROM   tempcanteenservicefact 
  GROUP  BY sc_orderid, 
            timeid, 
            season, 
            order_price_scaleid, 
            payment_type_id, 
            promo_code, 
            status_id, 
            staff_gender, 
            cust_type_id; 

/*--------------------------------------------------------  
CateringServiceFACT  
---------------------------------------------------------*/ 
CREATE TABLE tempcateringservicefact AS 
  SELECT ca_orderid, 
         To_char(ca_orderdate, 'YYYY') 
         || To_char(ca_orderdate, 'MM') 
         || To_char(ca_orderdate, 'DD') AS timeID, 
         To_char(ca_orderdate, 'MM')    AS order_month, 
         ca.promo_code, 
         s.staff_gender, 
         ca.status_id, 
         ca.ca_finalprice, 
         ca.provider_id, 
         ca.ca_totalprice, 
         d.provider_rate 
  FROM   catering_order ca 
         join staff s 
           ON ca.staff_id = s.staff_id 
         join delivery_provider d 
           ON d.provider_id = ca.provider_id; 

ALTER TABLE tempcateringservicefact 
  ADD ( season VARCHAR2(10)); 

UPDATE tempcateringservicefact 
SET    season = 'summer' 
WHERE  order_month = '12' 
        OR order_month <= '02'; 

UPDATE tempcateringservicefact 
SET    season = 'winter' 
WHERE  order_month >= '06' 
       AND order_month <= '08'; 

UPDATE tempcateringservicefact 
SET    season = 'autumn' 
WHERE  order_month >= '03' 
       AND order_month <= '05'; 

UPDATE tempcateringservicefact 
SET    season = 'spring' 
WHERE  order_month >= '09' 
       AND order_month <= '11'; 

ALTER TABLE tempcateringservicefact 
  ADD ( order_price_scaleid VARCHAR2(10)); 

UPDATE tempcateringservicefact 
SET    order_price_scaleid = 'l' 
WHERE  ca_finalprice >= 0.00 
        OR ca_finalprice <= 49.99; 

UPDATE tempcateringservicefact 
SET    order_price_scaleid = 'm' 
WHERE  ca_finalprice >= 50.00 
       AND ca_finalprice <= 150.00; 

UPDATE tempcateringservicefact 
SET    order_price_scaleid = 'e' 
WHERE  ca_finalprice >= 150.01; 

CREATE TABLE cateringservicefact AS 
  SELECT ca_orderid, 
         timeid, 
         season, 
         order_price_scaleid, 
         Nvl(promo_code, 'no_pr')           AS promo_code, 
         status_id, 
         staff_gender, 
         provider_id, 
         SUM(ca_finalprice)                 AS total_sales, 
         Count(*)                           AS total_order_number, 
         SUM(ca_totalprice * provider_rate) AS total_delivery_cost 
  FROM   tempcateringservicefact 
  GROUP  BY ca_orderid, 
            timeid, 
            season, 
            order_price_scaleid, 
            promo_code, 
            status_id, 
            staff_gender, 
            provider_id; 

/*----------------------------------------------  
productFACT  
--------------------------------------------------*/ 
CREATE TABLE tempproductfact AS 
  SELECT product_id, 
         product_price 
  FROM   product; 

ALTER TABLE tempproductfact 
  ADD ( product_price_scaleid VARCHAR2(10)); 

UPDATE tempproductfact 
SET    product_price_scaleid = 'l' 
WHERE  product_price >= 0.00 
       AND product_price <= 9.99; 

UPDATE tempproductfact 
SET    product_price_scaleid = 'm' 
WHERE  product_price >= 10.00 
       AND product_price <= 20.00; 

UPDATE tempproductfact 
SET    product_price_scaleid = 'h' 
WHERE  product_price >= 20.01; 

CREATE TABLE productfact AS 
  SELECT product_id, 
         product_price_scaleid, 
         Count(*) AS total_number_of_products 
  FROM   tempproductfact 
  GROUP  BY product_id, 
            product_price_scaleid; 