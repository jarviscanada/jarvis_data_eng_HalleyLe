-- Show table schema 
\d+ retail;

-- Show first 10 rows
SELECT * FROM retail
LIMIT 10;

-- Check number of records
SELECT COUNT(*) FROM retail;

-- Number of clients (e.g. unique client ID)
SELECT COUNT(DISTINCT customer_id) FROM retail;

-- Invoice data range
SELECT MIN(invoice_date) AS earliest_date,
       MAX(invoice_date) AS latest_date
FROM retail;

-- Number of SKU/merchants (e.g. unique stock code)
SELECT COUNT(DISTINCT stock_code) FROM retail;

-- Average invoice amount excluding invoices with a negative amount
SELECT AVG(total_amount) AS avg_invoice_amount
FROM (
    SELECT invoice_no, SUM(quantity*unit_price) AS total_amount
    FROM retail
    GROUP BY invoice_no
    HAVING SUM(quantity*unit_price) > 0
) AS positive_invoice;

-- Total revenue
SELECT SUM(quantity*unit_price) AS total_revenue
FROM retail;

-- Total revenue by YYYYMM
SELECT CAST(EXTRACT(YEAR FROM invoice_date) * 100 + EXTRACT(MONTH FROM invoice_date) AS INTEGER) AS yyyymm,
	SUM(quantity*unit_price) AS total_revenue
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;
