-- ============================================================
-- Query 1: Monthly Budget vs Actual Variance by Product Line
-- Skills: JOINs, CASE WHEN, calculated columns, variance analysis
-- Used in: Power BI Page 1 (Management Summary) and Page 2 (Variance Detail)
-- ============================================================

SELECT
    m.month_short,
    m.month_name,
    m.quarter,
    m.fy_year,
    p.product_name,
    p.division,
    mt.metric_name,
    mt.metric_type,
    mt.unit,

    f.budget_value,
    f.actual_value,
    f.forecast_value,

    -- Absolute variance (positive = better than budget for revenue/profit)
    ROUND(f.actual_value - f.budget_value, 1) AS variance_abs,

    -- Percentage variance
    ROUND(
        (f.actual_value - f.budget_value)
        / f.budget_value * 100, 2
    ) AS variance_pct,

    -- Traffic light status accounting for direction (higher/lower is better)
    CASE
        WHEN mt.higher_is_better = 1 THEN
            CASE
                WHEN (f.actual_value - f.budget_value)
                     / f.budget_value >=  0.05 THEN 'Above target'
                WHEN (f.actual_value - f.budget_value)
                     / f.budget_value >=  0    THEN 'On target'
                WHEN (f.actual_value - f.budget_value)
                     / f.budget_value >= -0.05 THEN 'Within 5%'
                ELSE 'Below target'
            END
        ELSE
            CASE
                WHEN (f.budget_value - f.actual_value)
                     / f.budget_value >=  0.05 THEN 'Above target'
                WHEN (f.budget_value - f.actual_value)
                     / f.budget_value >=  0    THEN 'On target'
                WHEN (f.budget_value - f.actual_value)
                     / f.budget_value >= -0.05 THEN 'Within 5%'
                ELSE 'Below target'
            END
    END AS kpi_status

FROM fact_fpa f
JOIN dim_month   m  ON f.month_id   = m.month_id
JOIN dim_product p  ON f.product_id = p.product_id
JOIN dim_metric  mt ON f.metric_id  = mt.metric_id

WHERE mt.metric_name = 'Revenue'

ORDER BY m.month_id, p.product_name;
