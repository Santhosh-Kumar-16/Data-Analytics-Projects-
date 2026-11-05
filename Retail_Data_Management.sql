
SET GLOBAL local_infile = 1;

USE retail_data_management;

-- ============================================================
-- LEVEL 1 TABLES (no dependencies) — load these first
-- ============================================================

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/suppliers.csv'
INTO TABLE suppliers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/promotions.csv'
INTO TABLE promotions
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- LEVEL 2 TABLES (depend on Level 1)
-- ============================================================

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- LEVEL 3 TABLES (depend on Level 2)
-- ============================================================

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- LEVEL 4 TABLES (depend on Level 3)
-- ============================================================

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/shipments.csv'
INTO TABLE shipments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- LEVEL 5 TABLES (depend on Level 4) — load these last
-- ============================================================

LOAD DATA LOCAL INFILE 'E:/Course/Projects/MYSQL/Retail_Data_Warehouse/Raw Files/returns.csv'
INTO TABLE returns
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- Verify row counts loaded into each table
-- ============================================================
SELECT 'categories' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'stores', COUNT(*) FROM stores
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'promotions', COUNT(*) FROM promotions
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL SELECT 'returns', COUNT(*) FROM returns;
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'retail_data_management'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;
SELECT 'employees -> stores' AS check_name, COUNT(*) AS orphan_count
FROM employees e LEFT JOIN stores s ON e.store_id = s.store_id
WHERE s.store_id IS NULL
 
UNION ALL
SELECT 'products -> categories', COUNT(*)
FROM products p LEFT JOIN categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL
 
UNION ALL
SELECT 'products -> suppliers', COUNT(*)
FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL
 
UNION ALL
SELECT 'orders -> customers', COUNT(*)
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
 
UNION ALL
SELECT 'orders -> stores', COUNT(*)
FROM orders o LEFT JOIN stores s ON o.store_id = s.store_id
WHERE s.store_id IS NULL
 
UNION ALL
SELECT 'orders -> promotions', COUNT(*)
FROM orders o LEFT JOIN promotions p ON o.promotion_id = p.promotion_id
WHERE o.promotion_id IS NOT NULL AND p.promotion_id IS NULL
 
UNION ALL
SELECT 'order_items -> orders', COUNT(*)
FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
 
UNION ALL
SELECT 'order_items -> products', COUNT(*)
FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
 
UNION ALL
SELECT 'payments -> orders', COUNT(*)
FROM payments pay LEFT JOIN orders o ON pay.order_id = o.order_id
WHERE o.order_id IS NULL
 
UNION ALL
SELECT 'shipments -> orders', COUNT(*)
FROM shipments sh LEFT JOIN orders o ON sh.order_id = o.order_id
WHERE o.order_id IS NULL
 
UNION ALL
SELECT 'returns -> order_items', COUNT(*)
FROM returns r LEFT JOIN order_items oi ON r.order_item_id = oi.order_item_id
WHERE oi.order_item_id IS NULL;
SELECT 
    s.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.qty * oi.price) AS total_revenue
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.city
ORDER BY total_revenue DESC
LIMIT 10;
SELECT 
    c.category_name,
    SUM(oi.qty) AS total_units_sold,
    SUM(oi.qty * oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;
SELECT 
    c.customer_id,
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(p.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.city
ORDER BY total_spent DESC
LIMIT 10;
SELECT 
    s.store_id,
    s.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(p.amount) AS total_revenue
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY s.store_id, s.city
ORDER BY total_revenue DESC
LIMIT 10;
SELECT 
    c.category_name,
    COUNT(DISTINCT oi.order_item_id) AS total_items_sold,
    COUNT(DISTINCT r.return_id) AS total_returns,
    ROUND(COUNT(DISTINCT r.return_id) * 100.0 / COUNT(DISTINCT oi.order_item_id), 2) AS return_rate_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
GROUP BY c.category_name
ORDER BY return_rate_pct DESC;
SELECT 
    CASE WHEN o.promotion_id IS NULL THEN 'No Promotion' ELSE 'With Promotion' END AS promo_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(p.amount), 2) AS avg_order_value,
    SUM(p.amount) AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY promo_status;
SELECT 
    pr.discount,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(p.amount), 2) AS avg_order_value
FROM orders o
JOIN promotions pr ON o.promotion_id = pr.promotion_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY pr.discount
ORDER BY pr.discount;
SELECT 
    e.store_id,
    s.city,
    COUNT(DISTINCT e.employee_id) AS num_employees,
    SUM(p.amount) AS total_store_revenue,
    ROUND(SUM(p.amount) / COUNT(DISTINCT e.employee_id), 2) AS revenue_per_employee
FROM employees e
JOIN stores s ON e.store_id = s.store_id
JOIN orders o ON s.store_id = o.store_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY e.store_id, s.city
ORDER BY revenue_per_employee DESC
LIMIT 10;
SELECT 
    sr.store_id,
    sr.city,
    ec.num_employees,
    sr.total_store_revenue,
    ROUND(sr.total_store_revenue / ec.num_employees, 2) AS revenue_per_employee
FROM (
    SELECT s.store_id, s.city, SUM(p.amount) AS total_store_revenue
    FROM stores s
    JOIN orders o ON s.store_id = o.store_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY s.store_id, s.city
) sr
JOIN (
    SELECT store_id, COUNT(*) AS num_employees
    FROM employees
    GROUP BY store_id
) ec ON sr.store_id = ec.store_id
ORDER BY revenue_per_employee DESC
LIMIT 10;
SELECT 
    status,
    COUNT(*) AS total_shipments,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM shipments
GROUP BY status
ORDER BY total_shipments DESC;
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(p.amount) AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month;
SELECT 
    sup.country,
    COUNT(DISTINCT p.product_id) AS num_products,
    SUM(oi.qty * oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN suppliers sup ON p.supplier_id = sup.supplier_id
GROUP BY sup.country
ORDER BY total_revenue DESC;
select count(*) from products;
show tables;
select count(*) from stores;