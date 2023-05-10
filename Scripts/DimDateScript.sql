/*CREATE TABLE DBO.DimDate (
	DateKey INT PRIMARY KEY,
	FullDateAlternateKey DATE,
	DayNumberofWeek INT,
	EnglishDayNameOfWeek VARCHAR(20),
	DayNumberofMonth INT,
	DayNumberOfYear INT,
	EnglishMonthName VARCHAR(20),
	MonthNumberOfYear INT,
	CalendarQuarter INT,
	CalendarYear INT,
	)*/

BEGIN
	CREATE
		OR

	ALTER PROCEDURE usp_PopulateDimDate
	AS
	BEGIN
		DECLARE @TableOfDate TABLE (CurrentDate DATE);
		DECLARE @MinDate DATE;
		DECLARE @MaxDate DATE;

		SELECT @MinDate = MIN(DATE)
		FROM HrAnalyticsProject.[dbo].[condensedMergedDates];

		SELECT @MaxDate = MAX(DATE)
		FROM HrAnalyticsProject.[dbo].[condensedMergedDates];

		--print @MinDate;
		--print @MaxDate;
		DECLARE @BeginDate DATE = @MinDate;
		DECLARE @EndDate DATE = @MaxDate;

		WHILE (@BeginDate <= @EndDate)
		BEGIN --print @BeginDate;
			INSERT INTO @TableOfDate
			VALUES (@BeginDate);

			SET @BeginDate = DATEADD(DAY, 1, @BeginDate);
		END;

		--select replace(cast(CurrentDate as varchar(255)), '-', '') from @tableOfDate;
		MERGE INTO HrAnalyticsProjectDw.dbo.DimDate tgt
		USING (
			SELECT CurrentDate,
				cast(replace(cast(CurrentDate AS VARCHAR(255)), '-', '') As INT) AS DateKey
			FROM @tableOfDate
			) src
			ON tgt.DateKey = src.DateKey
		WHEN MATCHED
			THEN
				UPDATE
				SET tgt.FullDateAlternateKey = src.CurrentDate,
					tgt.DayNumberofWeek = datepart(weekday, src.CurrentDate),
					tgt.EnglishDayNameOfWeek = dateName(weekday, src.CurrentDate),
					tgt.DayNumberofMonth = day(src.CurrentDate),
					tgt.DayNumberOfYear = datename(dayofyear, src.CurrentDate),
					tgt.EnglishMonthName = datename(month, src.currentDate),
					tgt.MonthNumberOfYear = datepart(month, src.CurrentDate),
					tgt.CalendarQuarter = datepart(quarter, src.CurrentDate),
					tgt.CalendarYear = year(src.currentDate)
		WHEN NOT MATCHED BY target
			THEN
				INSERT
				VALUES (
					src.DateKey,
					src.CurrentDate,
					datepart(weekday, src.CurrentDate),
					dateName(weekday, src.CurrentDate),
					day(src.CurrentDate),
					datename(dayofyear, src.CurrentDate),
					datename(month, src.currentDate),
					datepart(month, src.CurrentDate),
					datepart(quarter, src.CurrentDate),
					year(src.currentDate)
					);
	END;

	EXEC usp_PopulateDimDate;END;

