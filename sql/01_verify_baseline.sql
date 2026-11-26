-- Run immediately after 00_sample_data.sql, before the status-update procedure.
-- Any unexpected fixture/result raises an error rather than silently passing.
\set ON_ERROR_STOP on
SET search_path TO sql_practice, public;
DO $$
BEGIN
    ASSERT (SELECT COUNT(*) FROM payment_transactions) = 10, 'Expected 10 payments';
    ASSERT (SELECT SUM(amount) FROM payment_transactions WHERE status='Success') = 235000,
        'Expected successful volume 235000';
    ASSERT (SELECT COUNT(*) FROM customers c LEFT JOIN payment_transactions t
        ON c.customer_id=t.customer_id WHERE t.transaction_id IS NULL) = 1,
        'Expected one customer with no payments';
    ASSERT (SELECT amount - (SELECT SUM(refund_amount) FROM refunds WHERE transaction_id=101)
        FROM payment_transactions WHERE transaction_id=101) = 53000,
        'Expected payment 101 net amount 53000';
    ASSERT (SELECT COUNT(*) FROM raw_payment_event WHERE updated_at > TIMESTAMP '2026-11-16 09:00:00'
        AND updated_at <= TIMESTAMP '2026-11-16 10:00:00') = 2,
        'Expected two incremental events';
END;
$$;
