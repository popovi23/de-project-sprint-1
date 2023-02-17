truncate analysis.dm_rfm_segments; 

INSERT INTO analysis.dm_rfm_segments(user_id,recency,frequency,monetary_value)
SELECT u.id AS "user_id",
         r.recency,
         f.frequency,
         m.monetary_value
FROM analysis.tmp_rfm_frequency f, analysis.tmp_rfm_recency r, analysis.tmp_rfm_monetary_value m, analysis.users u
WHERE u.id = r.user_id
        AND u.id=m.user_id
        AND u.id=f.user_id

-- user_id recency frequency monetary_value
--    0		  1			3			4
--    1		  4			3			3
--    2		  2			3			5
--    3		  2			3			3
--    4		  4			3			3
--    5		  5			5			5
--    6		  1			3			5
--    7		  4			2			2
--    8		  1			2			3
--    9		  1			3			2
--    10	  3			5			2
