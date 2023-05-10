/*CREATE TABLE dbo.DimHoliday (
	DateKey VARCHAR(50),
	DATE DATE,
	HolidayName VARCHAR(255)
	);*/

BEGIN
	CREATE
		OR

	ALTER PROCEDURE usp_PopulateDimHoliday
	AS
	BEGIN
		MERGE INTO HrAnalyticsProjectDw.dbo.DimHoliday tgt
		USING HrAnalyticsProject.dbo.Holidays src
			ON tgt.DATE = src.DATE
		WHEN MATCHED
			THEN
				UPDATE
				SET tgt.HolidayName = src.HolidayName
		WHEN NOT MATCHED BY Target
			THEN
				INSERT
				VALUES (
					(replace(cast(src.DATE AS VARCHAR(255)), '-', '')),
					src.DATE,
					src.HolidayName
					);
	END;

	EXEC usp_PopulateDimHoliday;END;