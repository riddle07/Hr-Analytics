/*CREATE TABLE dbo.DimJobRole (
	RoleKey INT PRIMARY KEY identity(1601, 1),
	RoleId VARCHAR(10),
	RoleName VARCHAR(255),
	DepartmentKey INT,
	RoleLeadKey INT
	);*/

BEGIN
	CREATE
		OR

	ALTER PROCEDURE usp_PopulateDimRole
	AS
	BEGIN
		MERGE INTO HrAnalyticsProjectDw.dbo.DimJobRole tgt
		USING (
			SELECT DISTINCT DEPARTMENT,
				JobRole
			FROM HrAnalyticsProject.dbo.MainStage
			) src
			ON tgt.RoleName = src.JobRole
				AND tgt.DepartmentKey = (
					SELECT DepartmentKey
					FROM DimDepartment
					WHERE DimDepartment.DepartmentName = src.Department
					)
		WHEN MATCHED
			THEN
				UPDATE
				SET tgt.RoleName = src.JobRole,
					tgt.RoleId = left(src.Department, 2) + '-' + left(src.jobrole, 2),
					tgt.RoleLeadKey = (
						SELECT EMPLOYEEID
						FROM (
							SELECT DEPARTMENT,
								JOBROLE,
								EMPLOYEEID,
								ROW_NUMBER() OVER (
									PARTITION BY DEPARTMENT,
									JOBROLE ORDER BY TOTALWORKINGYEARS,
										JOBLEVEL,
										MONTHLYINCOME
									) RNO
							FROM HrAnalyticsProject.dbo.MAINSTAGE
							) t
						WHERE T.RNO = 1
							AND T.Department = src.Department
							AND T.JobRole = src.JobRole
						)
		WHEN NOT MATCHED
			THEN
				INSERT
				VALUES (
					left(src.Department, 2) + '-' + left(src.jobrole, 2),
					src.JobRole,
					(
						SELECT DepartmentKey
						FROM DimDepartment
						WHERE DimDepartment.DepartmentName = src.Department
						),
					(
						SELECT EMPLOYEEID
						FROM (
							SELECT DEPARTMENT,
								JOBROLE,
								EMPLOYEEID,
								ROW_NUMBER() OVER (
									PARTITION BY DEPARTMENT,
									JOBROLE ORDER BY TOTALWORKINGYEARS,
										JOBLEVEL,
										MONTHLYINCOME
									) RNO
							FROM HrAnalyticsProject.dbo.MAINSTAGE
							) t
						WHERE T.RNO = 1
							AND T.Department = src.Department
							AND T.JobRole = src.JobRole
						)
					);
	END

	EXEC usp_PopulateDimRole;END
