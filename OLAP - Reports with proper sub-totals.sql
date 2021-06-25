/*
Group MA1
Ahmed Mohamed H A Nassar - 28901797
Grace Nathania - 30241510
Kelvin Kan Jia Yaw - 29764920

Submitted on: November 4 2020

Task 3 B: Report 4,5,6,7
*/
-- Report 4 What are the subtotals and total catering sales from each promotion, time period (month), and delivery service provider?
-- lvl 2
SELECT
    promo_code             AS promotion,
    the_month              AS month,
    provider_description   AS "Delivery Service Provider",
    SUM(total_sales) AS total_sales
FROM
    cateringservicefact   c
    JOIN deliveryproviderdim   d
    ON c.provider_id = d.provider_id
    JOIN timedim               t
    ON c.timeid = t.timeid
GROUP BY
    CUBE(promo_code,
         the_month,
         provider_description)
ORDER BY the_month, provider_description, promo_code;

-- lvl 0

SELECT
    promo_code             AS promotion,
    to_char(ca_orderdate, 'MM') AS month,
    provider_description   AS "Delivery Service Provider",
    SUM(total_sales) AS total_sales
FROM
    cateringservicefact_0   c
    JOIN deliveryproviderdim_0   d
    ON c.provider_id = d.provider_id
    JOIN cateringorderdim_0      co
    ON c.ca_orderid = co.ca_orderid
GROUP BY
    CUBE(promo_code,
         to_char(ca_orderdate, 'MM'),
         provider_description)
ORDER By to_char(ca_orderdate, 'MM'),provider_description, promo_code;


-- report 5: What are the subtotals and total catering sales from each promotion, time period (month), and delivery service provider?
-- partial cube
-- lvl 2

SELECT
    promo_code             AS promotion,
    the_month              AS month,
    provider_description   AS "Delivery Service Provider",
    SUM(total_sales) AS total_sales
FROM
    cateringservicefact   c
    JOIN deliveryproviderdim   d
    ON c.provider_id = d.provider_id
    JOIN timedim               t
    ON c.timeid = t.timeid
GROUP BY
    promo_code,
    CUBE(the_month,
         provider_description)
ORDER BY the_month, provider_description, promo_code;
-- lvl 0

SELECT
    promo_code             AS promotion,
    to_char(ca_orderdate, 'MM') AS month,
    provider_description   AS "Delivery Service Provider",
    SUM(total_sales) AS total_sales
FROM
    cateringservicefact_0   c
    JOIN deliveryproviderdim_0   d
    ON c.provider_id = d.provider_id
    JOIN cateringorderdim_0      co
    ON c.ca_orderid = co.ca_orderid
GROUP BY
    promo_code,
    CUBE(to_char(ca_orderdate, 'MM'),
         provider_description)
ORDER By to_char(ca_orderdate, 'MM'),provider_description, promo_code;

-- report 6  Total weekly days sales canteen sales per month
-- lvl 2

SELECT
    the_month   AS month,
    weeklyday   AS day,
    SUM(total_sales) AS total_sales
FROM
    canteenservicefact   c
    JOIN timedim              t
    ON c.timeid = t.timeid
GROUP BY
    ROLLUP(the_month,
           weeklyday)
ORDER BY
    the_month;

-- lvl 0

SELECT
    to_char(sc_orderdate, 'MM') AS month,
    to_char(sc_orderdate, 'Day') AS day,
    SUM(total_sales) AS total_sales
FROM
    canteenservicefact_0   c
    JOIN canteenorderdim_0      co
    ON c.sc_orderid = co.sc_orderid
GROUP BY
    ROLLUP(to_char(sc_orderdate, 'MM'),
           to_char(sc_orderdate, 'Day'))
ORDER BY
    to_char(sc_orderdate, 'MM');

-- report 7 monthly total delivery cost per provider
-- lvl 2

SELECT
    the_month              AS month,
    provider_description   AS "Delivery Provider",
    SUM(total_delivery_cost) AS total_sales
FROM
    cateringservicefact   c
    JOIN timedim               t
    ON c.timeid = t.timeid
    JOIN deliveryproviderdim   d
    ON d.provider_id = c.provider_id
GROUP BY
    the_month,
    ROLLUP(provider_description)
ORDER BY
    the_month;

-- lvl 0

SELECT
    to_char(ca_orderdate, 'MM') AS month,
    provider_description AS "Delivery Provider",
    SUM(total_delivery_cost) AS total_sales
FROM
    cateringservicefact_0   c
    JOIN cateringorderdim_0      co
    ON c.ca_orderid = co.ca_orderid
    JOIN deliveryproviderdim_0   d
    ON d.provider_id = c.provider_id
GROUP BY
    to_char(ca_orderdate, 'MM'),
    ROLLUP(provider_description)
ORDER BY
    to_char(ca_orderdate, 'MM');
