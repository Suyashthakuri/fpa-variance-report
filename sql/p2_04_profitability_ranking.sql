-- ============================================================
-- Query 4: Product Line Profitability Ranking & EBITDA Margin
-- Skills: CTEs, RANK() window function, self-join for margin calc
-- Used in: Power BI Page 3 (Profitability Analysis)
-- ============================================================

WITH revenue AS (
    SELECT
        f.month_id,
        f.product_id,
        SUM(f.actual_value) AS total_revenue
    FROM fact_fpa f
    JOIN dim_metric mt ON f.metric_id = mt.metric_id
    WHERE mt.metric_name = 'Revenue'
    GROUP BY f.month_id, f.product_id
),
ebitda AS (
    SELECT
        f.month_id,
        f.product_id,
        SUM(f.actual_value) AS total_ebitda
    FROM fact_fpa f
    JOIN dim_metric mt ON f.metric_id = mt.metric_id
    WHERE mt.metric_name = 'EBITDA'
    GROUP BY f.month_id, f.product_id
),
combined AS (
    SELECT
        r.month_id,
        r.product_id,
        r.total_revenue,
        e.total_ebitda,
        ROUND(e.total_ebitda / r.total_revenue * 100, 1) AS ebitda_margin_pct
    FROM revenue r
    JOIN ebitda e ON r.month_id = e.month_id
                  AND r.product_id = e.product_id
)
SELECT
    m.month_short,
    m.quarter,
    p.product_name,
    p.division,
    ROUND(c.total_revenue, 1)      AS revenue,
    ROUND(c.total_ebitda, 1)       AS ebitda,
    c.ebitda_margin_pct,

    -- Rank products by EBITDA margin each month
    RANK() OVER (
        PARTITION BY c.month_id
        ORDER BY c.ebitda_margin_pct DESC
    ) AS margin_rank,

    -- Rank by absolute EBITDA
    RANK() OVER (
        PARTITION BY c.month_id
        ORDER BY c.total_ebitda DESC
    ) AS ebitda_rank

FROM combined c
JOIN dim_month   m ON c.month_id   = m.month_id
JOIN dim_product p ON c.product_id = p.product_id

ORDER BY m.month_id, margin_rank;
