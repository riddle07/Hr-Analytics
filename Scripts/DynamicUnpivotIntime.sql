-- incoming parameters
BEGIN
	DECLARE @table NVARCHAR(257) = N'dbo.in_time',
		@key_column SYSNAME = N'Employee_Key';
	-- local variables
	DECLARE @sql NVARCHAR(MAX) = N'',
		@cols NVARCHAR(MAX) = N'';

	SELECT @cols += ', ' + QUOTENAME(name)
	FROM sys.columns
	WHERE [object_id] = OBJECT_ID(@table)
		AND name <> @key_column

	SELECT @sql = N'SELECT ' + @key_column + ', Date, In_Time
  FROM 
  (
    SELECT ' + @key_column + @cols + '
 FROM ' + @table + '
  ) AS cp
  UNPIVOT
  (
    In_time FOR Date IN (' + STUFF(@cols, 1, 1, '') + ')
  ) AS up';

	INSERT INTO Dbo.InTimeUnPivot
	EXEC sys.sp_executesql @sql
END

/*CREATE TABLE Dbo.InTimeUnPivot (
	EmployeeId INT,
	DATE VARCHAR(250),
	InTime VARCHAR(250)
	)*/
