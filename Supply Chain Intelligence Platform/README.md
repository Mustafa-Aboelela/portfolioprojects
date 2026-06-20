# Supply Chain Intelligence Platform

A Kimball-style dimensional data warehouse built on **Snowflake** using **dbt**, transforming raw transportation/logistics data into an analytics-ready star schema. This project simulates a trucking/freight operation, modeling trips, deliveries, fuel purchases, maintenance, and safety incidents into a fully tested, documented data warehouse.

---

## Project Overview

The dataset represents a mid-size trucking company's operations: customers, drivers, trucks, trailers, facilities, routes, and the transactions that connect them (loads, trips, fuel purchases, deliveries, maintenance, safety incidents).

This project takes that raw data through a complete **ELT pipeline**:

```
Raw CSV data → Snowflake (RAW schema) → dbt staging (views) → dbt marts (dimensions + facts) → Analytics-ready star schema
```

**Scale:** 14 source tables, ~550,000+ total rows, 28 dbt models, 135 automated data tests.

---

## Architecture

### Layered design

| Layer | Schema | Materialization | Purpose |
|---|---|---|---|
| Raw | `RAW` | Source tables | Untouched landing zone for source CSV data |
| Staging | `ANALYTICS` | View | 1:1 with raw tables — renamed, typed, lightly cleaned |
| Marts | `ANALYTICS` | Table | Dimensional model — star schema for analysis |
| Snapshots | `SNAPSHOTS` | Table (append-only) | SCD Type 2 history tracking |

Role-based access control (`TRANSFORM` role) enforces read-only access to `RAW` and full build access to `ANALYTICS`/`SNAPSHOTS`, keeping the raw landing zone protected from accidental writes.

### Star schema

**7 Dimensions**
- `dim_customer` — customer accounts, revenue tier classification
- `dim_driver` — driver profiles **(SCD Type 2)**
- `dim_truck` — fleet truck assets **(SCD Type 2)**
- `dim_trailer` — fleet trailer assets
- `dim_facility` — warehouses / distribution centers
- `dim_route` — origin-destination lanes with haul type classification
- `dim_date` — calendar dimension (2022–2027), generated via `dbt_utils.date_spine`

**5 Transaction Fact Tables**
- `fct_trip` — core fact table: revenue, fuel cost, distance, margin per trip
- `fct_delivery` — pickup/delivery events with on-time performance and detention tracking
- `fct_fuel_purchase` — fuel transactions by truck/driver/location
- `fct_maintenance` — maintenance work orders, cost, and downtime
- `fct_safety_incident` — safety incidents with fault, injury, and financial impact

**2 Periodic Snapshot Facts**
- `agg_truck_utilization_metrics` — monthly truck-level utilization, revenue, and maintenance KPIs
- `agg_driver_monthly_metrics` — monthly driver-level trip, mileage, and on-time performance KPIs

---

## Key Features

### Slowly Changing Dimensions (SCD Type 2)
`dim_driver` and `dim_truck` track historical changes via **dbt snapshots** (`check` strategy), preserving point-in-time accuracy. A driver's `home_terminal` or a truck's `status` changing doesn't overwrite history — a new versioned row is added with `valid_from` / `valid_to` / `is_current` columns, so historical fact joins remain accurate.

### Surrogate Keys
Every dimension and fact table uses `dbt_utils.generate_surrogate_key()` to generate stable, warehouse-controlled keys, decoupled from natural/business keys — a core Kimball modeling requirement that also enables the SCD Type 2 pattern above.

### Data Quality Testing
135 automated tests across the pipeline:
- **Uniqueness & not-null** on all primary/surrogate keys
- **Referential integrity** (`relationships` tests) across every foreign key
- **Accepted values** on derived categorical columns (e.g. `haul_type`, `revenue_tier`)
- **Severity-tiered testing** — known upstream data gaps (e.g. ~2% of completed trips missing a truck assignment) are downgraded to `warn` rather than `error`, so they're monitored without blocking the pipeline. This reflects a deliberate decision after investigating root cause, not a workaround.

**Result: 128 PASS / 7 WARN / 0 ERROR** across the full test suite.

### Grain Enforcement
Many-to-one relationships (e.g. multiple fuel purchases per trip) are aggregated to the correct grain *before* joining into fact tables, preventing fan-out and double-counted metrics.

### Documentation & Lineage
Full column-level descriptions and a browsable lineage DAG generated via `dbt docs`, tracing every analytical column back to its raw source.

---

## Tech Stack

- **Warehouse:** Snowflake
- **Transformation:** dbt (Core, v1.11)
- **Package:** dbt-labs/dbt_utils (v1.3.0)
- **Language:** SQL, Jinja
- **Version Control:** Git / GitHub

---

## Project Structure

```
supply_chain_dbt/
└── supplychain/
    ├── models/
    │   ├── staging/              # 14 staging views + sources.yml + tests
    │   └── marts/
    │       ├── dimensions/       # 7 dimension tables
    │       ├── facts/            # 5 transaction fact tables
    │       └── aggregates/       # 2 periodic snapshot fact tables
    ├── snapshots/                 # SCD Type 2 snapshots (driver, truck)
    ├── packages.yml               # dbt_utils dependency
    └── dbt_project.yml
```

---

## How to Run

1. **Load raw data** into Snowflake under `SUPPLY_CHAIN_DWH.RAW` (14 CSVs in `/dataset`)
2. **Install dependencies**
   ```bash
   dbt deps
   ```
3. **Build the full pipeline**
   ```bash
   dbt run
   ```
4. **Run data quality tests**
   ```bash
   dbt test
   ```
5. **Track SCD history** (driver/truck dimensions)
   ```bash
   dbt snapshot
   ```
6. **Generate documentation**
   ```bash
   dbt docs generate
   dbt docs serve
   ```

---

## Example Analysis Enabled

- Revenue, gross margin, and cost-per-mile by route, customer, or time period
- On-time delivery rate and detention analysis by facility or customer
- Fleet utilization and downtime trends by truck, month over month
- Driver safety performance — at-fault rate, preventable incident rate
- Historically accurate reporting even after a driver/truck's attributes change (via SCD Type 2)

---

## Data Quality Notes

During testing, ~1,600–4,000 rows across `fct_trip` and `fct_fuel_purchase` were found to have missing truck/driver assignments despite being marked "Completed." Investigation confirmed these were genuine completed trips (with real distances, drivers, and trailers) — an upstream data entry gap rather than a loading error. These were documented and downgraded to `warn`-level tests rather than silently dropped or hidden, reflecting a deliberate, investigated decision.

---

## Author

Mustafa Mohamed — [LinkedIn](https://www.linkedin.com/in/mustafa-aboelela-b4b535252/) | [GitHub](https://github.com/Mustafa-Aboelela) | [Portfolio](https://mustafa-aboelela.github.io/mywebsite/)
