/*SELECT [IN].EMPLOYEEID,
	--FORMAT(CAST([IN].DATE AS DATE), 'MM-DD-YYYY'),
	SUBSTRING(intime, CHARINDEX(' ', intime) + 1, len(intime)) --OUT_TIME
FROM DBO.INTIMEUNPIVOT [IN]

/*JOIN
     DBO.OUT_TIME_UNPIVOT [OUT]
     ON [IN].EMPLOYEE_KEY = [OUT].EMPLOYEE_KEY;*/
SELECT employeeId,
	cast(DATE AS DATE) DATE,
	cast(SUBSTRING(intime, CHARINDEX(' ', intime) + 1, len(intime)) as Time) InTime
--INTO dbo.condensedFormattedIntime
FROM (
	SELECT employeeId,
		REPLACE(DATE, ' ', '-') DATE,
		intime
	FROM DBO.INTIMEUNPIVOT
	) T*/
MERGE dbo.condensedFormattedIntime tgt
USING (
	SELECT employeeId,
		cast(DATE AS DATE) DATE,
		SUBSTRING(intime, CHARINDEX(' ', intime) + 1, len(intime)) InTime
	--INTO dbo.condensedFormattedIntime
	FROM (
		SELECT employeeId,
			REPLACE(DATE, ' ', '-') DATE,
			intime
		FROM DBO.INTIMEUNPIVOT
		) T
	) src
	ON tgt.employeeId = src.employeeId
		AND tgt.DATE = src.DATE
WHEN MATCHED
	THEN
		UPDATE
		SET tgt.inTime = src.inTime
WHEN NOT MATCHED BY Target
	THEN
		INSERT
		VALUES (
			src.employeeId,
			src.DATE,
			src.inTime
			);

/*SELECT *
FROM dbo.OutTIMEUNPIVOT

SELECT employeeId,
	cast(DATE AS DATE) DATE,
	SUBSTRING(outtime, CHARINDEX(' ', outtime) + 1, len(outtime)) OutTime
INTO dbo.condensedFormattedOuttime
FROM (
	SELECT employeeId,
		REPLACE(DATE, ' ', '-') DATE,
		outtime
	FROM DBO.OutTIMEUNPIVOT
	) T
*/
MERGE dbo.condensedFormattedOutTime tgt
USING (
	SELECT employeeId,
		cast(DATE AS DATE) DATE,
		SUBSTRING(outtime, CHARINDEX(' ', outtime) + 1, len(outtime)) outTime
	--INTO dbo.condensedFormattedIntime
	FROM (
		SELECT employeeId,
			REPLACE(DATE, ' ', '-') DATE,
			outtime
		FROM DBO.OUTTIMEUNPIVOT
		) T
	) src
	ON tgt.employeeId = src.employeeId
		AND tgt.DATE = src.DATE
WHEN MATCHED
	THEN
		UPDATE
		SET tgt.outtime = src.outtime
WHEN NOT MATCHED BY Target
	THEN
		INSERT
		VALUES (
			src.employeeId,
			src.DATE,
			src.outTime
			);

CREATE
	OR

ALTER PROCEDURE usp_CreateMergedTable
AS
BEGIN
	SELECT [in].EMPLOYEEId,
		[in].DATE,
		[in].InTime,
		[out].OutTime
	--INTO dbo.condensedMergedDates
	FROM dbo.condensedFormattedIntime [in]
	JOIN dbo.condensedFormattedOuttime [out] ON [in].EMPLOYEEID = [out].EMPLOYEEID
		AND [in].DATE = [out].DATE;
END;

DROP TABLE dbo.condensedmergeddates;

SELECT *
FROM dbo.condensedmergeddates;

SELECT *
FROM DimEmployee
