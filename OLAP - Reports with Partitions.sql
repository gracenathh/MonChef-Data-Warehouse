/*
Group MA1
Ahmed Mohamed H A Nassar - 28901797
Grace Nathania - 30241510
Kelvin Kan Jia Yaw - 29764920

Submitted on: November 4 2020

Task 3 D: Report 11, 12
*/
-- REPORT 11: Show ranking of each cuisine based on the monthly total number of 
-- sales for school canteen orders and the ranking of each customer type based 
-- on the monthly total number of sales for school canteen orders.

-- lvl 2

SELECT
    category_description    AS cuisine,
    cust.type_description   AS customer_type,
    the_month               AS month,
    SUM(total_order_number) AS "Monthly Total Number of Sales",
    RANK() OVER(
        PARTITION BY category_description
        ORDER BY
            SUM(total_order_number) DESC
    ) AS rank_by_cuisine,
    RANK() OVER(
        PARTITION BY cust.type_description
        ORDER BY
            SUM(total_order_number) DESC
    ) AS rank_by_customer_type
FROM
    canteenservicefact         c
    JOIN timedim                    t
    ON c.timeid = t.timeid
    JOIN customertypedim            cust
    ON cust.cust_type_id = c.cust_type_id
    JOIN canteenorderdim            co
    ON c.sc_orderid = co.sc_orderid
    JOIN canteenorderlinedim        col
    ON co.sc_orderid = col.sc_orderid
    JOIN productdim                 p
    ON p.product_id = col.product_id
    JOIN productcategorybridgedim   pc
    ON p.product_id = pc.product_id
    JOIN categorydim                cate
    ON cate.category_id = pc.category_id
WHERE
    category_type = 'cuisine'
GROUP BY
    category_description,
    cust.type_description,
    the_month
ORDER BY
    category_description,
    rank_by_cuisine,
    rank_by_customer_type;
    
    
-- lvl 0

SELECT
    category_description    AS cuisine,
    cust.type_description   AS customer_type,
    to_char(sc_orderdate, 'MM') AS month,
    SUM(total_order_number) AS "Monthly Total Number of Sales",
    RANK() OVER(
        PARTITION BY category_description
        ORDER BY
            SUM(total_order_number) DESC
    ) AS rank_by_cuisine,
    RANK() OVER(
        PARTITION BY cust.type_description
        ORDER BY
            SUM(total_order_number) DESC
    ) AS rank_by_customer_type
FROM
    canteenservicefact_0         c
    JOIN customertypedim_0            cust
    ON cust.cust_type_id = c.cust_type_id
    JOIN canteenorderdim_0            co
    ON c.sc_orderid = co.sc_orderid
    JOIN canteenorderlinedim_0        col
    ON co.sc_orderid = col.sc_orderid
    JOIN productdim_0                 p
    ON p.product_id = col.product_id
    JOIN productcategorybridgedim_0   pc
    ON p.product_id = pc.product_id
    JOIN categorydim_0                cate
    ON cate.category_id = pc.category_id
WHERE
    category_type = 'cuisine'
GROUP BY
    category_description,
    cust.type_description,
    to_char(sc_orderdate, 'MM')
ORDER BY
    category_description,
    rank_by_cuisine,
    rank_by_customer_type;

    
-- report 12: cumulative total school canteen sales of each meal based on month

-- lvl 2

SELECT
    category_description   AS meal,
    the_month              AS month,
    to_char(SUM(total_sales *(sol_lineprice / sc_totalprice)), '9,999,999,999.99'
    ) AS "Monthly Total Sales",
    to_char(SUM(SUM(total_sales *(sol_lineprice / sc_totalprice))) OVER(
        PARTITION BY category_description
        ORDER BY
            category_description, the_month
        ROWS UNBOUNDED PRECEDING
    ), '9,999,999,999.99') AS cum_sales
FROM
    canteenservicefact         c
    JOIN timedim                    t
    ON c.timeid = t.timeid
    JOIN customertypedim            cust
    ON cust.cust_type_id = c.cust_type_id
    JOIN canteenorderdim            co
    ON c.sc_orderid = co.sc_orderid
    JOIN canteenorderlinedim        col
    ON co.sc_orderid = col.sc_orderid
    JOIN productdim                 p
    ON p.product_id = col.product_id
    JOIN productcategorybridgedim   pc
    ON p.product_id = pc.product_id
    JOIN categorydim                cate
    ON cate.category_id = pc.category_id
WHERE
    category_type = 'meal'
GROUP BY
    category_description,
    the_month
ORDER BY
    category_description,
    the_month;

-- lvl 0

SELECT
    category_description AS meal,
    to_char(sc_orderdate, 'MM') AS month,
    to_char(SUM(total_sales *(sol_lineprice / sc_totalprice)), '9,999,999,999.99'
    ) AS "Monthly Total Sales",
    to_char(SUM(SUM(total_sales *(sol_lineprice / sc_totalprice))) OVER(
        PARTITION BY category_description
        ORDER BY
            category_description, to_char(sc_orderdate, 'MM')
        ROWS UNBOUNDED PRECEDING
    ), '9,999,999,999.99') AS cum_sales
FROM
    canteenservicefact_0         c
    JOIN customertypedim_0            cust
    ON cust.cust_type_id = c.cust_type_id
    JOIN canteenorderdim_0            co
    ON c.sc_orderid = co.sc_orderid
    JOIN canteenorderlinedim_0        col
    ON co.sc_orderid = col.sc_orderid
    JOIN productdim_0                 p
    ON p.product_id = col.product_id
    JOIN productcategorybridgedim_0   pc
    ON p.product_id = pc.product_id
    JOIN categorydim_0                cate
    ON cate.category_id = pc.category_id
WHERE
    category_type = 'meal'
GROUP BY
    category_description,
    to_char(sc_orderdate, 'MM')
ORDER BY
    category_description,
    to_char(sc_orderdate, 'MM');