-- Build a funnel summary table (counts + stage-to-stage conversion %)
-- This outputs one row per bank (also includes a global row if you use bank_name = 'ALL').

-- 1. Helper CTE: stage_flags per transaction (one row per txn with flags for reached stages)
WITH stage_flags AS (
  SELECT
    e.txn_id,
    MAX(CASE WHEN e.stage = 'init' THEN 1 ELSE 0 END) AS reached_init,
    MAX(CASE WHEN e.stage = 'amount_entered' THEN 1 ELSE 0 END) AS reached_amount,
    MAX(CASE WHEN e.stage = 'pin_entered' THEN 1 ELSE 0 END) AS reached_pin,
    MAX(CASE WHEN e.stage = 'bank_auth' THEN 1 ELSE 0 END) AS reached_bankauth,
    MAX(CASE WHEN e.stage = 'completed' THEN 1 ELSE 0 END) AS reached_completed
  FROM upi_txn_events e
  GROUP BY e.txn_id
)

-- 2. Join with transactions to get bank/device, then aggregate by bank
SELECT
  COALESCE(t.bank_name, 'UNKNOWN') AS bank_name,
  SUM(sf.reached_init) AS init_count,
  SUM(sf.reached_amount) AS amount_count,
  SUM(sf.reached_pin) AS pin_count,
  SUM(sf.reached_bankauth) AS bankauth_count,
  SUM(sf.reached_completed) AS completed_count,
  -- conversion percentages (guarding against division by zero)
  ROUND(100.0 * SUM(sf.reached_amount) / NULLIF(SUM(sf.reached_init),0),2) AS pct_amount_of_init,
  ROUND(100.0 * SUM(sf.reached_pin) / NULLIF(SUM(sf.reached_amount),0),2) AS pct_pin_of_amount,
  ROUND(100.0 * SUM(sf.reached_bankauth) / NULLIF(SUM(sf.reached_pin),0),2) AS pct_bankauth_of_pin,
  ROUND(100.0 * SUM(sf.reached_completed) / NULLIF(SUM(sf.reached_bankauth),0),2) AS pct_completed_of_bankauth,
  ROUND(100.0 * SUM(sf.reached_completed) / NULLIF(SUM(sf.reached_init),0),2) AS pct_completed_of_init
FROM stage_flags sf
LEFT JOIN upi_transactions t ON sf.txn_id = t.txn_id
GROUP BY COALESCE(t.bank_name, 'UNKNOWN')
ORDER BY init_count DESC;
