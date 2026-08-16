USE EnterpriseDQFramework;
GO

CREATE TABLE DQ_RULE_PARAMETER
(
    ParameterID INT IDENTITY(1,1) PRIMARY KEY,

    ConfigID INT NOT NULL,

    ParameterName VARCHAR(100) NOT NULL,

    ParameterValue VARCHAR(500) NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1,

    CreatedDate DATETIME2 DEFAULT GETDATE(),

    UpdatedDate DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Parameter_Config
        FOREIGN KEY (ConfigID)
        REFERENCES DQ_RULE_OBJECT_CONFIG(ConfigID)
);
GO


INSERT INTO DQ_RULE_PARAMETER
(
    ConfigID,
    ParameterName,
    ParameterValue
)
VALUES

-- Customer Age
(2, 'MinValue', '0'),
(2, 'MaxValue', '120'),

-- Customer Email
(3, 'Pattern', '%_@%._%'),

-- Orders OrderAmount
(4, 'MinValue', '0'),
(4, 'MaxValue', '10000'),

-- Orders OrderDate
(5, 'MinDate', '2000-01-01'),
(5, 'MaxDate', 'GETDATE()'),

-- Products Price
(7, 'MinValue', '0'),
(7, 'MaxValue', '100000'),

-- Employees Salary
(9, 'MinValue', '0'),
(9, 'MaxValue', '100000'),

-- Employees JoiningDate
(10, 'MinDate', '2000-01-01'),
(10, 'MaxDate', 'GETDATE()');
GO