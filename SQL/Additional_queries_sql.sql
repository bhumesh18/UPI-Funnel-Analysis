
-- 1. Top 3 banks by transaction volume in last 30 days (assuming event_time is usable)
WITH recent_txns AS (
  SELECT DISTINCT txn_id
  FROM upi_txn_events
  WHERE event_time >= datetime('now','-60 days')  -- SQLite syntax; for Postgres use CURRENT_TIMESTAMP - INTERVAL '30 days'
)
SELECT
  t.bank_name,
  COUNT(*) AS txn_volume
FROM upi_transactions t
JOIN recent_txns r ON t.txn_id = r.txn_id
GROUP BY t.bank_name
ORDER BY txn_volume DESC
LIMIT 3;

-- 2. Bank with highest failure percentage
WITH bank_stats AS (
  SELECT
    bank_name,
    COUNT(*) AS total_txns,
    SUM(CASE WHEN txn_success = 0 OR txn_success = 'False' OR txn_success = 'false' THEN 1 ELSE 0 END) AS failures
  FROM upi_transactions
  GROUP BY bank_name
)
SELECT
  bank_name,
  failures,
  total_txns,
  ROUND(100.0 * failures / NULLIF(total_txns,0),2) AS failure_pct
FROM bank_stats
ORDER BY failure_pct DESC
LIMIT 1;

-- 3. For each device type, compute average number of stages reached per txn (a simple "engagement depth" metric)
WITH stage_flags AS (
  SELECT
    e.txn_id,
    MAX(CASE WHEN e.stage = 'init' THEN 1 ELSE 0 END) +
    MAX(CASE WHEN e.stage = 'amount_entered' THEN 1 ELSE 0 END) +
    MAX(CASE WHEN e.stage = 'pin_entered' THEN 1 ELSE 0 END) +
    MAX(CASE WHEN e.stage = 'bank_auth' THEN 1 ELSE 0 END) +
    MAX(CASE WHEN e.stage = 'completed' THEN 1 ELSE 0 END) AS stages_reached
  FROM upi_txn_events e
  GROUP BY e.txn_id
)
SELECT
  t.device_type,
  AVG(sf.stages_reached) AS avg_stages_reached
FROM stage_flags sf
JOIN upi_transactions t ON sf.txn_id = t.txn_id
GROUP BY t.device_type;
