-- Simple aggregated metrics you’ll use often.

-- 1. Global funnel counts by stage (how many unique txns reached each stage)

SELECT
  stage,
  COUNT(DISTINCT txn_id) AS txn_count
FROM upi_txn_events
GROUP BY stage
ORDER BY CASE stage
  WHEN 'init' THEN 1
  WHEN 'amount_entered' THEN 2
  WHEN 'pin_entered' THEN 3
  WHEN 'bank_auth' THEN 4
  WHEN 'completed' THEN 5
  ELSE 99 END;

-- 2. Overall success rate (transactions completed / total unique transactions)
SELECT
  (SUM(CASE WHEN txn_success = 1 OR txn_success = 'True' OR txn_success = 'true' THEN 1 ELSE 0 END) * 1.0)
  / NULLIF(COUNT(*),0) AS overall_success_rate
FROM upi_transactions;

-- 3. Transactions per bank (volume + success rate)
SELECT
  bank_name,
  COUNT(*) AS total_txns,
  SUM(CASE WHEN txn_success = 1 OR txn_success = 'True' OR txn_success = 'true' THEN 1 ELSE 0 END) AS success_count,
  ROUND(100.0 * SUM(CASE WHEN txn_success = 1 OR txn_success = 'True' OR txn_success = 'true' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),1),2) AS success_pct
FROM upi_transactions
GROUP BY bank_name
ORDER BY total_txns DESC;
