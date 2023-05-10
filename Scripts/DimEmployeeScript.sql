CREATE TABLE dbo.DimEmployee (
	EmployeeKey INT PRIMARY KEY,
	FirstName varchar(50),
	MiddleName varchar(50),
	LastName varchar(50),
	isActive INT,
	Gender VARCHAR(255),
	WorkExperience INT,
	StandardWorkHours INT,
	DistanceFromHome INT,
	JobLevel INT,
	MonthlyIncome INT,
	PercentageSalaryHike INT,
	StockOptionLevel INT,
	YearsAtPresentCompany INT,
	YearsSinceLastPromotion INT,
	YearsWithCurrentManager INT,
	JobInvolvement INT,
	PerformanceRating INT,
	EnvironmentSatisfaction INT,
	JobSatisfaction INT,
	WorkLifeBalance INT,
	DepartmentKey INT,
	RoleKey INT,
	BranchKey VARCHAR(255),
	LocationKey INT
	);

	Drop Table DimEmployee

	ALTER TABLE dbo.DimEmployee ADD DistanceFromHome INT

	BEGIN
		CREATE
			OR

		ALTER PROCEDURE usp_PopulateDimEmployee
		AS
		BEGIN
			MERGE INTO HrAnalyticsProjectDW.dbo.DimEmployee tgt
			USING HrAnalyticsProject.dbo.MainStage src
				ON tgt.EmployeeKey = cast(src.EmployeeID AS INT)
			WHEN MATCHED
				THEN
					UPDATE
					SET tgt.gender = src.gender,
						tgt.isActive = (
							CASE 
								WHEN src.Attrition = 'YES'
									THEN 0
								ELSE 1
								END
							),
						tgt.WorkExperience = src.TotalWorkingYears,
						tgt.StandardWorkHours = src.StandardHours,
						tgt.DistanceFromHome = src.DistanceFromHome,
						tgt.JobLevel = src.JobLevel,
						tgt.MonthlyIncome = src.MonthlyIncome,
						tgt.PercentageSalaryHike = src.PercentSalaryHike,
						tgt.StockOptionLevel = src.StockOptionLevel,
						tgt.YearsAtPresentCompany = src.YearsAtCompany,
						tgt.YearsSinceLastPromotion = src.YearsSinceLastPromotion,
						tgt.YearsWithCurrentManager = src.YearsWithCurrManager,
						tgt.JobInvolvement = (
							SELECT iif(Job_Involvement = 'NA', 0, Job_Involvement)
							FROM HrAnalyticsProject.dbo.manager_survey_data ref
							WHERE ref.Employee_Key = src.employeeId
							),
						tgt.PerformanceRating = (
							SELECT iif(Performance_Rating = 'NA', 0, Performance_Rating)
							FROM HrAnalyticsProject.dbo.manager_survey_data ref
							WHERE ref.Employee_Key = src.employeeId
							),
						tgt.EnvironmentSatisfaction = (
							SELECT CASE 
									WHEN EnvironmentSatisfaction = 'NA'
										THEN 0
									ELSE EnvironmentSatisfaction
									END
							FROM HrAnalyticsProject.dbo.employee_survey_data ref
							WHERE ref.EmployeeId = src.employeeId
							),
						tgt.JobSatisfaction = (
							SELECT CASE 
									WHEN JobSatisfaction = 'NA'
										THEN 0
									ELSE JobSatisfaction
									END
							FROM HrAnalyticsProject.dbo.employee_survey_data ref
							WHERE ref.EmployeeId = src.employeeId
							),
						tgt.WorkLifeBalance = (
							SELECT CASE 
									WHEN WorkLifeBalance = 'NA'
										THEN 0
									ELSE WorkLifeBalance
									END
							FROM HrAnalyticsProject.dbo.employee_survey_data ref
							WHERE ref.EmployeeId = src.employeeId
							),
						tgt.FirstName = (Select FirstName from HrAnalyticsProject.dbo.names where EmployeeId = src.employeeId),
						tgt.MiddleName = (Select MiddleName from HrAnalyticsProject.dbo.names where EmployeeId = src.employeeId),
						tgt.LastName = (Select LastName from HrAnalyticsProject.dbo.names where EmployeeId = src.employeeId)
			WHEN NOT MATCHED BY TARGET
				THEN
					INSERT
					VALUES (
						cast(src.EmployeeId AS INT),
						(Select FirstName from HrAnalyticsProject.dbo.names where EmployeeId = src.employeeId),
						(Select MiddleName from HrAnalyticsProject.dbo.names where EmployeeId = src.employeeId),
						(Select LastName from HrAnalyticsProject.dbo.names where EmployeeId = src.employeeId),
						(
							CASE 
								WHEN src.Attrition = 'YES'
									THEN 0
								ELSE 1
								END
							),
						src.gender,
						src.TotalWorkingYears,
						src.StandardHours,
						src.DistanceFromHome,
						src.JobLevel,
						src.MonthlyIncome,
						src.PercentSalaryHike,
						src.StockOptionLevel,
						src.YearsAtCompany,
						src.YearsSinceLastPromotion,
						src.YearsWithCurrManager,
						(
							SELECT iif(Job_Involvement = 'NA', 0, Job_Involvement)
							FROM HrAnalyticsProject.dbo.manager_survey_data ref
							WHERE ref.Employee_Key = src.employeeId
							),
						(
							SELECT iif(Performance_Rating = 'NA', 0, Performance_Rating)
							FROM HrAnalyticsProject.dbo.manager_survey_data ref
							WHERE ref.Employee_Key = src.employeeId
							),
						(
							SELECT CASE 
									WHEN EnvironmentSatisfaction = 'NA'
										THEN 0
									ELSE EnvironmentSatisfaction
									END
							FROM HrAnalyticsProject.dbo.employee_survey_data ref
							WHERE ref.EmployeeId = src.employeeId
							),
						(
							SELECT CASE 
									WHEN JobSatisfaction = 'NA'
										THEN 0
									ELSE JobSatisfaction
									END
							FROM HrAnalyticsProject.dbo.employee_survey_data ref
							WHERE ref.EmployeeId = src.employeeId
							),
						(
							SELECT CASE 
									WHEN WorkLifeBalance = 'NA'
										THEN 0
									ELSE WorkLifeBalance
									END
							FROM HrAnalyticsProject.dbo.employee_survey_data ref
							WHERE ref.EmployeeId = src.employeeId
							),
						(
							SELECT DepartmentKey
							FROM DimDepartment
							WHERE DimDepartment.DepartmentName = src.Department
							),
						(
							SELECT RoleKey
							FROM DimJobRole
							WHERE DimJobRole.RoleName = src.JobRole
								AND DimJobRole.DepartmentKey = (
									SELECT DepartmentKey
									FROM DimDepartment
									WHERE DepartmentName = src.Department
									)
							),
						(
							SELECT BranchKey
							FROM DimBranch
							WHERE DimBranch.BranchId = substring(src.City, 1, 2) + substring(src.latitude, 1, 2) + substring(src.longitude, 1, 2)
							),
						(
							SELECT TOP 1 LocationKey
							FROM DimLocation A
							WHERE A.LocationId IN (
									SELECT left(City, 4) + '-' + left(STATE, 3) + left(Country, 2)
									FROM HrAnalyticsProject.dbo.EmployeesLocation X
									WHERE X.employeeId = src.EmployeeId
									)
							)
						);
		END

		EXEC usp_PopulateDimEmployee;END;

		Select * from dimemployee;