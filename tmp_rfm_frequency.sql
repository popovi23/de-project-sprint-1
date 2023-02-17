WITH frequency_cte AS (
    SELECT
        u.id AS user_id,
        NTILE (5) OVER (ORDER BY count(o.order_id) NULLS FIRST) AS frequency
    FROM
        analysis.users AS u
        LEFT JOIN analysis.orders AS o ON u.id = o.user_id
        AND o.status = 4
        AND EXTRACT (YEAR FROM o.order_ts) >= 2022
    GROUP BY
        u.id
)
INSERT INTO
    analysis.tmp_rfm_frequency (user_id, frequency)
SELECT
    user_id,
    frequency
FROM
    frequency_cte;