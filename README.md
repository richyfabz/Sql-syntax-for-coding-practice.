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

## Run the commented examples with sample data

All 11 notebooks now use **PostgreSQL 14 or later**. SQL Server `PIVOT`/`UNPIVOT`
examples have been replaced with PostgreSQL conditional aggregation and lateral
`VALUES`. Table names are shared across notebooks: `payment_transactions`,
`customers`, `payment_providers`, and `refunds`. Syntax errors and inconsistent
column names have been corrected. The previously empty `function.ipynb` now has
a text-cleaning example. The actual CTE filename is `CTE's..ipynb`.

### 1. Load the fixtures

Connect to a dedicated PostgreSQL practice database using your preferred SQL
client. Execute the entire [sample setup](sql/00_sample_data.sql). It creates
10 payments, 5 customers, 2 providers, 3 refunds, messy customer text, raw source
snapshots, incremental events, order records, and sales examples.

**Rerunning this file drops and recreates the `sql_practice` schema and everything
inside it.** This restores the original sample data and removes practice views,
procedures, and indexes. Other schemas are outside the reset.

With PostgreSQL's `psql` command-line client and an existing database:

```sh
psql -d sql_practice_db -v ON_ERROR_STOP=1 -f sql/00_sample_data.sql
psql -d sql_practice_db -f sql/01_verify_baseline.sql
```

Replace `sql_practice_db` with your database name; supply your usual connection
options such as `-h localhost -U postgres` if needed. These commands assume the
database already exists. The verification script raises an error if the baseline
counts, successful amount, refund calculation, or watermark selection is wrong.
It must run before changing payment statuses.

### 2. Execute the transformations

For a SQL editor or notebook SQL connection, run this first in **every new
connection**:

```sql
SET search_path TO sql_practice, public;
```

The notebooks contain SQL, so a Python kernel cannot execute their cells directly.
Use a PostgreSQL-capable SQL kernel/extension, or copy each code cell into your
connected SQL editor. Run cells from top to bottom. Temporary tables require the
same database session for their creation and later queries.

You can also execute exported scripts with `psql`, avoiding notebook setup:

```sh
python3 scripts/export_sql.py
psql -d sql_practice_db -f sql/notebooks/Advance_SELECT_Queries.sql
psql -d sql_practice_db -f sql/notebooks/Temp_table.sql
psql -d sql_practice_db -f sql/notebooks/Views.sql
```

Every notebook has a matching script in `sql/notebooks/`. Regenerate them after
editing notebook code. Run the stored-procedure notebook last because it changes
payment 105 from Pending to Success. Reload the sample setup whenever you want
the original baseline. To repeat the temporary-table notebook, start from its
first cell so its working tables are recreated.

### 3. Compare your results with the baseline

These values apply immediately after loading the fixtures:

| Example | Expected result and reason |
| --- | --- |
| Provider success rates | Provider 1: 4 successes / 6 payments = 66.67%; provider 2: 3 / 4 = 75.00%. |
| Provider HAVING thresholds | Only provider 1 passes: 6 payments totaling 205,000. This example includes all statuses. |
| Successful amounts above 30,000 | Payments 101 and 102 (60,000 each), and 104 (40,000). Exactly 30,000 is excluded. |
| Successful customer segments | 201: Premium, 140,000; 203: Standard, 50,000; 202: Basic, 40,000; 204 and 205: Basic, 0. Customer 999 is unregistered and is excluded from the customer list. |
| Customer with no payments | Customer 205. Customer 204 has a failed payment, so does not qualify as having no payments. |
| RIGHT JOIN / missing customer | Payment 109 remains, but its customer name is NULL because customer 999 is unregistered. |
| Ranking ties for customer 201 | Payments 101 and 102 tie at 60,000. RANK gives 1, 1, 3; DENSE_RANK gives 1, 1, 2. ROW_NUMBER breaks the tie by transaction ID. |
| Latest payment for customer 201 | Payment 103, dated February 10. |
| Monthly successful volume | January: 120,000; February: 60,000; March: 55,000. Growth is NULL, -50.00%, then -8.33%. |
| Net payment 101 | 60,000 minus two refunds (5,000 + 2,000) = 53,000; still one payment row. |
| Clean customer 201 | ` ADA@EXAMPLE.COM ` becomes `ada@example.com`; ` ng ` becomes `NG`; surrounding name spaces disappear. |
| Blank customer 203 | Blank name, email and country become SQL NULL. Country cleaning standardizes case; it does not convert codes into country names. |
| Incremental temporary batch | Events 302 and 303, total 5,000. Event 301 equals the lower bound and is excluded; event 303 equals the upper bound and is included. |
| Sales pivot | Widget: Jan 150, Feb 200, Mar 300; Gadget: Jan 80, Feb NULL, Mar 120. Unpivot returns 5 rows because NULL February is omitted. |
| Index examples | Payment values stay the same. Indexes change access options; these tiny tables may still use sequential scans. |

The month-growth query compares adjacent **available** months. It does not
manufacture rows for calendar months with no payments. Money in the payment
examples is expressed in naira; sales values are illustrative units.

### 4. Understand when the sample data actually changes

`SELECT`, joins, CTEs, subqueries, window functions, and pivots produce a result
without overwriting source rows. A view stores a query definition and reads current
source data each time. A temporary table stores a separate snapshot for the current
session. `UPDATE` and the status-update procedure change stored rows.

For example, run the Views notebook, then inspect the baseline:

```sql
SET search_path TO sql_practice, public;
SELECT * FROM payment_transactions WHERE transaction_id = 105;
SELECT * FROM vv_successful_transaction WHERE transaction_id = 105;
```

The first query returns a Pending payment of 15,000. The view returns no row.
Now execute the Stored_procedure notebook (which creates and calls the procedure),
or, once its first definition cell has been run, execute:

```sql
CALL sp_update_transaction_status(105, 'Success');
SELECT * FROM payment_transactions WHERE transaction_id = 105;
SELECT * FROM vv_successful_transaction WHERE transaction_id = 105;
CALL sp_customer_summary(202, NULL, NULL);
```

Payment 105 is now Success and appears in the view. Customer 202 now has 2
successful payments totaling 55,000, so rerunning the segmentation query changes
that customer from Basic to Standard. March successful volume rises from 55,000
to 70,000. The raw snapshot still holds the original Pending value. If your client
uses manual transactions, commit your update to make it visible to other sessions.

To preview a stored change and undo it, after creating the procedure:

```sql
BEGIN;
CALL sp_update_transaction_status(106, 'Success');
SELECT * FROM vv_successful_transaction WHERE transaction_id = 106;
ROLLBACK;
```

To save cleaned data as a separate table, run once:

```sql
CREATE TABLE sql_practice.clean_customers AS
SELECT * FROM sql_practice.vv_customer_staging;
SELECT * FROM sql_practice.clean_customers ORDER BY customer_id;
```

This keeps raw text available for comparison. The new table is a snapshot; later
raw changes appear in the view, but do not automatically refresh this table.
The incremental example extracts and validates a batch only; it does not load a
target or advance the watermark. In a complete pipeline those operations belong
in the same successful transaction before the next extraction.
