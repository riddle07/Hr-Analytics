/*CREATE TABLE dbo.FactAttendance (
	EmployeeKey INT,
	DepartmentKey INT,
	RoleKey INT,
	DateKey INT,
	BranchKey VARCHAR(255),
	LeaveStatus INT,
	LeaveKey INT,
	WFHStatus INT,
	InTime VARCHAR(255),
	OutTime VARCHAR(255),
	TotalWorkFromHomeTakenTillNow INT
	)*/
BEGIN
	CREATE
		OR

	ALTER PROCEDURE usp_PopulateFactAttendence
	AS
	BEGIN
		MERGE INTO HrAnalyticsProjectDw.dbo.FactAttendance tgt
		USING (
			SELECT A.employeeId,
				A.DATE,
				CASE 
					WHEN c.leavekey IS NULL
						THEN 0
					ELSE 1
					END AS LeaveStatus,
				isnull(c.leaveKey, 0) AS LeaveKey,
				isNUll(B.WFHStatus, 0) WFHStatus,
				A.InTime,
				A.OutTime,
				sum(isnull(cast(B.WFHStatus AS INT), 0)) OVER (
					PARTITION BY A.employeeid ORDER BY A.DATE
					) WFHTaken
			FROM (
				HrAnalyticsProject.dbo.condensedMergedDates A LEFT JOIN HrAnalyticsProject.dbo.WFHStatus B ON A.EMPLOYEEId = B.employeeid
					AND B.DATE = a.DATE
				)
			LEFT JOIN HrAnalyticsProject.dbo.Leaves C ON C.employeeid = a.employeeid
				AND c.DATE = a.DATE
			) src
			ON tgt.DateKey = cast(replace(cast(src.DATE AS VARCHAR(255)), '-', '') AS INT)
				AND tgt.employeeKey = src.EmployeeId
		WHEN MATCHED
			THEN
				UPDATE
				SET tgt.DepartmentKey = (
						SELECT DepartmentKey
						FROM HrAnalyticsProjectDw.dbo.DimDepartment D
						WHERE DepartmentName = (
								SELECT Department
								FROM HrAnalyticsProject.dbo.MAINSTAGE M
								WHERE M.EmployeeId = src.employeeId
								)
						),
					tgt.RoleKey = (
						SELECT RoleKey
						FROM HrAnalyticsProjectDw.dbo.DimJobRole D
						WHERE RoleName = (
								SELECT JobRole
								FROM HrAnalyticsProject.dbo.MainStage M
								WHERE src.EmployeeId = M.EmployeeId
								)
							AND DepartmentKey = (
								SELECT DepartmentKey
								FROM HrAnalyticsProjectDw.dbo.DimDepartment D
								WHERE DepartmentName = (
										SELECT Department
										FROM HrAnalyticsProject.dbo.MAINSTAGE M
										WHERE M.EmployeeID = src.employeeId
										)
								)
						),
					tgt.DateKey = cast(replace(cast(src.DATE AS VARCHAR(255)), '-', '') AS INT),
					tgt.BranchKey = (
						SELECT BranchKey
						FROM HrAnalyticsProjectDw.dbo.DimBranch D
						WHERE CityName = (
								SELECT city
								FROM HrAnalyticsProject.dbo.MAINSTAGE M
								WHERE M.EmployeeID = src.employeeid
								)
						),
					tgt.InTime = src.InTime,
					tgt.OutTime = src.OutTime,
					tgt.LeaveStatus = src.LeaveStatus,
					tgt.LeaveKey = src.LeaveKey,
					tgt.WFHStatus = src.WFHStatus,
					tgt.TotalWorkFromHomeTakenTillNow = src.WFHTaken
		WHEN NOT MATCHED BY Target
			THEN
				INSERT
				VALUES (
					src.employeeId,
					(
						SELECT DepartmentKey
						FROM HrAnalyticsProjectDw.dbo.DimDepartment D
						WHERE DepartmentName = (
								SELECT Department
								FROM HrAnalyticsProject.dbo.MAINSTAGE M
								WHERE M.EmployeeID = src.employeeId
								)
						),
					(
						SELECT RoleKey
						FROM HrAnalyticsProjectDw.dbo.DimJobRole D
						WHERE RoleName = (
								SELECT JobRole
								FROM HrAnalyticsProject.dbo.MainStage M
								WHERE src.EmployeeId = M.EmployeeId
								)
							AND DepartmentKey = (
								SELECT DepartmentKey
								FROM HrAnalyticsProjectDw.dbo.DimDepartment D
								WHERE DepartmentName = (
										SELECT Department
										FROM HrAnalyticsProject.dbo.MAINSTAGE M
										WHERE M.EmployeeID = src.employeeId
										)
								)
						),
					cast(replace(cast(src.DATE AS VARCHAR(255)), '-', '') AS INT),
					(
						SELECT BranchKey
						FROM HrAnalyticsProjectDw.dbo.DimBranch D
						WHERE CityName = (
								SELECT city
								FROM HrAnalyticsProject.dbo.MAINSTAGE M
								WHERE M.EmployeeID = src.employeeId
								)
						),
					src.LeaveStatus,
					src.LeaveKey,
					src.WFHStatus,
					src.InTime,
					src.OutTime,
					src.WFHTaken
					);
	END

	EXEC usp_PopulateFactAttendence;END

	--SELECT *
	--FROM FactAttendance;
