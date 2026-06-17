/* Exploring Measures */

-- Checking the total sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales


-- Checking how many items are sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales


-- Checking the average selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales


-- Checking the total number of orders
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales  -- without duplicates


-- Checking the total number of products
SELECT COUNT(product_name) AS total_products FROM gold.dim_products
SELECT COUNT(DISTINCT product_name) AS total_products FROM gold.dim_products


-- Checking the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers


-- Checking the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales

