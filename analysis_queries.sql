
-- This SQL script creates a sample sales table and performs various analyses to understand customer spending patterns, revenue trends, and customer segmentation.
-- 1. CREATE TABLE
DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    category VARCHAR(50)
);

-
INSERT INTO sales VALUES
(1,101,'2024-01-05',250,'Electronics'),
(2,102,'2024-01-10',120,'Clothing'),
(3,101,'2024-02-12',300,'Electronics'),
(4,103,'2024-02-15',450,'Furniture'),
(5,104,'2024-03-01',200,'Clothing'),
(6,102,'2024-03-05',180,'Electronics'),
(7,105,'2024-03-20',600,'Furniture'),
(8,101,'2024-04-02',150,'Clothing'),
(9,106,'2024-04-10',700,'Electronics'),
(10,107,'2024-04-15',90,'Clothing');

--3. TOTAL SPENDING PER CUSTOMER
SELECT customer_id, SUM(amount) AS total_spent
FROM sales
GROUP BY customer_id
ORDER BY total_spent DESC;

-- 4. TOP 10 CUSTOMERS
SELECT customer_id, SUM(amount) AS total_spent
FROM sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- 5. MONTHLY REVENUE
SELECT DATE_TRUNC('month', order_date) AS month,
       SUM(amount) AS revenue
FROM sales
GROUP BY month
ORDER BY month;

-- 6. AVERAGE SPEND PER CUSTOMER
SELECT AVG(total_spent) AS avg_customer_spend
FROM (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM sales
    GROUP BY customer_id
) sub;

-- 7. REPEAT VS ONE-TIME CUSTOMERS
SELECT customer_type, COUNT(*) AS num_customers
FROM (
    SELECT customer_id,
           CASE WHEN COUNT(order_id) = 1 THEN 'One-time'
                ELSE 'Repeat'
           END AS customer_type
    FROM sales
    GROUP BY customer_id
) sub
GROUP BY customer_type;

-- 8. REVENUE BY CATEGORY
SELECT category, SUM(amount) AS total_revenue
FROM sales
GROUP BY category
ORDER BY total_revenue DESC;

-- 9. MONTH-OVER-MONTH GROWTH
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) /
             LAG(revenue) OVER (ORDER BY month), 2) AS growth_rate
FROM (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(amount) AS revenue
    FROM sales
    GROUP BY month
) sub;

-- 10. CUSTOMER SEGMENTATION
SELECT customer_id, total_spent,
       CASE WHEN total_spent > 1000 THEN 'High Value'
            WHEN total_spent > 500 THEN 'Medium Value'
            ELSE 'Low Value'
       END AS segment
FROM (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM sales
    GROUP BY customer_id
) sub
ORDER BY total_spent DESC;