USE EnterpriseDQFramework;
GO

CREATE TABLE DQ_OBJECT_META
(
    ObjectID INT PRIMARY KEY IDENTITY(1,1),

    DatabaseName VARCHAR(100),

    SchemaName VARCHAR(100),

    TableName VARCHAR(100),

    PrimaryKeyColumn VARCHAR(100),

    BusinessDomain VARCHAR(100),

    SourceSystem VARCHAR(100),

    Criticality VARCHAR(20),

    IsActive BIT DEFAULT 1,

    CreatedDate DATETIME DEFAULT GETDATE(),

    UpdatedDate DATETIME DEFAULT GETDATE()
);


INSERT INTO DQ_OBJECT_META
(
    DatabaseName,
    SchemaName,
    TableName,
    PrimaryKeyColumn,
    BusinessDomain,
    SourceSystem,
    Criticality,
    IsActive
)
VALUES
(
    'EnterpriseDQFramework',
    'dbo',
    'Customer',
    'CustomerID',
    'Sales',
    'CRM',
    'High',
    1
),
(
    'EnterpriseDQFramework',
    'dbo',
    'Orders',
    'OrderID',
    'Sales',
    'ERP',
    'Critical',
    1
),
(
    'EnterpriseDQFramework',
    'dbo',
    'Products',
    'ProductID',
    'Inventory',
    'PIM',
    'Medium',
    1
),
(
    'EnterpriseDQFramework',
    'dbo',
    'Employees',
    'EmployeeID',
    'HR',
    'HRMS',
    'Low',
    1
);
