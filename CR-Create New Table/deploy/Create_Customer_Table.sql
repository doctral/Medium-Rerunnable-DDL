USE [Demo]
GO

BEGIN 
	-- DECLARE Parameters
	DECLARE @CommitChange BIT = 1;  -- 1 to commit transaction, 0 to cancel transaction
	DECLARE @NewTableName VARCHAR(20) = 'Customer';
	DECLARE @SchemaName VARCHAR(10) = 'dbo';
	-- Taking a snapshot before the change
	SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @NewTableName

	BEGIN TRANSACTION
		BEGIN TRY
			-- Create table if not exist 
			IF NOT EXISTS (
				SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @NewTableName 
			)
				BEGIN
					CREATE TABLE [dbo].[Customer]
					(
						Id INT PRIMARY KEY IDENTITY NOT NULL,
						FirstName NVARCHAR(10) NOT NULL,
						LastName NVARCHAR(10) NOT NULL,
						[Address] NVARCHAR(50) NOT NULL,
						CreateDate DATE NOT NULL DEFAULT GETDATE(),
						UpdateDate DATE NULL
					)
				END
			
			-- Take a snapshot after change
			SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @NewTableName

			-- Determine whether to commit or cancel transaction based on parameters
			IF @CommitChange = 1
				BEGIN
					SELECT 'Committing Transaction...'
					COMMIT TRANSACTION
				END
			ELSE
				BEGIN
					SELECT 'Cancelling Transaction...'
					ROLLBACK TRANSACTION
				END
		END TRY
		BEGIN CATCH
			SELECT
				ERROR_NUMBER(),
				ERROR_SEVERITY(),
				ERROR_STATE(),
				ERROR_PROCEDURE(),
				ERROR_LINE(),
				ERROR_MESSAGE()
			
			SELECT 'Aborting Transaction...'
			ROLLBACK TRANSACTION
		END CATCH

		-- Take a snapshot of final result
		SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @NewTableName
		SELECT * FROM dbo.Customer
END
