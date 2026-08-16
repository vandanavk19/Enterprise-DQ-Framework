USE EnterpriseDQFramework;
GO

CREATE TABLE DQ_RULE_MASTER
(
    rule_id INT PRIMARY KEY IDENTITY(1,1),

    rule_name VARCHAR(100) NOT NULL,

    description VARCHAR(500),

    check_level VARCHAR(20),

    rule_sql NVARCHAR(MAX),

    required_params VARCHAR(500),

    output_format VARCHAR(100),

    is_active BIT NOT NULL DEFAULT 1,

    audit_insert_dt DATETIME2 DEFAULT GETDATE(),

    audit_update_dt DATETIME2 DEFAULT GETDATE()
);
GO

INSERT INTO DQ_RULE_MASTER
(
    rule_name,
    description,
    check_level,
    rule_sql,
    required_params,
    output_format
)
VALUES
(
    'NULL_CHECK',
    'Checks whether a column contains NULL values.',
    'COLUMN',
    NULL,
    'TableName, ColumnName',
    'ViolationCount'
),
(
    'RANGE_CHECK',
    'Checks whether values fall within a specified range.',
    'COLUMN',
    NULL,
    'TableName, ColumnName, MinValue, MaxValue',
    'ViolationCount'
),
(
    'DUPLICATE_CHECK',
    'Checks for duplicate values within a column.',
    'COLUMN',
    NULL,
    'TableName, ColumnName',
    'ViolationCount'
),
(
    'DATE_CHECK',
    'Checks whether date values are valid.',
    'COLUMN',
    NULL,
    'TableName, ColumnName',
    'ViolationCount'
),
(
    'REGEX_CHECK',
    'Checks whether values match a specified pattern.',
    'COLUMN',
    NULL,
    'TableName, ColumnName, Pattern',
    'ViolationCount'
);
GO