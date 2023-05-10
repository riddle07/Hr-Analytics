/*CREATE TABLE DimRLS (
	RoleKey INT,
	DepartmentKey INT,
	RLSRole VARCHAR(20),
	EmployeeKey INT,
	Email VARCHAR(100)
	);*/

CREATE
	OR

ALTER PROCEDURE usp_PopulateDimRLS
AS
BEGIN
	MERGE INTO HrAnalyticsProjectDW.dbo.DimRLS tgt
	USING HrAnalyticsProject.dbo.Hierarchy src
		ON tgt.RoleKey = (
				SELECT RoleKey
				FROM DimJobRole
				WHERE DimJobRole.RoleName = src.RoleName
					AND DimjobRole.DepartmentKey = (
						SELECT DepartmentKey
						FROM DimDepartment
						WHERE DimDepartment.DepartmentName = src.DepartmentName
						)
				)
			AND tgt.RLSRole = src.RlSRole
	WHEN MATCHED
		THEN
			UPDATE
			SET tgt.EmployeeKey = src.EmployeeId,
				tgt.Email = src.UserName
	WHEN NOT MATCHED BY Target
		THEN
			INSERT
			VALUES (
				(
					SELECT RoleKey
					FROM DimJobRole
					WHERE DimJobRole.RoleName = src.RoleName
						AND DimjobRole.DepartmentKey = (
							SELECT DepartmentKey
							FROM DimDepartment
							WHERE DimDepartment.DepartmentName = src.DepartmentName
							)
					),
				(
					SELECT DepartmentKey
					FROM DimDepartment
					WHERE DimDepartment.DepartmentName = src.DepartmentName
					),
				src.RLSRole,
				src.EmployeeId,
				src.UserName
				);
END;

EXEC usp_PopulateDimRLS;
