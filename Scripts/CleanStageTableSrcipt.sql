CREATE
	OR

ALTER PROCEDURE usp_UpdateMainStage
AS
BEGIN
	UPDATE MainStage
	SET Age = 0
	WHERE Age = 'NA';

	UPDATE MainStage
	SET DistanceFromHome = 0
	WHERE DistanceFromHome = 'NA';

	UPDATE MainStage
	SET Education = 0
	WHERE Education = 'NA';

	UPDATE MainStage
	SET JobLevel = 0
	WHERE JobLevel = 'NA';

	UPDATE MainStage
	SET MonthlyIncome = 0
	WHERE MonthlyIncome = 'NA';

	UPDATE MainStage
	SET NumCompaniesWorked = 0
	WHERE NumCompaniesWorked = 'NA';

	UPDATE MainStage
	SET PercentSalaryHike = 0
	WHERE PercentSalaryHike = 'NA';

	UPDATE MainStage
	SET StandardHours = 0
	WHERE StandardHours = 'NA';

	UPDATE MainStage
	SET StockOptionLevel = 0
	WHERE StockOptionLevel = 'NA';

	UPDATE MainStage
	SET TotalWorkingYears = 0
	WHERE TotalWorkingYears = 'NA';

	UPDATE MainStage
	SET TrainingTimesLastYear = 0
	WHERE TrainingTimesLastYear = 'NA';

	UPDATE MainStage
	SET YearsAtCompany = 0
	WHERE YearsAtCompany = 'NA';

	UPDATE MainStage
	SET YearsSinceLastPromotion = 0
	WHERE YearsSinceLastPromotion = 'NA';

	UPDATE MainStage
	SET YearsWithCurrManager = 0
	WHERE YearsWithCurrManager = 'NA';
END

EXEC usp_UpdateMainStage;
