WITH PaymentSum AS (
    SELECT 
        order_id, 
        SUM(CAST(payment_value AS FLOAT)) AS Total_Order_Revenue
    FROM olist_order_payments_dataset
    GROUP BY order_id
),
MonthlySales AS (
    SELECT 
        YEAR(o.order_purchase_timestamp) AS OrderYear,
        MONTH(o.order_purchase_timestamp) AS OrderMonth,
        COUNT(o.order_id) AS Total_Orders,
        ROUND(SUM(p.Total_Order_Revenue), 2) AS Total_Revenue
    FROM olist_orders_dataset o
    JOIN PaymentSum p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
)
SELECT 
    OrderYear,
    OrderMonth,
    Total_Orders,
    Total_Revenue,
    SUM(Total_Revenue) OVER (ORDER BY OrderYear, OrderMonth) AS Running_Total
FROM MonthlySales;

WITH CustomerLastOrder AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
MaxDate AS (
    SELECT MAX(order_purchase_timestamp) AS max_dataset_date 
    FROM olist_orders_dataset
),
ChurnCalculation AS (
    SELECT 
        c.customer_unique_id,
        c.last_order_date,
        DATEDIFF(day, c.last_order_date, m.max_dataset_date) AS days_since_last_order
    FROM CustomerLastOrder c
    CROSS JOIN MaxDate m
)
SELECT 
    CASE 
        WHEN days_since_last_order > 180 THEN 'Churned (Inactive > 6 months)'
        ELSE 'Active (Ordered in last 6 months)'
    END AS Customer_Status,
    COUNT(customer_unique_id) AS Total_Customers
FROM ChurnCalculation
GROUP BY 
    CASE 
        WHEN days_since_last_order > 180 THEN 'Churned (Inactive > 6 months)'
        ELSE 'Active (Ordered in last 6 months)'
    END;
   
