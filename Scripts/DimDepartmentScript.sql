/*CREATE TABLE dbo.DimDepartment (
	Departmentkey INT PRIMARY KEY identity(1001, 1),
	DepartmentId VARCHAR(10),
	DepartmentName VARCHAR(255),
	DepartmentManagerKey INT
	);*/

BEGIN
	CREATE
		OR

	ALTER PROCEDURE usp_PopulateDimDepartment
	AS
	BEGIN
		MERGE INTO HrAnalyticsProjectDw.dbo.DimDepartment tgt
		USING (
			SELECT DISTINCT Department
			FROM HrAnalyticsProject.dbo.MainStage
			) src
			ON tgt.DepartmentName = src.Department
		WHEN MATCHED
			THEN
				UPDATE
				SET tgt.DepartmentName = src.Department,
					DepartmentId = left(src.Department, 2),
					tgt.DepartmentManagerKey = 					(
						SELECT EmployeeId
						FROM (
							SELECT Department,
								EmployeeId,
								Row_Number() OVER (
									PARTITION BY Department ORDER BY TotalWorkingYears,
										JObLevel,
										MonthlyIncome
									) Rno
							FROM HrAnalyticsProject.dbo.MainStage
							) T
						WHERE T.Rno = 1
							AND T.Department = src.Department
						)
		WHEN NOT MATCHED BY TARGET
			THEN
				INSERT
				VALUES (
					left(src.Department, 2),
					src.Department,
					(
						SELECT EmployeeId
						FROM (
							SELECT Department,
								EmployeeId,
								Row_Number() OVER (
									PARTITION BY Department ORDER BY TotalWorkingYears,
										JObLevel,
										MonthlyIncome
									) Rno
							FROM HrAnalyticsProject.dbo.MainStage
							) T
						WHERE T.Rno = 1
							AND T.Department = src.Department
						)
					);
	END

	EXEC usp_PopulateDimDepartment;END;