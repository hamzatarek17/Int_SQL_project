WITH customer_last_purchase AS (
	SELECT 
		customerkey,
		full_name,
		orderdate,
		row_number() OVER (PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
		first_purchase_date,
		cohort_year 
	FROM 
		cohort_analysis ca 
), Churned_customers AS (
	SELECT 
		customerkey,
		full_name, 
		orderdate AS last_purchase_date,
		CASE 
			WHEN orderdate < (SELECT max(orderdate)
	FROM sales) - INTERVAL '6 months' THEN 'Churned'
			ELSE 'Avtive'
		END AS customer_statues,
		cohort_year 
		
	FROM 
		customer_last_purchase 
	WHERE rn = 1
		AND first_purchase_date < (SELECT max(orderdate)
	FROM sales) - INTERVAL '6 months'
)
SELECT 	
	cohort_year ,
	customer_statues,
	count(customerkey) AS num_customers,
	sum(count(customerkey)) over(PARTITION BY cohort_year) AS total_customers,
	round(count(customerkey) / sum(count(customerkey)) over(PARTITION BY cohort_year), 2) AS status_percentage
FROM Churned_customers 
GROUP BY
	cohort_year,
	customer_statues
	 
 