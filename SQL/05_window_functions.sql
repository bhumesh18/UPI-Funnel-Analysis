-- Use window functions (Postgres & SQLite 3.25+ support window functions)
-- 1. Top error codes per bank (ranked)

WITH failures AS (
  SELECT
    bank_name,
    final_error_code,
    COUNT(*) AS fail_count
  FROM upi_transactions
  WHERE txn_success = 0 OR txn_success = 'False' OR txn_success = 'false'
  GROUP BY bank_name, final_error_code
)
SELECT
  bank_name,
  final_error_code,
  fail_count,
  RANK() OVER (PARTITION BY bank_name ORDER BY fail_count DESC) AS error_rank
FROM failures
ORDER BY bank_name, error_rank
LIMIT 200;

-- 2. Example: for each transaction, compute time-ordered event rows and a row_number per transaction
-- (useful for reconstructing first/last event)
SELECT
  txn_id,
  stage,
  event_time,
  ROW_NUMBER() OVER (PARTITION BY txn_id ORDER BY event_time) AS seq_in_txn
FROM upi_txn_events
ORDER BY txn_id, seq_in_txn
LIMIT 100;
