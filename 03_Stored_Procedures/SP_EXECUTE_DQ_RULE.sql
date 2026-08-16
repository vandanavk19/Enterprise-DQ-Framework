USE EnterpriseDQFramework;
GO

DROP PROCEDURE IF EXISTS SP_EXECUTE_DQ_RULE;
GO

CREATE PROCEDURE SP_EXECUTE_DQ_RULE
    @ConfigID INT      -- Configuration ID to execute
AS
BEGIN

    SET NOCOUNT ON;

    -----------------------------------------------------
    -- ENTERPRISE DATA QUALITY RULE EXECUTION PROCEDURE
    -----------------------------------------------------
    -- Purpose:
    --     Executes one configured data quality rule.
    --
    -- Processing flow:
    --
    --     ConfigID
    --        ↓
    --     Rule/Object Configuration
    --        ↓
    --     Object Metadata
    --        ↓
    --     Rule Metadata
    --        ↓
    --     Rule Parameters
    --        ↓
    --     Generate Validation SQL
    --        ↓
    --     Execute Validation
    --        ↓
    --     Determine Status
    --        ↓
    --     Write Execution Log
    --        ↓
    --     Capture Exception Records
    --
    -- Supported Rules:
    --     1. NULL_CHECK
    --     2. RANGE_CHECK
    --     3. DUPLICATE_CHECK
    --     4. DATE_CHECK
    --     5. REGEX_CHECK
    --
    -- The procedure is metadata-driven.
    -- The caller only needs to provide ConfigID.
    -----------------------------------------------------

    -----------------------------------------------------
    -- STEP 0 : Variable Declarations
    -----------------------------------------------------

    -- Metadata
    DECLARE @ObjectID INT;
    DECLARE @RuleID INT;
    DECLARE @TableName VARCHAR(100);
    DECLARE @ColumnName VARCHAR(100);
    DECLARE @PrimaryKeyColumn VARCHAR(100);
    DECLARE @RuleName VARCHAR(100);

    -- Rule Parameters
    DECLARE @MinValue VARCHAR(100);
    DECLARE @MaxValue VARCHAR(100);
    DECLARE @MinDate VARCHAR(100);
    DECLARE @MaxDate VARCHAR(100);
    DECLARE @Pattern VARCHAR(500);

    -- Dynamic SQL
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ExceptionSQL NVARCHAR(MAX);

    -- Execution information
    DECLARE @ViolationCount INT;
    DECLARE @Status VARCHAR(20);
    DECLARE @ExecutionID INT;
    DECLARE @StartTime DATETIME2;
    DECLARE @EndTime DATETIME2;


    -----------------------------------------------------
    -- Record execution start time
    -----------------------------------------------------

    SET @StartTime = GETDATE();

    BEGIN TRY

        -------------------------------------------------
        -- STEP 1 : Validate ConfigID
        -------------------------------------------------
        -- Read the active configuration selected by
        -- the caller.
        --
        -- The configuration determines:
        --     • Business object
        --     • Rule
        --     • Column
        -------------------------------------------------

        SELECT
            @ObjectID = ObjectID,
            @RuleID = RuleID,
            @ColumnName = ColumnName
        FROM DQ_RULE_OBJECT_CONFIG
        WHERE ConfigID = @ConfigID
          AND IsActive = 1;


        -------------------------------------------------
        -- ERROR CHECK 1 : Configuration Validation
        -------------------------------------------------
        -- If no active configuration was found,
        -- stop execution immediately.
        -------------------------------------------------

        IF @ObjectID IS NULL
        BEGIN
            THROW 50001,
                  'Invalid or inactive ConfigID. No active configuration was found.',
                  1;
        END;


        -------------------------------------------------
        -- STEP 2 : Read Object Metadata
        -------------------------------------------------
        -- Resolve the physical business table and
        -- primary key using ObjectID.
        -------------------------------------------------

        SELECT
            @TableName = TableName,
            @PrimaryKeyColumn = PrimaryKeyColumn
        FROM DQ_OBJECT_META
        WHERE ObjectID = @ObjectID
          AND IsActive = 1;


        -------------------------------------------------
        -- ERROR CHECK 2 : Object Metadata Validation
        -------------------------------------------------
        -- The configuration cannot execute if the
        -- referenced business object is missing/inactive.
        -------------------------------------------------

        IF @TableName IS NULL
        BEGIN
            THROW 50002,
                  'Object metadata was not found or is inactive for the configured ObjectID.',
                  1;
        END;


        IF @PrimaryKeyColumn IS NULL
        BEGIN
            THROW 50003,
                  'Primary key metadata is missing for the configured business object.',
                  1;
        END;


        -------------------------------------------------
        -- STEP 3 : Read Rule Metadata
        -------------------------------------------------
        -- Resolve the rule name from the rule master.
        -------------------------------------------------

        SELECT
            @RuleName = Rule_Name
        FROM DQ_RULE_MASTER
        WHERE Rule_ID = @RuleID
          AND Is_Active = 1;


        -------------------------------------------------
        -- ERROR CHECK 3 : Rule Validation
        -------------------------------------------------

        IF @RuleName IS NULL
        BEGIN
            THROW 50004,
                  'Rule metadata was not found or is inactive for the configured RuleID.',
                  1;
        END;


        -------------------------------------------------
        -- STEP 4 : Validate Supported Rule
        -------------------------------------------------
        -- Only rules implemented by this procedure
        -- are allowed to execute.
        -------------------------------------------------

        IF @RuleName NOT IN
        (
            'NULL_CHECK',
            'RANGE_CHECK',
            'DUPLICATE_CHECK',
            'DATE_CHECK',
            'REGEX_CHECK'
        )
        BEGIN
            THROW 50005,
                  'The configured rule is not supported by SP_EXECUTE_DQ_RULE.',
                  1;
        END;


        -------------------------------------------------
        -- STEP 5 : Read Rule Parameters
        -------------------------------------------------
        -- Parameters are configuration-specific.
        --
        -- Examples:
        --
        -- RANGE_CHECK
        --     MinValue
        --     MaxValue
        --
        -- DATE_CHECK
        --     MinDate
        --     MaxDate
        --
        -- REGEX_CHECK
        --     Pattern
        --
        -- NULL_CHECK and DUPLICATE_CHECK do not require
        -- parameters.
        -------------------------------------------------

        SELECT

            @MinValue =
            MAX
            (
                CASE
                    WHEN ParameterName = 'MinValue'
                    THEN ParameterValue
                END
            ),

            @MaxValue =
            MAX
            (
                CASE
                    WHEN ParameterName = 'MaxValue'
                    THEN ParameterValue
                END
            ),

            @MinDate =
            MAX
            (
                CASE
                    WHEN ParameterName = 'MinDate'
                    THEN ParameterValue
                END
            ),

            @MaxDate =
            MAX
            (
                CASE
                    WHEN ParameterName = 'MaxDate'
                    THEN ParameterValue
                END
            ),

            @Pattern =
            MAX
            (
                CASE
                    WHEN ParameterName = 'Pattern'
                    THEN ParameterValue
                END
            )

        FROM DQ_RULE_PARAMETER
        WHERE ConfigID = @ConfigID
          AND IsActive = 1;


        -------------------------------------------------
        -- STEP 6 : Validate Required Parameters
        -------------------------------------------------
        -- Each rule validates only the parameters it
        -- actually requires.
        -------------------------------------------------

        IF @RuleName = 'RANGE_CHECK'
        BEGIN

            IF NULLIF(LTRIM(RTRIM(@MinValue)), '') IS NULL
               OR NULLIF(LTRIM(RTRIM(@MaxValue)), '') IS NULL
            BEGIN
                THROW 50006,
                      'RANGE_CHECK requires active MinValue and MaxValue parameters.',
                      1;
            END;

            IF TRY_CONVERT(DECIMAL(38,10), @MinValue) IS NULL
               OR TRY_CONVERT(DECIMAL(38,10), @MaxValue) IS NULL
            BEGIN
                THROW 50007,
                      'RANGE_CHECK MinValue and MaxValue must be numeric.',
                      1;
            END;

        END;


        IF @RuleName = 'DATE_CHECK'
        BEGIN

            IF NULLIF(LTRIM(RTRIM(@MinDate)), '') IS NULL
               OR NULLIF(LTRIM(RTRIM(@MaxDate)), '') IS NULL
            BEGIN
                THROW 50008,
                      'DATE_CHECK requires active MinDate and MaxDate parameters.',
                      1;
            END;

            IF TRY_CONVERT(DATE, @MinDate) IS NULL
            BEGIN
                THROW 50009,
                      'DATE_CHECK MinDate must be a valid date.',
                      1;
            END;

            -- MaxDate contain GETDATE() because the
            -- framework supports a dynamic current-date
            -- upper boundary.

            IF UPPER(LTRIM(RTRIM(@MaxDate))) <> 'GETDATE()'
               AND TRY_CONVERT(DATE, @MaxDate) IS NULL
            BEGIN
                THROW 50010,
                      'DATE_CHECK MaxDate must be a valid date or GETDATE().',
                      1;
            END;

        END;


        IF @RuleName = 'REGEX_CHECK'
        BEGIN

            IF NULLIF(LTRIM(RTRIM(@Pattern)), '') IS NULL
            BEGIN
                THROW 50011,
                      'REGEX_CHECK requires an active Pattern parameter.',
                      1;
            END;

        END;


        -------------------------------------------------
        -- STEP 7 : Generate Validation SQL
        -------------------------------------------------
        -- Build the rule-specific validation query.
        --
        -- The generated SQL returns the number of
        -- records that violate the selected rule.
        -------------------------------------------------

        IF @RuleName = 'NULL_CHECK'
        BEGIN

            SET @SQL =
            'SELECT @Count = COUNT(*)
             FROM ' + QUOTENAME(@TableName) +
            ' WHERE ' + QUOTENAME(@ColumnName) +
            ' IS NULL';

        END


        ELSE IF @RuleName = 'RANGE_CHECK'
        BEGIN

            SET @SQL =
            'SELECT @Count = COUNT(*)
             FROM ' + QUOTENAME(@TableName) +
            ' WHERE ' + QUOTENAME(@ColumnName) +
            ' < ' + @MinValue +
            ' OR ' + QUOTENAME(@ColumnName) +
            ' > ' + @MaxValue;

        END


        ELSE IF @RuleName = 'DUPLICATE_CHECK'
        BEGIN

            SET @SQL =
            'SELECT @Count = COUNT(*)
             FROM ' + QUOTENAME(@TableName) + '
             WHERE ' + QUOTENAME(@ColumnName) + ' IN
             (
                 SELECT ' + QUOTENAME(@ColumnName) + '
                 FROM ' + QUOTENAME(@TableName) + '
                 GROUP BY ' + QUOTENAME(@ColumnName) + '
                 HAVING COUNT(*) > 1
             )';

        END


        ELSE IF @RuleName = 'DATE_CHECK'
        BEGIN

            SET @SQL =
            'SELECT @Count = COUNT(*)
             FROM ' + QUOTENAME(@TableName) +
            ' WHERE ' + QUOTENAME(@ColumnName) +
            ' < ''' + @MinDate + '''
             OR ' + QUOTENAME(@ColumnName) +
            ' > ' + @MaxDate;

        END


        ELSE IF @RuleName = 'REGEX_CHECK'
        BEGIN

            -- The current implementation uses SQL LIKE
            -- pattern matching. The rule name is retained
            -- as REGEX_CHECK to remain consistent with the
            -- existing project metadata.

            SET @SQL =
            'SELECT @Count = COUNT(*)
             FROM ' + QUOTENAME(@TableName) + '
             WHERE ' + QUOTENAME(@ColumnName) +
            ' NOT LIKE ''' + @Pattern + '''';

        END;

        -------------------------------------------------
        -- ERROR CHECK 4 : SQL Generation
        -------------------------------------------------
        -- Prevent execution if no validation SQL was
        -- generated.
        -------------------------------------------------

        IF @SQL IS NULL
        BEGIN
            THROW 50012,
                  'Validation SQL could not be generated for the configured rule.',
                  1;
        END;


        -------------------------------------------------
        -- STEP 8 : Display Generated SQL
        -------------------------------------------------
        -- Useful during development and debugging.
        -- This can be removed or replaced with formal
        -- application logging in a production version.
        -------------------------------------------------

        PRINT 'Generated Validation SQL:';
        PRINT @SQL;

        -------------------------------------------------
        -- STEP 9 : Execute Validation SQL
        -------------------------------------------------
        -- The COUNT(*) result is returned through the
        -- @Count OUTPUT parameter.
        -------------------------------------------------

        SET @ViolationCount = NULL;

        EXEC sp_executesql
            @SQL,
            N'@Count INT OUTPUT',
            @Count = @ViolationCount OUTPUT;

        -------------------------------------------------
        -- ERROR CHECK 5 : Validation Result
        -------------------------------------------------
        -- A successful validation must always return a
        -- violation count.
        -------------------------------------------------

        IF @ViolationCount IS NULL
        BEGIN
            THROW 50013,
                  'Validation completed without returning a violation count.',
                  1;
        END;

        -------------------------------------------------
        -- STEP 10 : Determine Validation Status
        -------------------------------------------------
        -- Compare the violation count against the
        -- configured threshold ranges.
        --
        -- Possible results:
        --     PASS
        --     WARNING
        --     FAIL
        --     CRITICAL
        -------------------------------------------------

        SELECT
            @Status = Status
        FROM DQ_RULE_THRESHOLD
        WHERE RuleID = @RuleID
          AND @ViolationCount BETWEEN MinViolations AND MaxViolations
          AND IsActive = 1;


        -------------------------------------------------
        -- ERROR CHECK 6 : Threshold Validation
        -------------------------------------------------
        -- Every supported rule must have an applicable
        -- threshold for its violation count.
        -------------------------------------------------

        IF @Status IS NULL
        BEGIN
            THROW 50014,
                  'No active threshold was found for the calculated violation count.',
                  1;
        END;

        -------------------------------------------------
        -- STEP 11 : Record Execution End Time
        -------------------------------------------------

        SET @EndTime = GETDATE();

        -------------------------------------------------
        -- STEP 12 : Log Execution Summary
        -------------------------------------------------
        -- One record is written for every successfully
        -- executed configuration.
        -------------------------------------------------

        INSERT INTO DQ_EXECUTION_LOG
        (
            ConfigID,
            TableName,
            ColumnName,
            RuleName,
            ViolationCount,
            Status,
            ExecutionStartTime,
            ExecutionEndTime,
            ExecutionDurationMs
        )
        VALUES
        (
            @ConfigID,
            @TableName,
            @ColumnName,
            @RuleName,
            @ViolationCount,
            @Status,
            @StartTime,
            @EndTime,
            DATEDIFF
            (
                MILLISECOND,
                @StartTime,
                @EndTime
            )
        );

        -------------------------------------------------
        -- Capture the generated execution ID.
        -------------------------------------------------

        SET @ExecutionID =
            CONVERT(INT, SCOPE_IDENTITY());

        -------------------------------------------------
        -- STEP 13 : Generate Exception SQL
        -------------------------------------------------
        -- Generate a second query that retrieves the
        -- actual records responsible for the violations.
        --
        -- These records are stored in
        -- DQ_DATA_EXCEPTION_LOG.
        -------------------------------------------------

        IF @RuleName = 'NULL_CHECK'
        BEGIN

            SET @ExceptionSQL =
            'INSERT INTO DQ_DATA_EXCEPTION_LOG
            (
                ExecutionID,
                ConfigID,
                TableName,
                PrimaryKeyValue,
                ColumnName,
                InvalidValue,
                ErrorMessage
            )
            SELECT
                ' + CAST(@ExecutionID AS VARCHAR(10)) + ',
                ' + CAST(@ConfigID AS VARCHAR(10)) + ',
                ''' + @TableName + ''',
                CAST(' + QUOTENAME(@PrimaryKeyColumn) + ' AS VARCHAR(100)),
                ''' + @ColumnName + ''',
                CAST(' + QUOTENAME(@ColumnName) + ' AS VARCHAR(500)),
                ''' + @ColumnName + ' is NULL''
            FROM ' + QUOTENAME(@TableName) + '
            WHERE ' + QUOTENAME(@ColumnName) + ' IS NULL';

        END


        ELSE IF @RuleName = 'RANGE_CHECK'
        BEGIN

            SET @ExceptionSQL =
            'INSERT INTO DQ_DATA_EXCEPTION_LOG
            (
                ExecutionID,
                ConfigID,
                TableName,
                PrimaryKeyValue,
                ColumnName,
                InvalidValue,
                ErrorMessage
            )
            SELECT
                ' + CAST(@ExecutionID AS VARCHAR(10)) + ',
                ' + CAST(@ConfigID AS VARCHAR(10)) + ',
                ''' + @TableName + ''',
                CAST(' + QUOTENAME(@PrimaryKeyColumn) + ' AS VARCHAR(100)),
                ''' + @ColumnName + ''',
                CAST(' + QUOTENAME(@ColumnName) + ' AS VARCHAR(500)),
                ''' + @ColumnName + ' is outside valid range''
            FROM ' + QUOTENAME(@TableName) + '
            WHERE ' + QUOTENAME(@ColumnName) + ' < ' + @MinValue + '
               OR ' + QUOTENAME(@ColumnName) + ' > ' + @MaxValue;

        END


        ELSE IF @RuleName = 'DUPLICATE_CHECK'
        BEGIN

            SET @ExceptionSQL =
            'INSERT INTO DQ_DATA_EXCEPTION_LOG
            (
                ExecutionID,
                ConfigID,
                TableName,
                PrimaryKeyValue,
                ColumnName,
                InvalidValue,
                ErrorMessage
            )
            SELECT
                ' + CAST(@ExecutionID AS VARCHAR(10)) + ',
                ' + CAST(@ConfigID AS VARCHAR(10)) + ',
                ''' + @TableName + ''',
                CAST(' + QUOTENAME(@PrimaryKeyColumn) + ' AS VARCHAR(100)),
                ''' + @ColumnName + ''',
                CAST(' + QUOTENAME(@ColumnName) + ' AS VARCHAR(500)),
                ''' + @ColumnName + ' is duplicated''
            FROM ' + QUOTENAME(@TableName) + '
            WHERE ' + QUOTENAME(@ColumnName) + ' IN
            (
                SELECT ' + QUOTENAME(@ColumnName) + '
                FROM ' + QUOTENAME(@TableName) + '
                GROUP BY ' + QUOTENAME(@ColumnName) + '
                HAVING COUNT(*) > 1
            )';

        END


        ELSE IF @RuleName = 'DATE_CHECK'
        BEGIN

            SET @ExceptionSQL =
            'INSERT INTO DQ_DATA_EXCEPTION_LOG
            (
                ExecutionID,
                ConfigID,
                TableName,
                PrimaryKeyValue,
                ColumnName,
                InvalidValue,
                ErrorMessage
            )
            SELECT
                ' + CAST(@ExecutionID AS VARCHAR(10)) + ',
                ' + CAST(@ConfigID AS VARCHAR(10)) + ',
                ''' + @TableName + ''',
                CAST(' + QUOTENAME(@PrimaryKeyColumn) + ' AS VARCHAR(100)),
                ''' + @ColumnName + ''',
                CAST(' + QUOTENAME(@ColumnName) + ' AS VARCHAR(500)),
                ''' + @ColumnName + ' contains an invalid date''
            FROM ' + QUOTENAME(@TableName) + '
            WHERE ' + QUOTENAME(@ColumnName) + ' < ''' + @MinDate + '''
               OR ' + QUOTENAME(@ColumnName) + ' > ' + @MaxDate;

        END


        ELSE IF @RuleName = 'REGEX_CHECK'
        BEGIN

            SET @ExceptionSQL =
            'INSERT INTO DQ_DATA_EXCEPTION_LOG
            (
                ExecutionID,
                ConfigID,
                TableName,
                PrimaryKeyValue,
                ColumnName,
                InvalidValue,
                ErrorMessage
            )
            SELECT
                ' + CAST(@ExecutionID AS VARCHAR(10)) + ',
                ' + CAST(@ConfigID AS VARCHAR(10)) + ',
                ''' + @TableName + ''',
                CAST(' + QUOTENAME(@PrimaryKeyColumn) + ' AS VARCHAR(100)),
                ''' + @ColumnName + ''',
                CAST(' + QUOTENAME(@ColumnName) + ' AS VARCHAR(500)),
                ''' + @ColumnName + ' has an invalid format''
            FROM ' + QUOTENAME(@TableName) + '
            WHERE ' + QUOTENAME(@ColumnName) +
            ' NOT LIKE ''' + @Pattern + '''';

        END;

        -------------------------------------------------
        -- STEP 14 : Store Failed Records
        -------------------------------------------------
        -- Only execute exception SQL when it exists.
        --
        -- If the violation count is zero, the INSERT
        -- simply inserts zero rows.
        -------------------------------------------------

        IF @ExceptionSQL IS NULL
        BEGIN
            THROW 50015,
                  'Exception SQL could not be generated for the configured rule.',
                  1;
        END;


        PRINT 'Generated Exception SQL:';
        PRINT @ExceptionSQL;


        EXEC sp_executesql @ExceptionSQL;

        -------------------------------------------------
        -- STEP 15 : Return Execution Summary
        -------------------------------------------------
        -- Return the result to the caller.
        -------------------------------------------------

        SELECT
            @ExecutionID AS ExecutionID,
            @ConfigID AS ConfigID,
            @TableName AS TableName,
            @PrimaryKeyColumn AS PrimaryKeyColumn,
            @ColumnName AS ColumnName,
            @RuleName AS RuleName,
            @ViolationCount AS ViolationCount,
            @Status AS Status;


    END TRY

    BEGIN CATCH

        -------------------------------------------------
        -- ERROR HANDLING
        -------------------------------------------------
        -- If any part of the execution fails:
        --
        --     • Capture the SQL error
        --     • Display useful debugging information
        --     • Stop the current configuration
        --
        -- The master procedure can then continue with
        -- the next configuration.
        -------------------------------------------------

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorNumber INT;
        DECLARE @ErrorLine INT;
        DECLARE @ErrorProcedure NVARCHAR(200);

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorNumber = ERROR_NUMBER(),
            @ErrorLine = ERROR_LINE(),
            @ErrorProcedure = ERROR_PROCEDURE();


        PRINT '---------------------------------------------';
        PRINT 'DATA QUALITY EXECUTION ERROR';
        PRINT '---------------------------------------------';

        PRINT 'ConfigID: '
              + CAST(@ConfigID AS VARCHAR(20));

        PRINT 'Error Number: '
              + CAST(@ErrorNumber AS VARCHAR(20));

        PRINT 'Error Procedure: '
              + ISNULL(@ErrorProcedure, 'N/A');

        PRINT 'Error Line: '
              + CAST(@ErrorLine AS VARCHAR(20));

        PRINT 'Error Message: '
              + @ErrorMessage;

        PRINT '---------------------------------------------';

        -------------------------------------------------
        -- Re-throw the original error so that the caller
        -- knows this configuration failed.
        -------------------------------------------------

        THROW;

    END CATCH;

END;
GO