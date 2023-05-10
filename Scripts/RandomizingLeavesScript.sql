--Script To Randomly Assign Leaves to the employees
SELECT employeeId,
	DATE,
	CASE 
		WHEN row_number() OVER (
				PARTITION BY employeeid ORDER BY newid()
				) <= 10
			THEN 1
		ELSE 2
		END AS LeaveKey
FROM (
	SELECT employeeid,
		DATE,
		row_number() OVER (
			PARTITION BY employeeId ORDER BY DATE
			) rno
	FROM condensedMergedDates
	WHERE (
			DATE NOT IN (
				SELECT DATE
				FROM Holidays
				)
			)
		AND InTime = 'NA'
		AND OutTime = 'NA'
	) T
WHERE rno < 20
ORDER BY DATE

--
SELECT employeeId,
	DATE,
	3
FROM (
	SELECT employeeid,
		DATE,
		row_number() OVER (
			PARTITION BY employeeId ORDER BY DATE
			) rno
	FROM condensedMergedDates
	WHERE (
			DATE NOT IN (
				SELECT DATE
				FROM Holidays
				)
			)
		AND InTime = 'NA'
		AND OutTime = 'NA'
	) T
WHERE rno >= 20
ORDER BY DATE

--WorkFrom Home Script
SELECT *
FROM condensedMergedDates
WHERE InTime <> 'NA'
	AND OutTime <> 'NA' CreateTbale

SELECT A.employeeId,
	A.DATE,
	CASE 
		WHEN c.leavekey IS NULL
			THEN 0
		ELSE 1
		END AS LeaveStatus,
	isnull(c.leaveKey, 0) AS LeaveStatus,
	B.WFHStatus,
	A.InTime,
	A.OutTime
FROM (
	condensedMergedDates A LEFT JOIN WFHStatus B ON A.EMPLOYEEId = B.employeeid
		AND B.DATE = a.DATE
	)
LEFT JOIN Leaves C ON C.employeeid = a.employeeid
	AND c.DATE = a.DATE
