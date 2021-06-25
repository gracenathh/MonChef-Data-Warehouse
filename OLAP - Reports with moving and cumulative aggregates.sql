/*
Group MA1
Ahmed Mohamed H A Nassar - 28901797
Grace Nathania - 30241510
Kelvin Kan Jia Yaw - 29764920

Submitted on: November 4 2020

Task 3 C: Report 8,9,10
*/
--Report 8:
/*----------------------------------------------- 
LEVEL 0
------------------------------------------------*/

-- Cumulative Revenue: What are the total catering sales and cumulative total catering sales of Savoury dishes in each year?
SELECT  the_year,
        SUM(final_sales)                                                                                AS total_revenue,
        TO_CHAR(SUM(SUM(final_sales)) OVER(ORDER BY the_year ROWS UNBOUNDED PRECEDING), '9,999,999.99') AS cumulative_revenue
FROM    (
            SELECT  TO_CHAR(c.ca_orderdate,'YYYY')                          AS the_year,
                    f.total_sales,
                    c.ca_totalprice,
                    (SUM(co.col_lineprice)/c.ca_totalprice)                 AS percentage,
                    (f.total_sales*(SUM(co.col_lineprice)/c.ca_totalprice)) AS final_sales
            FROM    CateringServiceFACT_0 f, 
                    CateringOrderDIM_0 c, 
                    CateringOrderLineDIM_0 co, 
                    ProductCategoryBridgeDIM_0 p, 
                    CategoryDIM_0 ct
            WHERE   f.ca_orderid = c.ca_orderid
                    AND c.ca_orderid = co.ca_orderid
                    AND co.product_id = p.product_id
                    AND p.category_id = ct.category_id
                    AND ct.category_description = 'Savoury'
            GROUP   BY  c.ca_orderdate, 
                        f.total_sales, 
                        c.ca_totalprice)
GROUP   BY the_year;


-- Moving Average: What are the total catering sales and moving catering sales of 3 yearly of Savoury dishes in each year?
SELECT  the_year,
        SUM(final_sales)                                                                        AS total_revenue,
        TO_CHAR(AVG(SUM(final_sales)) OVER(ORDER BY the_year ROWS 2 PRECEDING), '9,999,999.99') AS moving_revenue
FROM    (
            SELECT  TO_CHAR(c.ca_orderdate,'YYYY')                          AS the_year,
                    f.total_sales,
                    c.ca_totalprice,
                    (SUM(co.col_lineprice)/c.ca_totalprice)                 AS percentage,
                    (f.total_sales*(SUM(co.col_lineprice)/c.ca_totalprice)) AS final_sales
            FROM    CateringServiceFACT_0 f, 
                    CateringOrderDIM_0 c, 
                    CateringOrderLineDIM_0 co, 
                    ProductCategoryBridgeDIM_0 p, 
                    CategoryDIM_0 ct
            WHERE   f.ca_orderid = c.ca_orderid
                    AND c.ca_orderid = co.ca_orderid
                    AND co.product_id = p.product_id
                    AND p.category_id = ct.category_id
                    AND ct.category_description = 'Savoury'
            GROUP   BY  c.ca_orderdate, 
                        f.total_sales, 
                        c.ca_totalprice)
GROUP   BY the_year;


/*----------------------------------------------- 
LEVEL 2
------------------------------------------------*/
-- Cumulative Revenue - What are the total catering sales and cumulative total catering sales of Savoury dishes in each year?
SELECT  the_year, 
        SUM(final_sales)                                                                                AS total_revenue,
        TO_CHAR(SUM(SUM(final_sales)) OVER(ORDER BY the_year ROWS UNBOUNDED PRECEDING), '9,999,999.99') AS cumulative_revenue
FROM    (
            SELECT  t.the_year,
                    f.total_sales,
                    c.ca_totalprice,
                    (SUM(co.col_lineprice)/c.ca_totalprice)                 AS percentage,
                    (f.total_sales*(SUM(co.col_lineprice)/c.ca_totalprice)) AS final_sales
            FROM    CateringServiceFact f, 
                    TimeDIM t, 
                    CateringOrderDIM c, 
                    CateringOrderLineDIM co, 
                    ProductCategoryBridgeDIM p, 
                    CategoryDIM ct
            WHERE   f.timeID = t.timeID
                    AND f.ca_orderid = c.ca_orderid
                    AND c.ca_orderid = co.ca_orderid
                    AND co.product_id = p.product_id
                    AND p.category_id = ct.category_id
                    AND ct.category_description = 'Savoury'
            GROUP   BY  t.the_year, 
                        f.total_sales,
                        c.ca_totalprice)
GROUP   BY the_year;


-- Moving Average - What are the total catering sales and moving catering sales of 3 yearly of Savoury dishes in each year?
SELECT  the_year, 
        SUM(final_sales)                                                                        AS total_revenue,
        TO_CHAR(AVG(SUM(final_sales)) OVER(ORDER BY the_year ROWS 2 PRECEDING), '9,999,999.99') AS moving_revenue
FROM    (
            SELECT  t.the_year,
                    f.total_sales,
                    c.ca_totalprice,
                    (SUM(co.col_lineprice)/c.ca_totalprice)                 AS percentage,
                    (f.total_sales*(SUM(co.col_lineprice)/c.ca_totalprice)) AS final_sales
            FROM    CateringServiceFact f, 
                    TimeDIM t, 
                    CateringOrderDIM c, 
                    CateringOrderLineDIM co, 
                    ProductCategoryBridgeDIM p, 
                    CategoryDIM ct
            WHERE   f.timeID = t.timeID
                    AND f.ca_orderid = c.ca_orderid
                    AND c.ca_orderid = co.ca_orderid
                    AND co.product_id = p.product_id
                    AND p.category_id = ct.category_id
                    AND ct.category_description = 'Savoury'
            GROUP   BY  t.the_year,
                        f.total_sales,
                        c.ca_totalprice)
GROUP   BY the_year;


-- Report 9:
/*----------------------------------------------- 
LEVEL 0
------------------------------------------------*/

-- Cumulative Aggregate: What are the total and cumulative catering promotion's value in each month-year?
SELECT  time_id, 
        SUM(promotion_val)                                                                                  AS promotion_val,
        TO_CHAR(SUM(SUM(promotion_val)) OVER(ORDER BY time_id ROWS UNBOUNDED PRECEDING), '9,999,999.99')    AS cumulative_promotion_val  
FROM    (
            SELECT  (TO_CHAR(c.ca_orderdate, 'YYYY') || TO_CHAR(c.ca_orderdate, 'MM')) AS time_id,
                    f.total_sales, 
                    c.ca_totalprice, 
                    f.total_delivery_cost,
                    (c.ca_totalprice + f.total_delivery_cost - f.total_sales) as promotion_val
            FROM    CateringServiceFACT_0 f, CateringOrderDIM_0 c, DeliveryProviderDIM_0 d
            WHERE   f.ca_orderid = c.ca_orderid
                    AND f.provider_id = d.provider_id
                    AND f.promo_code != 'no_pr'
            GROUP   BY  c.ca_orderdate, 
                        f.total_sales, 
                        c.ca_totalprice, 
                        f.total_delivery_cost)
GROUP   BY time_id;

-- Moving Aggregate: What are the total and moving catering promotion's value of 3 monthly?
SELECT  time_id, 
        SUM(promotion_val)                                                                          AS promotion_val,
        TO_CHAR(AVG(SUM(promotion_val)) OVER(ORDER BY time_id ROWS 2 PRECEDING), '9,999,999.99')    AS moving_3_month
FROM    (
            SELECT  (TO_CHAR(c.ca_orderdate, 'YYYY') || TO_CHAR(c.ca_orderdate, 'MM'))  AS time_id,
                    f.total_sales, 
                    c.ca_totalprice, 
                    f.total_delivery_cost,
                    (c.ca_totalprice + f.total_delivery_cost - f.total_sales)           AS promotion_val
            FROM    CateringServiceFACT_0 f, CateringOrderDIM_0 c, DeliveryProviderDIM_0 d
            WHERE   f.ca_orderid = c.ca_orderid
                    AND f.provider_id = d.provider_id
                    AND f.promo_code != 'no_pr'
            GROUP   BY  c.ca_orderdate, 
                        f.total_sales, 
                        c.ca_totalprice, 
                        f.total_delivery_cost)
GROUP   BY time_id;

/*----------------------------------------------- 
LEVEL 2
------------------------------------------------*/
-- Cumulative Aggregate: What are the total and cumulative catering promotion's value in each month-year?
SELECT  time_id, 
        SUM(promotion_val)                                                                                  AS promotion_val,
        TO_CHAR(SUM(SUM(promotion_val)) OVER(ORDER BY time_id ROWS UNBOUNDED PRECEDING), '9,999,999.99')    AS cumulative_promotion_val  
FROM    (
            SELECT  (t.the_year || t.the_month)                                 AS time_id,
                    f.total_sales, 
                    c.ca_totalprice, 
                    f.total_delivery_cost, 
                    (c.ca_totalprice + f.total_delivery_cost - f.total_sales)   AS promotion_val
            FROM    CateringServiceFACT f, 
                    CateringOrderDIM c, 
                    DeliveryProviderDIM d, 
                    TimeDIM t
            WHERE   f.ca_orderid = c.ca_orderid
                    AND f.timeID = t.timeID
                    AND f.provider_id = d.provider_id
                    AND f.promo_code != 'no_pr'
            GROUP   BY  t.the_year, 
                        t.the_month, 
                        f.total_sales, 
                        c.ca_totalprice, 
                        f.total_delivery_cost, 
                        f.ca_orderid)
GROUP   BY time_id;


-- Moving Aggregate: What are the total and moving catering promotion's value of 3 monthly?
SELECT  time_id, 
        SUM(promotion_val)                                                                          AS promotion_val,
        TO_CHAR(AVG(SUM(promotion_val)) OVER(ORDER BY time_id ROWS 2 PRECEDING), '9,999,999.99')    AS moving_3_month  
FROM    (
            SELECT  (t.the_year || t.the_month)                                 AS time_id,
                    f.total_sales, 
                    c.ca_totalprice, 
                    f.total_delivery_cost, 
                    (c.ca_totalprice + f.total_delivery_cost - f.total_sales)   AS promotion_val
            FROM    CateringServiceFACT f, 
                    CateringOrderDIM c, 
                    DeliveryProviderDIM d, 
                    TimeDIM t
            WHERE   f.ca_orderid = c.ca_orderid
                    AND f.timeID = t.timeID
                    AND f.provider_id = d.provider_id
                    AND f.promo_code != 'no_pr'
            GROUP   BY  t.the_year, 
                        t.the_month, 
                        f.total_sales, 
                        c.ca_totalprice, 
                        f.total_delivery_cost, 
                        f.ca_orderid)
GROUP   BY time_id;

-- Report 10:
/*----------------------------------------------- 
LEVEL 0
------------------------------------------------*/

-- Cumulative Aggregate: What are the total and cumulative number of canteen's order in each month-year?
SELECT  (TO_CHAR(c.sc_orderdate, 'YYYY') || TO_CHAR(c.sc_orderdate, 'MM'))  AS time_id,
        SUM(f.total_order_number)                                           AS total_order_number,
        TO_CHAR(SUM(SUM(f.total_order_number)) OVER
                (ORDER BY (TO_CHAR(c.sc_orderdate, 'YYYY') || TO_CHAR(c.sc_orderdate, 'MM')) ROWS UNBOUNDED PRECEDING), 
                            '9,999,999.99')                                 AS cumulative_order_number
FROM    CanteenServiceFACT_0 f, 
        CanteenOrderDIM_0 c
WHERE   f.sc_orderid = c.sc_orderid
GROUP   BY  (TO_CHAR(c.sc_orderdate, 'YYYY') || TO_CHAR(c.sc_orderdate, 'MM'));

-- Moving Aggregate: What are the total and moving number of canteen's order of 3 monthly?
SELECT  (TO_CHAR(c.sc_orderdate, 'YYYY') || TO_CHAR(c.sc_orderdate, 'MM'))  AS time_id,
        SUM(f.total_order_number)                                           AS total_order_number,
        TO_CHAR(AVG(SUM(f.total_order_number)) OVER
                (ORDER BY (TO_CHAR(c.sc_orderdate, 'YYYY') || TO_CHAR(c.sc_orderdate, 'MM')) ROWS 2 PRECEDING), 
                            '9,999,999.99')                                 AS moving_3_months
FROM    CanteenServiceFACT_0 f, 
        CanteenOrderDIM_0 c
WHERE   f.sc_orderid = c.sc_orderid
GROUP   BY (TO_CHAR(c.sc_orderdate, 'YYYY') || TO_CHAR(c.sc_orderdate, 'MM'));


/*----------------------------------------------- 
LEVEL 2
------------------------------------------------*/

-- Cumulative Aggregate: What are the total and cumulative number of canteen's order in each month-year?
SELECT  (t.the_year || t.the_month)                                     AS time_id,
        SUM(f.total_order_number)                                       AS total_order_number,
        TO_CHAR(SUM(SUM(f.total_order_number)) OVER 
                (ORDER BY (t.the_year || t.the_month) ROWS UNBOUNDED PRECEDING), 
                            '9,999,999.99')                             AS cumulative_order_number
FROM    CanteenServiceFACT f, 
        CanteenOrderDIM c, 
        TimeDIM t
WHERE   f.sc_orderid = c.sc_orderid
        AND f.timeID = t.timeID
GROUP   BY  t.the_year, 
            t.the_month;

-- Moving Aggregate: What are the total and moving number of canteen's order of 3 monthly?
SELECT  (t.the_year || t.the_month)                                     AS time_id,
        SUM(f.total_order_number)                                       AS total_order_number,
        TO_CHAR(AVG(SUM(f.total_order_number)) OVER 
                (ORDER BY (t.the_year || t.the_month) ROWS 2 PRECEDING), 
                            '9,999,999.99')                             AS moving_3_months
FROM    CanteenServiceFACT f, 
        CanteenOrderDIM c, 
        TimeDIM t
WHERE   f.sc_orderid = c.sc_orderid
        AND f.timeID = t.timeID
GROUP   BY  t.the_year, 
            t.the_month;