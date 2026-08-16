CREATE TABLE DQ_RULE_THRESHOLD
(
    ThresholdID INT IDENTITY(1,1) PRIMARY KEY,

    RuleID INT NOT NULL,

    MinViolations INT NOT NULL,

    MaxViolations INT NOT NULL,

    Status VARCHAR(20) NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1,

    CreatedDate DATETIME2 DEFAULT GETDATE(),

    UpdatedDate DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Threshold_Rule
        FOREIGN KEY (RuleID)
        REFERENCES DQ_RULE_MASTER(rule_id)
);


INSERT INTO DQ_RULE_THRESHOLD
(
    RuleID,
    MinViolations,
    MaxViolations,
    Status
)
VALUES

-- NULL_CHECK
(1, 0, 0, 'PASS'),
(1, 1, 2, 'WARNING'),
(1, 3, 5, 'FAIL'),
(1, 6, 999999, 'CRITICAL'),

-- RANGE_CHECK
(2, 0, 0, 'PASS'),
(2, 1, 2, 'WARNING'),
(2, 3, 5, 'FAIL'),
(2, 6, 999999, 'CRITICAL'),

-- DUPLICATE_CHECK
(3, 0, 0, 'PASS'),
(3, 1, 2, 'WARNING'),
(3, 3, 5, 'FAIL'),
(3, 6, 999999, 'CRITICAL'),

-- DATE_CHECK
(4, 0, 0, 'PASS'),
(4, 1, 2, 'WARNING'),
(4, 3, 5, 'FAIL'),
(4, 6, 999999, 'CRITICAL'),

-- REGEX_CHECK
(5, 0, 0, 'PASS'),
(5, 1, 2, 'WARNING'),
(5, 3, 5, 'FAIL'),
(5, 6, 999999, 'CRITICAL');