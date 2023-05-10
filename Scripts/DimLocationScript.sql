/*CREATE TABLE DimLocation(
	LocationKey Int identity(1,1),
	LocationId varchar(50),
	EnglishCountryName varchar(50),
	EnglishStateName varchar(50),
	EnglishCityName varchar(50)
);*/

Create
or alter procedure usp_PopulateDimLocation as begin Merge HrAnalyticsProjectDw.dbo.DimLocation tgt Using(Select Distinct Country, State, City, left(City,4)+'-'+left(State, 3)+left(Country,2) as Id from HrAnalyticsProject.dbo.EmployeesLocation )src on tgt.LocationId = src.Id
When Matched Then
update
set
	tgt.EnglishCountryName = src.Country,
	tgt.EnglishStateName = src.State,
	tgt.EnglishCityName = src.City
	When Not Matched By Target then
Insert
values
(       src.Id,
		src.Country,
		src.State,
		src.City
	);

end;

exec usp_populateDimLocation
select
	*
from
	DimLocation
Select * from DimDepartment;