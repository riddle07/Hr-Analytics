/*CREATE TABLE DimRecruitment (
	EmployeeKey INT,
	isActive INT,
	RecruiterId INT,
	RecruitmentSource VARCHAR(50),
	Education VARCHAR(255),
	EducationYears INT,
	WorkExperience INT,
	NumCompaniesWorked INT,
	HireYear INT
	);*/

CREATE
	OR

ALTER PROCEDURE usp_PopulateDimRecruitment
AS
BEGIN
	MERGE INTO HrAnalyticsProjectDw.dbo.DimRecruitment tgt
	USING (
		SELECT A.employeeID,
			A.RecruiterIdId,
			A.RecruitmentSo,
			B.EducationField,
			B.Education,
			B.TotalWorkingYears,
			B.NumCompaniesWorked,
			B.Attrition,
			A.YearsSinceHire
		FROM HrAnalyticsProject.dbo.recruitmentsource A
		JOIN HrAnalyticsProject.dbo.MainStage b ON A.employeeId = B.employeeId
		) src
		ON tgt.EmployeeKey = src.EmployeeId
	WHEN MATCHED
		THEN
			UPDATE
			SET tgt.Education = src.Education,
				tgt.isActive = (
					CASE 
						WHEN src.attrition = 'YES'
							THEN 0
						ELSE 1
						END
					),
				tgt.RecruiterId = src.RecruiterIdId,
				tgt.RecruitmentSource = src.RecruitmentSo,
				tgt.EducationYears = src.Education,
				tgt.WorkExperience = src.TotalWorkingYears,
				tgt.NumCompaniesWorked = src.NumCompaniesWorked,
				tgt.HireYear = (
					(
						SELECT cast(max(CalendarYear) AS INT) - src.YearsSinceHire
						FROM DimDate
						)
					)
	WHEN NOT MATCHED BY target
		THEN
			INSERT
			VALUES (
				src.employeeID,
				(
					CASE 
						WHEN src.attrition = 'YES'
							THEN 0
						ELSE 1
						END
					),
				src.RecruiterIdId,
				src.RecruitmentSo,
				src.EducationField,
				src.Education,
				src.TotalWorkingYears,
				src.NumCompaniesWorked,
				(
					(
						SELECT cast(max(CalendarYear) AS INT) - src.YearsSinceHire
						FROM DimDate
						)
					)
				);
END;

EXEC usp_populateDimRecruitment;
