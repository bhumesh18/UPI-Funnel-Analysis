-- Examples of joining event rows to transaction metadata.

-- 1. Simple join: show event rows with bank & device for inspection
SELECT e.txn_id, e.stage, e.event_time, t.bank_name, t.device_type, t.txn_value_inr, t.txn_success
FROM upi_txn_events e
JOIN upi_transactions t ON e.txn_id = t.txn_id
LIMIT 50;

-- 2. Stage counts by bank (how many txns per bank reached each stage)
SELECT
  t.bank_name,
  e.stage,
  COUNT(DISTINCT e.txn_id) AS txn_count
FROM upi_txn_events e
JOIN upi_transactions t ON e.txn_id = t.txn_id
GROUP BY t.bank_name, e.stage
ORDER BY t.bank_name,
  CASE e.stage
    WHEN 'init' THEN 1
    WHEN 'amount_entered' THEN 2
    WHEN 'pin_entered' THEN 3
    WHEN 'bank_auth' THEN 4
    WHEN 'completed' THEN 5
    ELSE 99 END;
