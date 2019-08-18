USE [Demo]
GO

BEGIN
	-- DECLARE PARAMETERS
	DECLARE @CommitChange BIT = 1; -- 1 to commit change, 0 to cancel change
	DECLARE @TableName VARCHAR(20) = '[dbo].[Customer]';
	DECLARE @NewColumn_Email NVARCHAR(50) = 'Email';
	DECLARE @NewColumn_SSN NVARCHAR(20) = 'SSN';

	BEGIN TRANSACTION
		BEGIN TRY
			-- Taking a snapshot of existing columns and types in target table
			SELECT 
				OBJECT_ID,
				sc.name,
				st.name,
				sc.max_length,
				sc.system_type_id,
				sc.user_type_id,
				sc.is_nullable
			FROM sys.columns sc
			INNER JOIN sys.types st 
				ON sc.user_type_id = st.user_type_id
			WHERE OBJECT_ID = OBJECT_ID(@TableName)

			-- Add new column Email if not exist
			IF NOT EXISTS(
				SELECT * FROM sys.columns WHERE name = @NewColumn_Email AND OBJECT_ID = OBJECT_ID(@TableName)
			)
				BEGIN
					ALTER TABLE [dbo].[Customer]
						ADD Email NVARCHAR(50) NULL;
					PRINT 'New Column Email has been added!'
				END

			-- Add new column SSN if not exist
			IF NOT EXISTS(
				SELECT * FROM sys.columns WHERE name = @NewColumn_SSN AND OBJECT_ID = OBJECT_ID(@TableName)
			)
				BEGIN
					ALTER TABLE [dbo].[Customer]
						ADD SSN NVARCHAR(20) NULL;
					PRINT 'New column SSN has been added!'
				END

			-- Take a snapshot of columns and types in target table after changes
			SELECT 
				OBJECT_ID,
				sc.name,
				st.name,
				sc.max_length,
				sc.system_type_id,
				sc.user_type_id,
				sc.is_nullable
				FROM sys.columns sc
					INNER JOIN sys.types st 
				ON sc.user_type_id = st.user_type_id
			WHERE OBJECT_ID = OBJECT_ID(@TableName)

			-- Determine whether to commit or cancel transaction
			IF @CommitChange = 1
				BEGIN
					SELECT 'Committing Transaction...';
					COMMIT TRANSACTION
				END
			ELSE
				BEGIN
					SELECT 'Cancelling Transaction...';
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

	-- Taking a snapshot of existing columns and types in target table in final
	SELECT 
		OBJECT_ID,
		sc.name,
		st.name,
		sc.max_length,
		sc.system_type_id,
		sc.user_type_id,
		sc.is_nullable
		FROM sys.columns sc
			INNER JOIN sys.types st 
		ON sc.user_type_id = st.user_type_id
	WHERE OBJECT_ID = OBJECT_ID(@TableName)

END