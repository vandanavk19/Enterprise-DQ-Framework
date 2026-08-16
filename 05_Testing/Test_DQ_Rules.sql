-- Test individual DQ rules

-- Customer - NULL FirstName
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 1;
GO

-- Customer - Age range
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 2;
GO

-- Customer - Email format
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 3;
GO

-- Orders - OrderAmount range
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 4;
GO

-- Orders - OrderDate validation
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 5;
GO

-- Products - NULL ProductName
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 6;
GO

-- Products - Price range
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 7;
GO

-- Employees - NULL FirstName
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 8;
GO

-- Employees - Salary range
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 9;
GO

-- Employees - JoiningDate validation
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 10;
GO

-- Customer - Duplicate Email
EXEC SP_EXECUTE_DQ_RULE @ConfigID = 11;
GO