/*
Group MA1
Ahmed Mohamed H A Nassar - 28901797
Grace Nathania - 30241510
Kelvin Kan Jia Yaw - 29764920

Submitted on: November 4 2020

Task 3 A: Report 1,2,3
*/
-- REPORT 1: TOP 3 ORDERED MAIN DISHES FOR CATERING 

/*----------------------------------------------- 
LEVEL 0
------------------------------------------------*/
SELECT  *
FROM    (
            SELECT  p.product_name, 
                    c.category_description, 
                    SUM(f.total_order_number)                                   AS total_order,
                    DENSE_RANK() OVER (ORDER BY SUM(f.total_order_number) DESC) AS dense_rank
            FROM    CateringServiceFACT_0 f, 
                    CateringOrderLineDIM_0 o, 
                    ProductDIM_0 p,
                    ProductCategoryBridgeDIM_0 pd, 
                    CategoryDIM_0 c
            WHERE   f.ca_orderid = o.ca_orderid
                    AND o.product_id = p.product_id
                    AND p.product_id = pd.product_id
                    AND pd.category_id = c.category_id
                    AND c.category_description = 'Main'
            GROUP   BY  p.product_name, 
                        c.category_description)
WHERE   dense_rank <= 3;


/*----------------------------------------------- 
LEVEL 2
------------------------------------------------*/
SELECT  *
FROM    (
            SELECT  p.product_name, 
                    c.category_description, 
                    SUM(f.total_order_number)                                   AS total_order,
                    DENSE_RANK() OVER (ORDER BY SUM(f.total_order_number) DESC) AS dense_rank
            FROM    CateringServiceFACT f, 
                    CateringOrderLineDIM o, 
                    ProductDIM  p,
                    ProductCategoryBridgeDIM_0 pd, 
                    CategoryDIM_0 c
            WHERE   f.ca_orderid = o.ca_orderid
                    AND o.product_id = p.product_id
                    AND p.product_id = pd.product_id
                    AND pd.category_id = c.category_id
                    AND c.category_description = 'Main'
            GROUP   BY  p.product_name, 
                        c.category_description)
WHERE   dense_rank <= 3;

-- REPORT 2: TOP 10% TOTAL_SALES FOR CANTEEN

/*----------------------------------------------- 
LEVEL 0
------------------------------------------------*/
SELECT  *
FROM    (
            SELECT  p.type_description                                      AS payment_type,
                    c.type_description                                      AS cust_type,
                    SUM(f.total_sales)                                      AS total_sales,
                    PERCENT_RANK() OVER (ORDER BY SUM(f.total_sales) DESC)  AS percent_rank
            FROM    CanteenServiceFACT_0 f, 
                    PaymentTypeDIM_0 p, 
                    CustomerTypeDIM_0 c
            WHERE   f.payment_type_id = p.payment_type_id
                    AND f.cust_type_id = c.cust_type_id
            GROUP   BY  p.type_description, 
                        c.type_description)
WHERE   percent_rank < 0.1;

/*----------------------------------------------- 
LEVEL 2
------------------------------------------------*/
SELECT  *
FROM    (
            SELECT  p.type_description                                      AS payment_type,
                    c.type_description                                      AS cust_type,
                    SUM(f.total_sales)                                      AS total_sales,
                    PERCENT_RANK() OVER (ORDER BY SUM(f.total_sales) DESC)  AS percent_rank
            FROM    CanteenServiceFACT f, 
                    PaymentTypeDIM p, 
                    CustomerTypeDIM c
            WHERE   f.payment_type_id = p.payment_type_id
                    AND f.cust_type_id = c.cust_type_id
            GROUP   BY  p.type_description, 
                        c.type_description)  
WHERE   percent_rank < 0.1;

-- Report 3: Number of Customer Type per suburb

/*----------------------------------------------- 
LEVEL 0
------------------------------------------------*/
SELECT  l.address_suburb,
        ct.type_description                                                 AS cust_type, 
        SUM(f.total_number_of_customer)                                     AS num_of_cust,
        DENSE_RANK() OVER (ORDER BY SUM(f.total_number_of_customer) DESC)   AS dense_rank
FROM    CustomerFACT_0 f, 
        customerDIM_0 c,
        CustomerTypeDIM_0 ct, 
        LocationDIM_0 l
WHERE   f.customer_id = c.customer_id
        AND c.cust_type_id = ct.cust_type_id
        AND c.address_id = l.address_id
GROUP   BY  ct.type_description, 
            l.address_suburb
ORDER   BY l.address_suburb;

/*----------------------------------------------- 
LEVEL 2
------------------------------------------------*/
SELECT  s.address_suburb,
        ct.type_description                                                 AS cust_type, 
        SUM(f.total_number_of_customer)                                     AS num_of_cust,
        DENSE_RANK() OVER (ORDER BY SUM(f.total_number_of_customer) DESC)   AS dense_rank
FROM    CustomerFACT f, 
        CustomerTypeDIM ct, 
        SuburbDIM s
WHERE   f.cust_type_id = ct.cust_type_id
        AND f.suburd = s.address_suburb
GROUP   BY  ct.type_description,
            s.address_suburb
ORDER   BY s.address_suburb;