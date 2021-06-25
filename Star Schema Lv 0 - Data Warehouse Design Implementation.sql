/*
Group MA1
Ahmed Mohamed H A Nassar - 28901797
Grace Nathania - 30241510
Kelvin Kan Jia Yaw - 29764920

Submitted on: November 4 2020

Star Schema Level 0 Implementation
*/
--Drop Statement:  
--dimensions  
DROP TABLE locationdim_0; 

DROP TABLE customertypedim_0; 

DROP TABLE paymenttypedim_0; 

DROP TABLE promotiondim_0; 

DROP TABLE orderstatusdim_0; 

DROP TABLE customerdim_0; 

DROP TABLE genderdim_0; 

DROP TABLE deliveryproviderdim_0; 

DROP TABLE tempproductdim_0; 

DROP TABLE productdim_0; 

DROP TABLE productcategorybridgedim_0; 

DROP TABLE categorydim_0; 

DROP TABLE canteenorderdim_0; 

DROP TABLE canteenorderlinedim_0; 

DROP TABLE cateringorderdim_0; 

DROP TABLE cateringorderlinedim_0; 

--fact tables: 
DROP TABLE canteenservicefact_0; 

DROP TABLE customerfact_0; 

DROP TABLE cateringservicefact_0; 

DROP TABLE productfact_0; 

/*-----------------------------------------------  
Dimension 1: LocationDIM  
------------------------------------------------*/ 
CREATE TABLE locationdim_0 AS 
  SELECT * 
  FROM   address; 

/*-----------------------------------------------  
Dimension 2: CustomerTypeDIM  
------------------------------------------------*/ 
CREATE TABLE customertypedim_0 AS 
  SELECT type_id AS cust_type_id, 
         type_description 
  FROM   customer_type; 

/*-----------------------------------------------  
Dimension 3: PaymentTypeDIM  
------------------------------------------------*/ 
CREATE TABLE paymenttypedim_0 AS 
  SELECT type_id AS payment_type_id, 
         type_description 
  FROM   payment_type; 

/*-----------------------------------------------  
Dimension 4: PromotionDIM  
------------------------------------------------*/ 
CREATE TABLE promotiondim_0 AS 
  SELECT * 
  FROM   promotion; 

/*-----------------------------------------------  
Dimension 5: orderStatusDIM  
------------------------------------------------*/ 
CREATE TABLE orderstatusdim_0 AS 
  SELECT * 
  FROM   order_status; 

/*-----------------------------------------------  
Dimension 6: GenderDIM  
------------------------------------------------*/ 
CREATE TABLE genderdim_0 AS 
  SELECT DISTINCT staff_gender 
  FROM   staff; 

ALTER TABLE genderdim_0 
  ADD ( description VARCHAR2(6)); 

UPDATE genderdim_0 
SET    description = 'Female' 
WHERE  staff_gender = 'F'; 

UPDATE genderdim_0 
SET    description = 'Male' 
WHERE  staff_gender = 'M'; 

/*-----------------------------------------------  
Dimension 7: DeliveryProviderDIM  
------------------------------------------------*/ 
CREATE TABLE deliveryproviderdim_0 AS 
  SELECT * 
  FROM   delivery_provider; 

/*-----------------------------------------------  
Dimension 8: CustomerDIM  
------------------------------------------------*/ 
CREATE TABLE customerdim_0 AS 
  SELECT customer_id, 
         customer_name, 
         address_id, 
         customer_phone, 
         customer_email, 
         type_id AS cust_type_id, 
         customer_bankaccount, 
         customer_abn 
  FROM   customer; 

/*-----------------------------------------------  
Dimension 9: ProductDIM  
------------------------------------------------*/ 
CREATE TABLE tempproductdim_0 AS 
  SELECT p.product_id, 
         p.product_name, 
         p.product_price, 
         Nvl(r.review_star, 0) AS Star 
  FROM   product p, 
         product_review r 
  WHERE  p.product_id = r.product_id(+); 

CREATE TABLE productdim_0 AS 
  SELECT product_id, 
         product_name, 
         product_price, 
         Round(Avg(star)) AS Avg_Star 
  FROM   tempproductdim_0 
  GROUP  BY product_id, 
            product_name, 
            product_price; 

/*-----------------------------------------------  
BRIDGE DIMENSION TABLE: ProductCategoryBridgeDIM  
------------------------------------------------*/  
CREATE TABLE productcategorybridgedim_0 AS 
  SELECT * 
  FROM   product_category; 

/*-----------------------------------------------  
Dimension 10: CategoryDIM  
------------------------------------------------*/ 
CREATE TABLE categorydim_0 AS 
  SELECT * 
  FROM   category; 

ALTER TABLE categorydim_0 
  ADD ( category_type VARCHAR2(10)); 

-- setting category type to Meal  
UPDATE categorydim_0 
SET    category_type = 'meal' 
WHERE  category_description IN ( 'Main', 'Starter', 'Dessert', 'Drink' ); 

UPDATE categorydim_0 
SET    category_type = 'flavour' 
WHERE  category_description IN ( 'Sweet', 'Savoury' ); 

UPDATE categorydim_0 
SET    category_type = 'cuisine' 
WHERE  category_description IN ( 'Indonesian', 'Korean', 'Thai' ); 

/*------------------------------------------------  
Dimension 11: CanteenOrderDIM  
------------------------------------------------*/ 
CREATE TABLE canteenorderdim_0 AS 
  SELECT o.sc_orderid, 
         o.sc_totalprice, 
         o.sc_finalprice, 
         o.sc_orderdate, 
         1.0 / Count(ol.product_id)              AS sc_weight_factor, 
         Listagg (ol.product_id, '_') 
           within GROUP (ORDER BY ol.product_id) AS sc_product_list 
  FROM   school_canteen_order o, 
         school_canteen_orderline ol 
  WHERE  o.sc_orderid = ol.sc_orderid 
  GROUP  BY o.sc_orderid, 
            o.sc_totalprice, 
            o.sc_finalprice, 
            o.sc_orderdate; 

/*------------------------------------------------  
Dimension 12: CanteenOrderLineDIM  
------------------------------------------------*/ 
CREATE TABLE canteenorderlinedim_0 AS 
  SELECT sc_orderid, 
         product_id, 
         sol_lineprice 
  FROM   school_canteen_orderline; 

/*------------------------------------------------  
Dimension 13: CateringOrderDIM  
------------------------------------------------*/ 
CREATE TABLE cateringorderdim_0 AS 
  SELECT o.ca_orderid, 
         o.ca_totalprice, 
         o.ca_finalprice, 
         o.ca_orderdate, 
         1.0 / Count(ol.product_id)              AS ca_weight_factor, 
         Listagg (ol.product_id, '_') 
           within GROUP (ORDER BY ol.product_id) AS ca_product_list 
  FROM   catering_order o, 
         catering_orderline ol 
  WHERE  o.ca_orderid = ol.ca_orderid 
  GROUP  BY o.ca_orderid, 
            o.ca_totalprice, 
            o.ca_finalprice, 
            o.ca_orderdate; 

/*------------------------------------------------  
Dimension 14: CateringOrderLineDIM  
------------------------------------------------*/ 
CREATE TABLE cateringorderlinedim_0 AS 
  SELECT ca_orderid, 
         product_id, 
         col_lineprice 
  FROM   catering_orderline; 

--- END of dimensions  
/*-----------------------------------------------   
CanteenServiceFACT   
------------------------------------------------*/ 
CREATE TABLE canteenservicefact_0 AS 
  SELECT o.type_id                  AS payment_type_id, 
         Nvl(o.promo_code, 'no_pr') AS promo_code, 
         o.status_id, 
         c.type_id                  AS cust_type_id, 
         s.staff_gender, 
         o.sc_orderid, 
         SUM(o.sc_finalprice)       AS total_sales, 
         Count(o.sc_orderid)        AS total_order_number 
  FROM   school_canteen_order o, 
         staff s, 
         customer c 
  WHERE  o.staff_id = s.staff_id 
         AND o.customer_id = c.customer_id 
  GROUP  BY o.type_id, 
            promo_code, 
            o.status_id, 
            c.type_id, 
            s.staff_gender, 
            o.sc_orderid; 

/*-----------------------------------------------   
CustomerFACT   
------------------------------------------------*/ 
CREATE TABLE customerfact_0 AS 
  SELECT customer_id, 
         Count(customer_id) AS total_number_of_customer 
  FROM   customer 
  GROUP  BY customer_id; 

/*-----------------------------------------------   
CateringServiceFACT   
------------------------------------------------*/ 
CREATE TABLE cateringservicefact_0 AS 
  SELECT Nvl(o.promo_code, 'no_pr')             AS promo_code, 
         o.status_id, 
         s.staff_gender, 
         o.provider_id, 
         o.ca_orderid, 
         SUM(o.ca_finalprice)                   AS total_sales, 
         Count(o.ca_orderid)                    AS total_order_number, 
         SUM(o.ca_totalprice * p.provider_rate) AS total_delivery_cost 
  FROM   catering_order o, 
         staff s, 
         delivery_provider p 
  WHERE  o.staff_id = s.staff_id 
         AND o.provider_id = p.provider_id 
  GROUP  BY promo_code, 
            o.status_id, 
            s.staff_gender, 
            o.provider_id, 
            o.ca_orderid, 
            o.ca_totalprice * p.provider_rate; 

/*-----------------------------------------------   
ProductFACT   
------------------------------------------------*/ 
CREATE TABLE productfact_0 AS 
  SELECT product_id, 
         Count(product_id) AS total_number_of_products 
  FROM   product 
  GROUP  BY product_id; 