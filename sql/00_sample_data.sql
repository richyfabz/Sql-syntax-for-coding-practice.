-- Shared PostgreSQL 14+ fixtures. Rerunning restores only the sql_practice schema.
-- Use a dedicated practice database: this resets all objects in that schema.
BEGIN;
DROP SCHEMA IF EXISTS sql_practice CASCADE;
CREATE SCHEMA sql_practice;
SET search_path TO sql_practice, public;

CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY, customer_name TEXT NOT NULL,
    country TEXT, created_at DATE, referred_by BIGINT REFERENCES customers(customer_id)
);
INSERT INTO customers VALUES
(201, 'Ada Okafor', 'Nigeria', '2025-12-01', NULL),
(202, 'Kofi Mensah', 'Ghana', '2025-12-02', 201),
(203, 'Zainab Bello', 'Nigeria', '2025-12-03', 201),
(204, 'Maya Cole', 'Kenya', '2025-12-04', NULL),
(205, 'Tunde Ade', 'Nigeria', '2025-12-05', 202);

CREATE TABLE payment_providers (provider_id BIGINT PRIMARY KEY, provider_name TEXT NOT NULL);
INSERT INTO payment_providers VALUES (1, 'Paystack'), (2, 'Flutterwave');
CREATE TABLE payment_transactions (
    transaction_id BIGINT PRIMARY KEY,
    -- No customer FK: customer 999 deliberately demonstrates an unmatched payment.
    customer_id BIGINT, provider_id BIGINT REFERENCES payment_providers(provider_id),
    amount NUMERIC(18,2) NOT NULL CHECK (amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('Success', 'Failed', 'Pending')),
    transaction_date DATE NOT NULL, updated_at TIMESTAMP NOT NULL
);
-- Same amounts and dates deliberately exercise ranking ties and deterministic ordering.
INSERT INTO payment_transactions VALUES
(101,201,1,60000,'Success','2026-01-10','2026-11-26 10:00:00'),
(102,201,1,60000,'Success','2026-01-10','2026-11-26 10:15:00'),
(103,201,1,20000,'Success','2026-02-10','2026-11-26 11:00:00'),
(104,202,1,40000,'Success','2026-02-15','2026-11-26 11:00:01'),
(105,202,1,15000,'Pending','2026-03-01','2026-11-26 09:59:59'),
(106,203,1,10000,'Failed','2026-03-02','2026-11-26 10:30:00'),
(107,203,2,30000,'Success','2026-03-10','2026-11-26 10:45:00'),
(108,203,2,20000,'Success','2026-03-11','2026-11-26 11:15:00'),
(109,999,2,5000,'Success','2026-03-12','2026-11-26 10:20:00'),
(110,204,2,8000,'Failed','2026-03-13','2026-11-26 10:25:00');

CREATE TABLE refunds (
    refund_id BIGINT PRIMARY KEY, transaction_id BIGINT REFERENCES payment_transactions(transaction_id),
    refund_amount NUMERIC(18,2), refund_date DATE
);
INSERT INTO refunds VALUES
(1,101,5000,'2026-01-11'), (2,101,2000,'2026-01-12'), (3,107,3000,'2026-03-12');
CREATE TABLE raw_customer (customer_id BIGINT, customer_name TEXT, email TEXT, country TEXT);
INSERT INTO raw_customer VALUES
(201,'  Ada Okafor  ',' ADA@EXAMPLE.COM ',' ng '),
(202,' Kofi Mensah ','kofi@example.com',' gh '),
(203,'   ','   ','   '), (204,NULL,NULL,NULL);
-- Materialized source snapshots stay unchanged when payment_transactions is updated.
CREATE TABLE raw_transactions AS SELECT * FROM payment_transactions;
CREATE TABLE raw_payment_event (transaction_id BIGINT, amount NUMERIC(18,2), updated_at TIMESTAMP);
INSERT INTO raw_payment_event VALUES
(301,1000,'2026-11-16 09:00:00'), -- excluded: exactly at lower watermark
(302,2000,'2026-11-16 09:00:01'), -- included
(303,3000,'2026-11-16 10:00:00'), -- included: exactly at upper cutoff
(304,4000,'2026-11-16 10:00:01'); -- excluded: after cutoff
CREATE TABLE etl_watermarks (pipeline_name TEXT PRIMARY KEY, last_processed_at TIMESTAMP);
INSERT INTO etl_watermarks VALUES ('payment_pipeline','2026-11-16 09:00:00');
CREATE TABLE fact_orders (
    order_id BIGINT PRIMARY KEY, customer_id BIGINT, order_date DATE,
    total_amount NUMERIC(18,2), currency_code TEXT
);
INSERT INTO fact_orders
SELECT transaction_id, customer_id, transaction_date, amount, 'NGN' FROM payment_transactions;
CREATE TABLE sales (product TEXT, month TEXT, sales NUMERIC(18,2));
INSERT INTO sales VALUES
('Widget','Jan',100),('Widget','Jan',50),('Widget','Feb',200),('Widget','Mar',300),
('Gadget','Jan',80),('Gadget','Mar',120);
CREATE TABLE sales_pivoted AS
SELECT product, SUM(sales) FILTER (WHERE month='Jan') AS jan,
    SUM(sales) FILTER (WHERE month='Feb') AS feb,
    SUM(sales) FILTER (WHERE month='Mar') AS mar
FROM sales GROUP BY product;
COMMIT;
