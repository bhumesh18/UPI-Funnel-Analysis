-- Basic exploration queries to understand your tables and columns.

-- 1. Show row counts for both tables
SELECT 'events' AS table_name, COUNT(*) AS rows FROM upi_txn_events
UNION ALL
SELECT 'transactions', COUNT(*) FROM upi_transactions;

-- 2. Show distinct stages present in events (helps confirm stage names)
SELECT DISTINCT stage FROM upi_txn_events ORDER BY stage;

-- 3. Peek at top 10 rows from events and transactions
SELECT * FROM upi_txn_events LIMIT 10;
SELECT * FROM upi_transactions LIMIT 10; 