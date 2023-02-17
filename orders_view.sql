-- Удаление view со старой логикой
DROP VIEW IF EXISTS analysis.orders;

-- Создание view с новой логикой
CREATE OR REPLACE VIEW analysis.orders AS
WITH order_sequence_cte AS (
    SELECT
        order_id,
        status_id,
        dttm,
        row_number() over (
            PARTITION by order_id
            ORDER BY
                dttm :: timestamp DESC
        ) AS sequence_orders
    FROM
        production.orderstatuslog
),

last_order_status_cte AS (
    SELECT
        order_id,
        status_id
    FROM
        order_sequence_cte
    WHERE
        sequence_orders = 1
)

SELECT
    order_id,
    order_ts,
    user_id,
    bonus_payment,
    payment,
    cost,
    bonus_grant,
    status_id AS "status"
FROM
    last_order_status_cte
    LEFT JOIN production.orders o USING(order_id);