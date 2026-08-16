USE EnterpriseDQFramework;
GO

CREATE TABLE DQ_RULE_OBJECT_CONFIG
(
    ConfigID INT IDENTITY(1,1) PRIMARY KEY,

    ObjectID INT NOT NULL,

    RuleID INT NOT NULL,

    ColumnName VARCHAR(100) NOT NULL,

    Severity VARCHAR(20) NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1,

    CreatedDate DATETIME2 DEFAULT GETDATE(),

    UpdatedDate DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Config_Object
        FOREIGN KEY (ObjectID)
        REFERENCES DQ_OBJECT_META(ObjectID),

    CONSTRAINT FK_Config_Rule
        FOREIGN KEY (RuleID)
        REFERENCES DQ_RULE_MASTER(rule_id)
);
GO


INSERT INTO DQ_RULE_OBJECT_CONFIG
(
    ObjectID,
    RuleID,
    ColumnName,
    Severity
)
VALUES
-- Customer
(1, 1, 'FirstName', 'Critical'),
(1, 2, 'Age', 'High'),
(1, 5, 'Email', 'Medium'),

-- Orders
(2, 2, 'OrderAmount', 'Critical'),
(2, 4, 'OrderDate', 'High'),

-- Products
(3, 1, 'ProductName', 'Critical'),
(3, 2, 'Price', 'High'),

-- Employees
(4, 1, 'FirstName', 'Critical'),
(4, 2, 'Salary', 'High'),
(4, 4, 'JoiningDate', 'Medium'),

-- Customer Duplicate Check
(1, 3, 'Email', 'Medium');
GO
