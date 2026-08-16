USE EnterpriseDQFramework;
GO

DROP PROCEDURE IF EXISTS SP_RUN_ALL_DQ;
GO

CREATE PROCEDURE SP_RUN_ALL_DQ
AS
BEGIN

    SET NOCOUNT ON;

    -----------------------------------------------------
    -- MASTER DATA QUALITY EXECUTION PROCEDURE
    -----------------------------------------------------
    -- Purpose:
    --     Executes every active DQ configuration.
    --
    -- This procedure acts as the orchestration layer
    -- of the Data Quality Framework.
    --
    -- It does NOT contain individual validation logic.
    -- All rule-specific processing is handled by:
    --
    --     SP_EXECUTE_DQ_RULE
    --
    -- Processing flow:
    --
    --     Active Configurations
    --             ↓
    --     ConfigID 1
    --             ↓
    --     SP_EXECUTE_DQ_RULE
    --             ↓
    --     ConfigID 2
    --             ↓
    --     SP_EXECUTE_DQ_RULE
    --             ↓
    --            ...
    --             ↓
    --     All active configurations completed
    --
    -- Any configuration can be enabled/disabled through
    -- DQ_RULE_OBJECT_CONFIG.IsActive without modifying
    -- this procedure.
    -----------------------------------------------------

    -----------------------------------------------------
    -- Variable Declaration
    -----------------------------------------------------

    DECLARE @ConfigID INT;

    -----------------------------------------------------
    -- STEP 1 : Identify Active Configurations
    -----------------------------------------------------
    -- Only configurations marked as active are executed.
    --
    -- Configurations are processed in ConfigID order
    -- to provide predictable execution ordering.
    -----------------------------------------------------

    DECLARE ConfigCursor CURSOR LOCAL FAST_FORWARD FOR

        SELECT ConfigID
        FROM DQ_RULE_OBJECT_CONFIG
        WHERE IsActive = 1
        ORDER BY ConfigID;


    BEGIN TRY

        -------------------------------------------------
        -- STEP 2 : Open Configuration Cursor
        -------------------------------------------------

        OPEN ConfigCursor;

        FETCH NEXT FROM ConfigCursor
        INTO @ConfigID;


        -------------------------------------------------
        -- STEP 3 : Process Each Configuration
        -------------------------------------------------

        WHILE @@FETCH_STATUS = 0
        BEGIN

            -------------------------------------------------
            -- Execute Individual DQ Configuration
            -------------------------------------------------
            -- SP_EXECUTE_DQ_RULE contains the actual
            -- validation logic.
            --
            -- This master procedure only passes the
            -- ConfigID to that procedure.
            -------------------------------------------------

            PRINT 'Executing ConfigID = '
                  + CAST(@ConfigID AS VARCHAR(10));


            BEGIN TRY

                EXEC SP_EXECUTE_DQ_RULE
                    @ConfigID = @ConfigID;

            END TRY

            BEGIN CATCH

                -------------------------------------------------
                -- Configuration-Level Error Handling
                -------------------------------------------------
                -- If one configuration fails, report the error
                -- and continue processing the remaining active
                -- configurations.
                --
                -- This prevents one bad configuration from
                -- stopping the entire DQ execution run.
                -------------------------------------------------

                PRINT 'ERROR executing ConfigID = '
                      + CAST(@ConfigID AS VARCHAR(10));

                PRINT 'Error Number: '
                      + CAST(ERROR_NUMBER() AS VARCHAR(20));

                PRINT 'Error Message: '
                      + ERROR_MESSAGE();

            END CATCH;


            -------------------------------------------------
            -- Move to Next Configuration
            -------------------------------------------------

            FETCH NEXT FROM ConfigCursor
            INTO @ConfigID;

        END;


        -------------------------------------------------
        -- STEP 4 : Close and Release Cursor
        -------------------------------------------------

        CLOSE ConfigCursor;

        DEALLOCATE ConfigCursor;

        -------------------------------------------------
        -- STEP 5 : Execution Complete
        -------------------------------------------------

        PRINT '---------------------------------------------';
        PRINT 'DATA QUALITY EXECUTION COMPLETED.';
        PRINT '---------------------------------------------';


    END TRY


    BEGIN CATCH

        -------------------------------------------------
        -- MASTER PROCEDURE ERROR HANDLING
        -------------------------------------------------
        -- Handles unexpected errors outside the
        -- individual configuration execution.
        -------------------------------------------------

        IF CURSOR_STATUS('local', 'ConfigCursor') >= 0
        BEGIN
            CLOSE ConfigCursor;
        END;


        IF CURSOR_STATUS('local', 'ConfigCursor') >= -1
        BEGIN
            DEALLOCATE ConfigCursor;
        END;


        PRINT '---------------------------------------------';
        PRINT 'DATA QUALITY MASTER EXECUTION ERROR';
        PRINT '---------------------------------------------';

        PRINT 'Error Number: '
              + CAST(ERROR_NUMBER() AS VARCHAR(20));

        PRINT 'Error Line: '
              + CAST(ERROR_LINE() AS VARCHAR(20));

        PRINT 'Error Message: '
              + ERROR_MESSAGE();

        PRINT '---------------------------------------------';


        THROW;

    END CATCH;

END;
GO