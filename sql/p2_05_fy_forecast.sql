-- ============================================================
-- Query 5: Full Year Forecast vs Budget — Executive Summary
-- Skills: CTE, conditional aggregation, ROW_NUMBER,
--         full-year outlook combining actuals + forecast
-- Used in: Power BI Page 1 (Executive KPI cards)
-- ============================================================

WITH full_year AS (
    SELECT
        f.product_id,
        f.metric_id,

        -- Full year budget
        SUM(f.budget_value) AS fy_budget,

        -- YTD actual (months 1-9 = actuals completed)
        SUM(CASE WHEN m.month_id <= 9
                 THEN f.actual_value ELSE 0 END) AS ytd_actual,

        -- Remaining forecast (months 10-12)
        SUM(CASE WHEN m.month_id > 9
                 THEN f.forecast_value ELSE 0 END) AS remaining_forecast,

        -- Full year outlook = YTD actual + remaining forecast
        SUM(CASE WHEN m.month_id <= 9
                 THEN f.actual_value
                 ELSE f.forecast_value END) AS fy_outlook,

        -- Prior year full year
        SUM(f.prior_year_value) AS fy_prior_year

    FROM fact_fpa f
    JOIN dim_month m ON f.month_id = m.month_id
    GROUP BY f.product_id, f.metric_id
)
SELECT
    p.product_name,
    p.division,
    p.cost_centre,
    mt.metric_name,
    mt.metric_type,
    mt.unit,
    mt.higher_is_better,

    ROUND(fy.fy_budget, 1)           AS full_year_budget,
    ROUND(fy.ytd_actual, 1)          AS ytd_actual,
    ROUND(fy.remaining_forecast, 1)  AS remaining_forecast,
    ROUND(fy.fy_outlook, 1)          AS full_year_outlook,
    ROUND(fy.fy_prior_year, 1)       AS prior_year,

    -- Outlook vs Budget
    ROUND(fy.fy_outlook - fy.fy_budget, 1)
        AS vs_budget_abs,
    ROUND((fy.fy_outlook - fy.fy_budget)
        / fy.fy_budget * 100, 1)
        AS vs_budget_pct,

    -- Outlook vs Prior Year
    ROUND(fy.fy_outlook - fy.fy_prior_year, 1)
        AS vs_prior_year_abs,
    ROUND((fy.fy_outlook - fy.fy_prior_year)
        / fy.fy_prior_year * 100, 1)
        AS vs_prior_year_pct,

    -- Overall status
    CASE
        WHEN (fy.fy_outlook - fy.fy_budget)
             / fy.fy_budget >=  0.03 THEN 'Tracking above budget'
        WHEN (fy.fy_outlook - fy.fy_budget)
             / fy.fy_budget >=  0    THEN 'On track'
        WHEN (fy.fy_outlook - fy.fy_budget)
             / fy.fy_budget >= -0.03 THEN 'Slight risk'
        ELSE 'At risk'
    END AS fy_outlook_status

FROM full_year fy
JOIN dim_product p  ON fy.product_id = p.product_id
JOIN dim_metric  mt ON fy.metric_id  = mt.metric_id

ORDER BY p.product_name, mt.metric_name;
