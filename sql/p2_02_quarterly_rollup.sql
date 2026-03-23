-- ============================================================
-- Query 2: Quarterly P&L Rollup — Budget vs Actual vs Prior Year
-- Skills: GROUP BY aggregation, CTEs, multi-column comparison
-- Used in: Power BI Page 2 (Variance Detail — quarterly view)
-- ============================================================

WITH quarterly AS (
    SELECT
        m.quarter,
        m.fy_year,
        p.product_name,
        p.division,
        mt.metric_name,
        mt.metric_type,
        mt.higher_is_better,

        SUM(f.budget_value)       AS budget_total,
        SUM(f.actual_value)       AS actual_total,
        SUM(f.prior_year_value)   AS prior_year_total,
        SUM(f.forecast_value)     AS forecast_total

    FROM fact_fpa f
    JOIN dim_month   m  ON f.month_id   = m.month_id
    JOIN dim_product p  ON f.product_id = p.product_id
    JOIN dim_metric  mt ON f.metric_id  = mt.metric_id

    WHERE mt.is_financial = 1

    GROUP BY
        m.quarter,
        m.fy_year,
        p.product_name,
        p.division,
        mt.metric_name,
        mt.metric_type,
        mt.higher_is_better
)
SELECT
    quarter,
    fy_year,
    product_name,
    division,
    metric_name,
    metric_type,

    ROUND(budget_total, 1)      AS budget,
    ROUND(actual_total, 1)      AS actual,
    ROUND(prior_year_total, 1)  AS prior_year,
    ROUND(forecast_total, 1)    AS forecast,

    -- vs Budget
    ROUND(actual_total - budget_total, 1)
        AS vs_budget_abs,
    ROUND((actual_total - budget_total)
        / budget_total * 100, 1)
        AS vs_budget_pct,

    -- vs Prior Year
    ROUND(actual_total - prior_year_total, 1)
        AS vs_prior_year_abs,
    ROUND((actual_total - prior_year_total)
        / prior_year_total * 100, 1)
        AS vs_prior_year_pct

FROM quarterly
ORDER BY quarter, product_name, metric_name;
