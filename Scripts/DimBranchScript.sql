/*CREATE TABLE dbo.dimBranch(
	BranchKey int identity(1,1) primary key,
    BranchId varchar(15),
	CountryName varchar(255),
	StateName varchar(255),
    CityName VARCHAR(255),
    Latitude Decimal(15, 10),
    Longitude Decimal(15, 10)
);*/

begin CREATE
OR ALTER PROCEDURE usp_PopulateDimBranch as begin MERGE INTO HrAnalyticsProjectDW.dbo.DimBranch tgt USING (
    SELECT
        DISTINCT substring(City, 1, 2) + substring(latitude, 1, 2) + substring(longitude, 1, 2) [BranchKey], Country, State, City, -- Key for DimBranch
        Latitude,
        Longitude
    FROM
        HrAnalyticsProject.dbo.MainStage src
) src on tgt.[BranchId] = src.[BranchKey] --key for dimbranch
WHEN MATCHED THEN
UPDATE
SET
    tgt.[CountryName] = src.Country,
	tgt.StateName = src.State,
	tgt.CityName = src.City,
	tgt.Latitude = src.Latitude,
	tgt.Longitude = src.Longitude
    WHEN NOT MATCHED by TARGET THEN
INSERT
VALUES
    (
	src.BranchKey,
    src.Country,
	src.State,
	src.City,
	src.Latitude,
	src.Longitude
    );

end exec usp_PopulateDimBranch;

end;

SELECT
    *
FROM
    DimBranch;
