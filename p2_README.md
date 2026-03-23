# FP&A Budget vs Actual Variance Report
### 12-month management reporting model for a Financial Services business unit — Excel, SQL, Power BI, DAX

---

## What this project demonstrates

This project replicates the core FP&A workflow in financial services — building a 12-month budget vs. actual variance report, tracking YTD performance, forecasting full-year outlook, and delivering a management-ready report for non-technical stakeholders.

**Skills demonstrated:**
- FP&A modelling: budget vs. actual, variance analysis, YTD tracking, full-year forecasting
- Star schema data modelling (fact table + 3 dimension tables)
- SQL: JOINs, CTEs, window functions (SUM OVER, RANK), conditional aggregation
- DAX: variance measures, YTD calculations, KPI status logic, EBITDA margin
- Power BI: management report design, drill-through, conditional formatting
- Financial services domain: P&L structure, EBITDA, NPS, headcount tracking

---

## Business context

A financial services business unit (6 product lines) needs a monthly management report showing:
- How each product line is tracking against budget
- YTD performance and full-year forecast outlook
- Key variance drivers at product and metric level
- Executive summary for CFO/board presentation

This dashboard replaces manual Excel consolidation with an automated, drill-through management report.

---

## Business unit — 6 product lines

| Product | Division | Revenue Type |
|---|---|---|
| Retail Banking | Consumer | Net Interest Income |
| Business Banking | Commercial | Net Interest Income |
| Wealth Management | Consumer | Fee Income |
| Insurance | Consumer | Premium Income |
| Markets | Institutional | Trading Income |
| Operations | Support | Internal Charges |

**Data: 12 months × 6 products × 7 metrics = 504 data points**

---

## Metrics tracked

| Metric | Type | Direction |
|---|---|---|
| Revenue | P&L | Higher is better |
| Direct Costs | P&L | Lower is better |
| Gross Profit | P&L | Higher is better |
| Operating Expenses | P&L | Lower is better |
| EBITDA | P&L | Higher is better |
| Headcount | Non-Financial | Lower vs budget = efficient |
| NPS Score | Non-Financial | Higher is better |

---

## Data model — star schema

```
        dim_month
             |
             | (many-to-one)
             |
fact_fpa ——————— dim_product
             |
             | (many-to-one)
             |
        dim_metric
```

---

## SQL queries

| File | What it does | SQL skills |
|---|---|---|
| 01_monthly_variance.sql | Monthly budget vs actual with traffic-light status | JOINs, CASE WHEN, variance calc |
| 02_quarterly_rollup.sql | Quarterly P&L aggregation vs budget and prior year | CTE, GROUP BY, multi-metric comparison |
| 03_ytd_totals.sql | Running YTD cumulative totals | SUM OVER with UNBOUNDED PRECEDING frame |
| 04_profitability_ranking.sql | EBITDA margin and product ranking | CTE, RANK(), self-join for margin |
| 05_fy_forecast.sql | Full year outlook = actuals + forecast | CTE, conditional aggregation, status flags |

---

## DAX measures

| Category | Measures |
|---|---|
| Base | Total Budget, Total Actual, Total Forecast, Prior Year Total |
| Variance | Variance $, Variance %, Variance % Label |
| YTD | YTD Actual, YTD Budget, YTD Variance $, YTD Variance % |
| Prior Year | vs Prior Year $, vs Prior Year %, vs Prior Year Label |
| Specific KPIs | Total Revenue, Total EBITDA, EBITDA Margin %, NPS Score, Headcount |
| Status | KPI Status, KPI Colour, Full Year Outlook |

---

## Dashboard pages

**Page 1 — Management Summary**
5 KPI cards: Revenue, EBITDA, EBITDA Margin %, Headcount, NPS. Each card shows actual value + variance vs budget label. Traffic-light conditional formatting. Month and product slicers. Written executive commentary text box.

**Page 2 — Monthly Variance Detail**
Matrix table: products as rows, months as columns, Variance % as values — conditional formatting green/red. Clustered bar chart: actual vs budget by month. Waterfall chart showing cumulative variance build.

**Page 3 — YTD Performance**
Line chart: YTD Actual vs YTD Budget accumulating over 12 months. Full Year Outlook card vs full year budget. Scatter plot: EBITDA Margin % vs Revenue by product — shows which products are most efficient.

**Page 4 — Product Deep-Dive** (drill-through)
All 7 metrics for selected product: actual, budget, variance %, prior year, YoY change. Sparkline trends. Bookmark toggle: Monthly view vs Quarterly view.

---

## Repository structure

```
fpa-variance-report/
├── README.md
├── data/
│   └── fpa_dataset.xlsx
├── sql/
│   ├── 01_monthly_variance.sql
│   ├── 02_quarterly_rollup.sql
│   ├── 03_ytd_totals.sql
│   ├── 04_profitability_ranking.sql
│   ├── 05_fy_forecast.sql
│   └── DAX_measures.txt
├── powerbi/
│   └── FPA_Variance_Report.pbix
└── screenshots/
    ├── 01_management_summary.png
    ├── 02_variance_detail.png
    ├── 03_ytd_performance.png
    └── 04_product_deepdive.png
```

---

## Tools used

- Microsoft Excel — FP&A dataset and star schema
- SQLite + DB Browser — SQL query development
- Power BI Desktop — data model, DAX, dashboard
- DAX — variance, YTD, KPI measures

---

*Built as part of a reporting analytics portfolio targeting Financial Analyst and BI Analyst roles in Sydney, Australia.*
