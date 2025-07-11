CREATE OR REPLACE VIEW public.cohort_analysis
AS WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS num_orders,
            max(c.countryfull::text) AS countryfull,
            max(c.age) AS age,
            max(c.givenname::text) AS givenname,
            max(c.surname::text) AS surname
           FROM sales s
             JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY s.customerkey, s.orderdate
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
    num_orders,
    countryfull,
    age,
    concat(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS full_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;