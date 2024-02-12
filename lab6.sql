
#Step 1: Create a View
#rst, create a view that summarizes rental information for each customer.
# The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW rental_info AS
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email, COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r
 ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

# Step 2: Create a Temporary Table
#ext, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
#the Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer
CREATE TEMPORARY TABLE IF NOT EXISTS customer_payment_summary AS
SELECT ri.customer_id, ri.customer_name, ri.email, COALESCE(SUM(p.amount), 0) AS total_paid,rental_count  
FROM rental_info ri
LEFT JOIN payment p
 ON ri.customer_id = p.customer_id
GROUP BY ri.customer_id, ri.customer_name, ri.email;

#Step 3: Create a CTE and the Customer Summary Report
#Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
#The CTE should include the customer's name, email address, rental count, and total amount paid.
#Next, using the CTE, create the query to generate the final customer summary report, which should include:
# customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary_cte AS (
    SELECT cps.customer_name, cps.email, cps.rental_count, cps.total_paid,
           CASE 
               WHEN cps.rental_count > 0 THEN cps.total_paid / cps.rental_count
               ELSE 0
           END AS average_payment_per_rental
    FROM customer_payment_summary cps
)
SELECT * FROM customer_summary_cte;