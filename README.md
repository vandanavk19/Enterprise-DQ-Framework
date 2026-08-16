# Enterprise DQ Framework

A metadata-driven SQL Server Data Quality Framework for automated data validation, configurable rule execution, threshold-based status evaluation, execution logging, and exception tracking.

## Overview

The Enterprise DQ Framework provides a reusable and configurable approach to data quality validation.

Instead of creating separate validation logic for every table and column, the framework uses metadata and configuration tables to define which data quality rules should be applied and how they should be evaluated.

The framework supports:

- Configurable data quality rules
- Metadata-driven rule execution
- Configurable rule parameters
- Threshold-based status evaluation
- Individual rule execution
- Full framework execution
- Centralized execution logging
- Detailed exception tracking
- Reusable test data and test scripts

## Architecture

```text
Enterprise-DQ-Framework/
├── 01_Database/
│   └── Create_Database.sql
├── 02_Tables/
│   ├── Customer.sql
│   ├── Orders.sql
│   ├── Products.sql
│   ├── Employees.sql
│   ├── DQ_DATA_EXCEPTION_LOG.sql
│   ├── DQ_EXECUTION_LOG.sql
│   ├── DQ_OBJECT_META.sql
│   ├── DQ_RULE_MASTER.sql
│   ├── DQ_RULE_OBJECT_CONFIG.sql
│   ├── DQ_RULE_PARAMETER.sql
│   └── DQ_RULE_THRESHOLD.sql
├── 03_Stored_Procedures/
│   ├── SP_EXECUTE_DQ_RULE.sql
│   └── SP_RUN_ALL_DQ.sql
├── 04_Test_Data/
│   ├── Customer_Data.sql
│   ├── Employees_Data.sql
│   ├── Orders_Data.sql
│   └── Products_Data.sql
├── 05_Testing/
│   ├── Test_DQ_Rules.sql
│   └── Test_Run_All_DQ.sql
└── README.md
```

## Data Quality Rules

The framework currently implements five data quality rules:

| Rule | Description |
|---|---|
| `NULL_CHECK` | Identifies NULL values in configured columns |
| `RANGE_CHECK` | Identifies values outside configured valid ranges |
| `REGEX_CHECK` | Validates values against a configured SQL LIKE pattern |
| `DATE_CHECK` | Identifies dates outside the configured date range |
| `DUPLICATE_CHECK` | Identifies duplicate values in configured columns |

## Metadata-Driven Design

The framework separates business data from data quality configuration.

The configuration tables determine which rules are executed rather than requiring the validation process to be manually rewritten for each table.

### DQ_OBJECT_META

Stores metadata about the source objects, including:

- Database name
- Schema name
- Table name
- Primary key column
- Active status
- Business domain
- Source system
- Criticality

### DQ_RULE_MASTER

Stores the available data quality rules and their associated rule definitions.

### DQ_RULE_OBJECT_CONFIG

Maps a data quality rule to a specific table and column and defines configuration attributes such as severity and active status.

### DQ_RULE_PARAMETER

Stores configurable parameters used by individual rules, such as:

- Minimum values
- Maximum values
- Date boundaries
- Regex patterns

### DQ_RULE_THRESHOLD

Defines violation thresholds and the corresponding status:

- `PASS`
- `WARNING`
- `FAIL`
- `CRITICAL`

## Stored Procedures

### SP_EXECUTE_DQ_RULE

Executes a single configured data quality rule using its `ConfigID`.

Example:

```sql
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 1;
GO
```

The procedure:

1. Retrieves the configuration and associated parameters.
2. Performs the configured validation.
3. Evaluates the violation count against the configured thresholds.
4. Records the execution result.
5. Records individual violations when applicable.

The procedure includes error handling using `TRY...CATCH`.

### SP_RUN_ALL_DQ

Acts as the master execution procedure.

It retrieves all active configurations from `DQ_RULE_OBJECT_CONFIG` and executes `SP_EXECUTE_DQ_RULE` for each active `ConfigID`.

Example:

```sql
EXEC SP_RUN_ALL_DQ;
GO
```

This provides a single entry point for running the complete data quality framework.

The procedure includes configuration-level error handling so that an error with one configuration does not prevent the remaining active configurations from being processed.

## Execution Logging

Each rule execution is recorded in `DQ_EXECUTION_LOG`.

The execution log stores information including:

- ExecutionID
- ConfigID
- TableName
- ColumnName
- RuleName
- ViolationCount
- Status
- ExecutionStartTime
- ExecutionEndTime
- ExecutionDurationMs
- ExecutedBy

`ExecutionID` uniquely identifies each rule execution and allows individual framework runs to be tracked.

## Exception Logging

Individual data quality violations are recorded in `DQ_DATA_EXCEPTION_LOG`.

The exception log stores information about the records that violated a configured data quality rule, including:

- ExecutionID
- ConfigID
- TableName
- Primary key value
- ColumnName
- Invalid value
- Error message

This allows individual problematic records to be identified and investigated.

## Test Data

The test data contains a mixture of valid records and intentionally introduced data quality violations.

These violations are designed to demonstrate:

- NULL validation
- Range validation
- Date validation
- Email format validation
- Duplicate detection
- Threshold-based status evaluation
- Exception logging

## Testing

The `05_Testing` folder contains scripts for validating the framework.

### Test_DQ_Rules.sql

Tests individual data quality configurations by `ConfigID`.

Example:

```sql
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 1;
GO

EXEC SP_EXECUTE_DQ_RULE @ConfigID = 2;
GO

EXEC SP_EXECUTE_DQ_RULE @ConfigID = 3;
GO
```

The test script covers the configured rules across the Customer, Orders, Products, and Employees tables.

### Test_Run_All_DQ.sql

Tests the complete framework execution through the master procedure.

Example:

```sql
EXEC SP_RUN_ALL_DQ;
GO
```

## How to Run

### 1. Create the Database

Run:

```text
01_Database/Create_Database.sql
```

### 2. Create the Business and DQ Tables

Run the SQL scripts under:

```text
02_Tables/
```

This creates:

- Customer
- Orders
- Products
- Employees
- DQ_OBJECT_META
- DQ_RULE_MASTER
- DQ_RULE_OBJECT_CONFIG
- DQ_RULE_PARAMETER
- DQ_RULE_THRESHOLD
- DQ_EXECUTION_LOG
- DQ_DATA_EXCEPTION_LOG

### 3. Load Test Data

Run the scripts under:

```text
04_Test_Data/
```

The test data contains intentionally introduced data quality issues for framework validation.

### 4. Create the Stored Procedures

Run:

```text
03_Stored_Procedures/SP_EXECUTE_DQ_RULE.sql
```

and:

```text
03_Stored_Procedures/SP_RUN_ALL_DQ.sql
```

### 5. Test Individual Rules

Run:

```text
05_Testing/Test_DQ_Rules.sql
```

This executes individual configurations using their `ConfigID`.

### 6. Test the Complete Framework

Run:

```text
05_Testing/Test_Run_All_DQ.sql
```

This executes:

```sql
EXEC SP_RUN_ALL_DQ;
GO
```

## Expected Results

After execution, review `DQ_EXECUTION_LOG` to verify:

- Which configurations were executed
- Which table and column were validated
- Which rule was applied
- Number of violations
- Final status
- Execution timing

Example:

```sql
SELECT *
FROM DQ_EXECUTION_LOG
ORDER BY ExecutionID;
```

Review `DQ_DATA_EXCEPTION_LOG` to identify the individual records that violated the configured rules.

Example:

```sql
SELECT *
FROM DQ_DATA_EXCEPTION_LOG
ORDER BY ExecutionID DESC;
```

## Example Execution Flow

```text
DQ_RULE_OBJECT_CONFIG
          |
          v
   Active ConfigID
          |
          v
 SP_EXECUTE_DQ_RULE
          |
          +-------> Data Validation
          |
          +-------> Threshold Evaluation
          |
          +-------> DQ_EXECUTION_LOG
          |
          +-------> DQ_DATA_EXCEPTION_LOG
```

For a complete framework run:

```text
SP_RUN_ALL_DQ
      |
      v
Retrieve Active Configurations
      |
      v
Execute SP_EXECUTE_DQ_RULE
      |
      v
Validate Each Configured Rule
      |
      v
Log Results and Exceptions
```

## Technologies

- Microsoft SQL Server
- T-SQL
- Stored Procedures
- Metadata-driven data quality framework
- Configuration-driven rule execution

## Project Purpose

This project demonstrates how a reusable data quality framework can be designed using SQL Server metadata, configuration tables, stored procedures, threshold-based evaluation, execution logging, and exception tracking.

The framework is designed to make data quality validation configurable and reusable instead of hard-coding validation logic separately for every table and column.
