WITH recency_cte AS (
    SELECT
        u.id AS user_id,
        NTILE (5) OVER (ORDER BY max(o.order_ts) NULLS FIRST) AS recency
    FROM
        analysis.users AS u
        LEFT JOIN analysis.orders AS o ON u.id = o.user_id
        AND o.status = 4
        AND EXTRACT (YEAR FROM o.order_ts) >= 2022
    GROUP BY
        u.id
)
INSERT INTO
    analysis.tmp_rfm_recency (user_id, recency)
SELECT
    user_id,
    recency
FROM
    recency_cte;