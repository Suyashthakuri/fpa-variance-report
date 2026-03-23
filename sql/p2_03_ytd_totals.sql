-- ============================================================
-- Query 3: Running Year-to-Date Totals
-- Skills: Window functions (SUM OVER with ROWS frame),
--         cumulative tracking, forecast vs budget YTD
-- Used in: Power BI Page 3 (YTD Performance)
-- ============================================================

SELECT
    m.month_id,
    m.month_short,
    m.month_name,
    m.quarter,
    p.product_name,
    mt.metric_name,

    f.budget_value      AS monthly_budget,
    f.actual_value      AS monthly_actual,

    -- Running YTD budget cumulative total
    SUM(f.budget_value) OVER (
        PARTITION BY f.product_id, f.metric_id
        ORDER BY m.month_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_budget,

    -- Running YTD actual cumulative total
    SUM(f.actual_value) OVER (
        PARTITION BY f.product_id, f.metric_id
        ORDER BY m.month_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_actual,

    -- YTD variance
    ROUND(
        SUM(f.actual_value) OVER (
            PARTITION BY f.product_id, f.metric_id
            ORDER BY m.month_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
        -
        SUM(f.budget_value) OVER (
            PARTITION BY f.product_id, f.metric_id
            ORDER BY m.month_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 1
    ) AS ytd_variance,

    -- YTD variance percentage
    ROUND(
        (SUM(f.actual_value) OVER (
            PARTITION BY f.product_id, f.metric_id
            ORDER BY m.month_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
        -
        SUM(f.budget_value) OVER (
            PARTITION BY f.product_id, f.metric_id
            ORDER BY m.month_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ))
        /
        SUM(f.budget_value) OVER (
            PARTITION BY f.product_id, f.metric_id
            ORDER BY m.month_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100, 1
    ) AS ytd_variance_pct

FROM fact_fpa f
JOIN dim_month   m  ON f.month_id   = m.month_id
JOIN dim_product p  ON f.product_id = p.product_id
JOIN dim_metric  mt ON f.metric_id  = mt.metric_id

WHERE mt.metric_name IN ('Revenue', 'EBITDA', 'Gross Profit')

ORDER BY p.product_name, mt.metric_name, m.month_id;
