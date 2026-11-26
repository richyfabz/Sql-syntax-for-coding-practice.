# SQL Coding Practice for Data Engineering

## Overview

This repository documents my hands-on SQL practice focused on real-world data engineering and analytics engineering tasks. It explores techniques for extracting, transforming, cleaning, validating and analyzing data, as well as optimizing database queries and supporting reliable ETL/ELT pipelines.

The exercises use practical business scenarios, including financial transactions, customer records, incremental data ingestion and data quality management.

## Learning Objectives

- Develop proficiency in intermediate and advanced SQL.
- Write efficient, readable and maintainable queries.
- Perform data cleaning, deduplication and transformation.
- Implement incremental data extraction and loading strategies.
- Understand database indexing and query performance optimization.
- Apply SQL to real-world data engineering and analytical problems.
- Prepare for technical interviews and SQL coding assessments.

## Topics Covered

| Topic | Description |
| --- | --- |
| Advanced SELECT Queries | Filtering, sorting, aggregation, conditional expressions and complex data retrieval. |
| SQL Functions | Built-in functions for manipulating strings, dates, numeric values and NULL values. |
| Joins | Combining datasets, identifying unmatched records and supporting data reconciliation. |
| Subqueries | Nested and correlated queries for filtering and complex business logic. |
| Common Table Expressions (CTEs) | Breaking complex transformations into readable, reusable query stages. |
| Window Functions | Ranking, deduplication, running totals, LAG, LEAD and period-over-period analysis. |
| Views | Creating reusable query definitions for reporting and data access. |
| Stored Procedures | Encapsulating database operations and reusable processing logic. |
| Temporary Tables | Managing intermediate datasets during multi-step transformations. |
| Pivot and Unpivot | Reshaping datasets between wide and long formats for reporting and analysis. |
| Indexing | Single-column, composite, unique, partial and covering indexes; query optimization and execution plans. |

## Repository Structure

```text
Sql coding practice/
├── Advance_SELECT_Queries.ipynb
├── CTE's.ipynb
├── function.ipynb
├── Indeximg.ipynb
├── Joins.ipynb
├── Pivot_and_unpivot.ipynb
├── Stored_procedure.ipynb
├── Subqueries.ipynb
├── Temp_table.ipynb
├── Views.ipynb
├── WindowFunctions.ipynb
└── README.md
```

## Practical Data Engineering Use Cases

### Data Cleaning and Quality Validation

- Identify duplicate records and retain the latest valid version using `ROW_NUMBER()`.
- Handle missing values and inconsistent data.
- Detect unmatched records through joins and reconcile datasets.
- Prevent duplicate records in curated tables using unique constraints or indexes.

### Incremental Data Ingestion

Extract newly created or updated records using timestamp-based watermarks rather than repeatedly extracting entire source tables.

```sql
SELECT *
FROM transactions
WHERE updated_at > TIMESTAMP '2026-11-26 10:00:00'
  AND updated_at <= TIMESTAMP '2026-11-26 11:00:00';
```

An appropriate index can improve selective incremental extraction:

```sql
CREATE INDEX idx_transactions_updated_at
ON transactions (updated_at);
```

### Data Transformation and Business Analytics

- Aggregate transaction volumes, revenue and customer activity.
- Calculate month-over-month revenue growth using `LAG()`.
- Rank records and calculate running totals using window functions.
- Reshape datasets for dashboards and downstream analytical workloads.
- Organize multi-step transformations using CTEs and temporary tables.

### Query Performance Optimization

- Create indexes based on filtering, joining and sorting requirements.
- Understand composite index column ordering and index selectivity.
- Compare sequential scans and index scans using execution plans.
- Evaluate the trade-off between query performance, storage and ingestion throughput.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM transactions
WHERE customer_id = 201;
```

## Tools and Technologies

- **SQL** — data querying, transformation and optimization.
- **PostgreSQL** — primary relational database dialect for practice.
- **Visual Studio Code** — development environment.
- **Jupyter Notebooks** — organizing SQL examples, explanations and exercises.
- **Git and GitHub** — version control and portfolio documentation.

## Data Warehouse Relevance

The SQL concepts explored in this repository are applicable to modern data platforms such as BigQuery, Snowflake, Amazon Redshift, Azure Synapse Analytics and Databricks SQL. Syntax, procedural features and performance optimization mechanisms vary across platforms. For example, traditional PostgreSQL indexing differs from warehouse partitioning, clustering and data skipping.

## Getting Started

1. Clone or download this repository.
2. Open the project in Visual Studio Code.
3. Install the Jupyter extension and configure a compatible SQL execution extension or kernel.
4. Connect to a PostgreSQL practice database.
5. Create the required sample tables and datasets for each exercise.
6. Open the relevant notebook and execute the SQL examples in order.

Use a non-production database when experimenting with schema changes, indexes and data modification statements.

## Learning Approach

Each topic is intended to combine conceptual understanding, SQL syntax, practical examples, business scenarios and performance considerations. The focus is on understanding why a solution works, not simply memorizing SQL commands.

## Project Status

**In progress** — this repository is continuously updated as I expand my SQL knowledge and practice more advanced data engineering scenarios.
