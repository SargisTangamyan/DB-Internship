SET enable_indexscan = off;
SET enable_bitmapscan = off;
EXPLAIN ANALYZE SELECT * FROM transactions WHERE from_account_id = 896;
RESET enable_bitmapscan;
RESET enable_indexscan;

-- Number of rows in transactions

-- Execution Times
-- Index - 0.044 ms
-- Bitmap - 0.115 ms
-- Seq - 1.229 ms

SELECT count(*) FROM transactions;


insert into transactions (amount,type,created_at,description,from_account_id,to_account_id,metadata)
select amount,type,created_at,description,from_account_id,to_account_id,metadata
       from transactions;

create index idx_transactions_from_account_id_created_at on transactions(from_account_id,created_at);
explain(analyze,verbose)
select * from transactions where from_account_id=12 and created_at between '2025-11-01' and '2025-11-30';


explain(analyze,verbose)
select * from transactions where  created_at between '2025-11-01' and '2025-11-30'and from_account_id=12 ;