/*CREATE TABLE DimLeaves(
LeaveKey INT identity(1,1),
LeaveId Varchar(2),
LeaveName Varchar(50),
ValidCount int
);*/

CREATE
	OR

ALTER PROCEDURE usp_PopulateDimLeaves
AS
BEGIN
	MERGE INTO HrAnalyticsProjectDW.dbo.DimLeaves tgt
	USING HrAnalyticsProject.dbo.LeaveTypes src
		ON tgt.LeaveId = src.LeaveId
	WHEN MATCHED
		THEN
			UPDATE
			SET tgt.LeaveName = src.LeaveName,
				tgt.ValidCount = isnull(src.ValidCount, 0)
	WHEN NOT MATCHED BY Target
		THEN
			INSERT
			VALUES (
				src.LeaveId,
				src.LeaveName,
				isnull(src.ValidCount, 0)
				);
END

EXEC usp_PopulateDimLeaves;


