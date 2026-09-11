-- ============================================================
-- NORTHWIND SALES & OPERATIONS ANALYSIS
-- SQL Portfolio Project
-- Database: northwind_analysis
-- Tool: MySQL Workbench
-- ============================================================
USE northwind_analysis;
-- ============================================================
-- 1. BUSINESS OVERVIEW
-- ============================================================
-- 1.1 Total Sales
SELECT 
    ROUND(SUM(od.quantity * od.unitPrice * (1 - od.discount)), 2) AS total_sales
FROM order_details od;


-- 1.2 Total Orders
SELECT 
    COUNT(*) AS total_orders
FROM orders;


-- 1.3 Average Order Value
SELECT 
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount))
        / COUNT(DISTINCT od.orderID),
        2
    ) AS average_order_value
FROM order_details od;


-- 1.4 Total Customers
SELECT 
    COUNT(*) AS total_customers
FROM customers;


-- 1.5 Total Products
SELECT 
    COUNT(*) AS total_products
FROM products;
-- ============================================================
-- 2. SALES ANALYSIS
-- ============================================================
-- 2.1 Sales by Category
SELECT
    c.categoryName,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS total_sales
FROM order_details od
JOIN products p
    ON od.productID = p.productID
JOIN categories c
    ON p.categoryID = c.categoryID
GROUP BY c.categoryName
ORDER BY total_sales DESC;


-- 2.2 Top 10 Products by Sales
SELECT
    p.productName,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS total_sales
FROM order_details od
JOIN products p
    ON od.productID = p.productID
GROUP BY p.productName
ORDER BY total_sales DESC
LIMIT 10;


-- 2.3 Monthly Sales Trend
SELECT
    YEAR(o.orderDate) AS sales_year,
    MONTH(o.orderDate) AS sales_month,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS total_sales
FROM order_details od
JOIN orders o
    ON od.orderID = o.orderID
GROUP BY
    YEAR(o.orderDate),
    MONTH(o.orderDate)
ORDER BY
    sales_year,
    sales_month;


-- 2.4 Sales by Country
SELECT
    c.country,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS total_sales
FROM order_details od
JOIN orders o
    ON od.orderID = o.orderID
JOIN customers c
    ON o.customerID = c.customerID
GROUP BY c.country
ORDER BY total_sales DESC;
-- ============================================================
-- 3. CUSTOMER ANALYSIS
-- ============================================================
-- 3.1 Top 10 Customers by Revenue
SELECT
    c.companyName,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS total_sales
FROM order_details od
JOIN orders o
    ON od.orderID = o.orderID
JOIN customers c
    ON o.customerID = c.customerID
GROUP BY c.companyName
ORDER BY total_sales DESC
LIMIT 10;


-- 3.2 Top 10 Customers by Order Frequency
SELECT
    c.companyName,
    COUNT(DISTINCT o.orderID) AS total_orders
FROM customers c
JOIN orders o
    ON c.customerID = o.customerID
GROUP BY c.companyName
ORDER BY total_orders DESC
LIMIT 10;


-- 3.3 Top 10 Customers by Average Order Value
SELECT
    c.companyName,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount))
        / COUNT(DISTINCT o.orderID),
        2
    ) AS average_order_value
FROM customers c
JOIN orders o
    ON c.customerID = o.customerID
JOIN order_details od
    ON o.orderID = od.orderID
GROUP BY c.companyName
ORDER BY average_order_value DESC
LIMIT 10;
-- ============================================================
-- 4. PRODUCT ANALYSIS
-- ============================================================
-- 4.1 Top 10 Products by Quantity Sold
SELECT
    p.productName,
    SUM(od.quantity) AS total_quantity_sold
FROM products p
JOIN order_details od
    ON p.productID = od.productID
GROUP BY p.productName
ORDER BY total_quantity_sold DESC
LIMIT 10;


-- 4.2 Top 10 Products by Average Unit Price
SELECT
    p.productName,
    ROUND(AVG(od.unitPrice), 2) AS average_unit_price
FROM products p
JOIN order_details od
    ON p.productID = od.productID
GROUP BY p.productName
ORDER BY average_unit_price DESC
LIMIT 10;


-- 4.3 Discontinued Product Count
SELECT
    COUNT(*) AS discontinued_products
FROM products
WHERE discontinued = 1;


-- 4.4 Sales from Discontinued Products
SELECT
    p.productName,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS total_sales
FROM products p
JOIN order_details od
    ON p.productID = od.productID
WHERE p.discontinued = 1
GROUP BY p.productName
ORDER BY total_sales DESC;
-- ============================================================
-- 5. EMPLOYEE ANALYSIS
-- ============================================================
-- 5.1 Sales by Employee
SELECT
    e.employeeName,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS total_sales
FROM order_details od
JOIN orders o
    ON od.orderID = o.orderID
JOIN employees e
    ON o.employeeID = e.employeeID
GROUP BY e.employeeName
ORDER BY total_sales DESC;
-- ============================================================
-- 6. SHIPPING & OPERATIONS
-- ============================================================
-- 6.1 Average Shipping Time
SELECT
    ROUND(AVG(DATEDIFF(shippedDate, orderDate)), 2) AS average_shipping_days
FROM orders
WHERE shippedDate IS NOT NULL;


-- 6.2 On-Time vs Late Shipping
SELECT
    CASE
        WHEN shippedDate <= requiredDate THEN 'On Time'
        ELSE 'Late'
    END AS shipping_status,
    COUNT(*) AS order_count
FROM orders
WHERE shippedDate IS NOT NULL
GROUP BY shipping_status;


-- 6.3 Total Freight
SELECT
    ROUND(SUM(freight), 2) AS total_freight
FROM orders;


-- 6.4 Minimum, Average and Maximum Freight
SELECT
    ROUND(MIN(freight), 2) AS min_freight,
    ROUND(AVG(freight), 2) AS avg_freight,
    ROUND(MAX(freight), 2) AS max_freight
FROM orders;


-- 6.5 Orders by Shipper
SELECT
    s.companyName,
    COUNT(o.orderID) AS total_orders
FROM shippers s
JOIN orders o
    ON s.shipperID = o.shipperID
GROUP BY s.companyName
ORDER BY total_orders DESC;
-- 6.6 Top 10 Orders by Freight Cost
SELECT
    orderID,
    ROUND(freight, 2) AS freight
FROM orders
ORDER BY freight DESC
LIMIT 10;


-- 6.7 Order Value vs Freight for Top Freight Orders
SELECT
    o.orderID,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS order_value,
    ROUND(o.freight, 2) AS freight
FROM orders o
JOIN order_details od
    ON o.orderID = od.orderID
GROUP BY o.orderID, o.freight
ORDER BY o.freight DESC
LIMIT 10;


-- 6.8 Orders Where Freight Exceeds Order Value
SELECT
    COUNT(*) AS orders_with_high_freight
FROM (
    SELECT
        o.orderID,
        SUM(od.quantity * od.unitPrice * (1 - od.discount)) AS order_value,
        o.freight
    FROM orders o
    JOIN order_details od
        ON o.orderID = od.orderID
    GROUP BY o.orderID, o.freight
) AS order_summary
WHERE freight > order_value;
-- ============================================================
-- 7. TIME-BASED ANALYSIS
-- ============================================================


-- 7.1 Year-wise Sales
SELECT
    YEAR(o.orderDate) AS sales_year,
    ROUND(
        SUM(od.quantity * od.unitPrice * (1 - od.discount)),
        2
    ) AS total_sales
FROM orders o
JOIN order_details od
    ON o.orderID = od.orderID
GROUP BY YEAR(o.orderDate)
ORDER BY sales_year;


-- 7.2 Year-wise Order Count
SELECT
    YEAR(orderDate) AS order_year,
    COUNT(*) AS total_orders
FROM orders
GROUP BY YEAR(orderDate)
ORDER BY order_year;