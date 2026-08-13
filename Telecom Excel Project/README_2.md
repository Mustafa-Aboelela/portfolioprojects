# Telecom Analytics Dashboard — Excel (Power Query, Power Pivot & DAX)

An end-to-end BI project built entirely in Excel: 13 raw telecom data sources consolidated into a single star-schema data model, with 15+ DAX measures and an interactive, cross-filtering dashboard.

## Project Overview

This project analyzes 13 independent telecom datasets (customer demographics, subscriptions, usage, billing, churn, fraud, marketing, network performance, network infrastructure, customer experience, customer behavior/satisfaction, regulatory compliance, and sustainability — 30,000+ rows total) to answer core business questions around **revenue, churn, fraud risk, network health, and marketing ROI**.

**Dashboard 1 — "Growth & Risk Overview" (v1)** covers Revenue, Churn, Fraud, Network, and Marketing. A second dashboard covering Customer Experience & Compliance is in progress.

## Key Design Decision: Why Dim_Date Is the Only Hub

A common assumption in relational data modeling is that customer-level tables should join on `Customer_ID`. Investigation (cross-checked via Python, DAX, and INDEX/MATCH) showed **~99% of Customer_ID values do not overlap** across the source files — each file was generated independently and was never designed to be joined on that key.

Rather than forcing broken relationships or fabricating a fix, this project uses a **star schema with `Dim_Date` as the sole relationship hub** connecting all 13 tables. This is a deliberate, defensible architecture choice:
- Every table relates to `Dim_Date` on its `Date` column (verified — clean 1:1 date grain, no duplicates).
- Cross-domain analysis (e.g., "churn trend alongside network reliability trend") is achieved through shared time periods rather than a broken customer key.
- Category-level breakdowns (e.g., revenue by segment, churn by reason) use each fact table's **own** categorical columns rather than borrowed dimension columns from unrelated tables — avoiding a subtle but common Power Pivot trap where a Pivot silently shows a flat, incorrect total when no real relationship path exists.

## Data Model

- **13 tables** loaded via Power Query, added to the Power Pivot Data Model.
- **1 shared `Dim_Date` table** (built via `CALENDAR()`), related to all 13 tables — enabling a single slicer/timeline to filter every visual simultaneously.
- Known data-quality issue documented rather than hidden: `Dim_Customer` contains duplicate `Customer_ID`s (slowly-changing snapshot data), which is why Customer_ID was never used as a relationship key.

## Key DAX Measures (sample)

```DAX
Churn Rate :=
DIVIDE(
    [Churned Customers],
    CALCULATE(COUNTROWS(Fact_Churn), ALL(Fact_Churn[Reasons_for_Churn_Categorical]))
)

Revenue YoY % :=
DIVIDE([Total Revenue] - [Revenue Prior Year], [Revenue Prior Year])
```

15+ measures span Revenue, Churn, Fraud, Network, Marketing, Compliance, Sustainability, and Customer Experience domains, including time-intelligence (MTD, QTD, MoM%, YoY%).

## Dashboard Features

- 5 KPI cards (Total Revenue, Churn Rate, Total Customers, Avg ARPU, Fraud Rate)
- 5 cross-filtering PivotCharts (Churn Rate by Quarter, Revenue by Subscription Type, Marketing ROI by Channel, Network Reliability by Quarter, Fraud Flag Rate by Quarter)
- Shared Year/Quarter slicers + Date timeline, connected to every visual via Report Connections
- Documented key insight: **App Push consistently delivered the highest marketing ROI in 3 of 4 quarters**; churn was driven primarily by pricing and network quality complaints.

## Key Learnings

- Diagnosed a many-to-many relationship error back to duplicate keys in a slowly-changing dimension table.
- Caught and fixed a "silent flat-total" bug — a Pivot table that looked correct but was actually ignoring a broken relationship path.
- Fixed a DAX filter-context bug (`Churn Rate` returning 100% everywhere) using `CALCULATE` + `ALL()`.
- Practiced both DAX (Power Pivot) and classic worksheet formulas (INDEX/MATCH, IFERROR, nested IF, AVERAGEIFS/COUNTIFS) for environments without Power Pivot access.

## Tools

Excel (Power Query, Power Pivot, DAX), Python (data integrity validation for the Customer_ID overlap analysis)

## Status

Dashboard 1 (Growth & Risk Overview) complete. Dashboard 2 (Customer Experience & Compliance) and further polish (What-If analysis, VBA refresh macro) in progress.
