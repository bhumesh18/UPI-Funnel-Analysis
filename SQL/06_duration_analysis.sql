-- Compute per-transaction duration from init -> completed and aggregate by bank/device.
-- Two variants: Postgres (recommended) and SQLite variant.

-- === Postgres version ===
WITH stage_times AS (
  SELECT
    txn_id,
    MIN(CASE WHEN stage = 'init' THEN event_time END) AS t_init,
    MIN(CASE WHEN stage = 'completed' THEN event_time END) AS t_completed
  FROM upi_txn_events
  GROUP BY txn_id
)
SELECT
  t.bank_name,
  AVG(EXTRACT(EPOCH FROM (st.t_completed - st.t_init))) AS avg_duration_sec,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (st.t_completed - st.t_init))) AS median_duration_sec,
  COUNT(*) AS num_txns_with_both
FROM stage_times st
JOIN upi_transactions t ON st.txn_id = t.txn_id
WHERE st.t_init IS NOT NULL AND st.t_completed IS NOT NULL
GROUP BY t.bank_name
ORDER BY avg_duration_sec DESC;

-- === SQLite version ===
-- SQLite stores times as text; use julianday to get difference in days -> convert to seconds
WITH stage_times AS (
  SELECT
    txn_id,
    MIN(CASE WHEN stage = 'init' THEN event_time END) AS t_init,
    MIN(CASE WHEN stage = 'completed' THEN event_time END) AS t_completed
  FROM upi_txn_events
  GROUP BY txn_id
)
SELECT
  t.bank_name,
  AVG( (julianday(st.t_completed) - julianday(st.t_init)) * 24.0 * 3600.0 ) AS avg_duration_sec,
  -- approximate median using percentile (SQLite lacks percentile function; you may compute with custom query or use Python)
  COUNT(*) AS num_txns_with_both
FROM stage_times st
JOIN upi_transactions t ON st.txn_id = t.txn_id
WHERE st.t_init IS NOT NULL AND st.t_completed IS NOT NULL
GROUP BY t.bank_name
ORDER BY avg_duration_sec DESC;
