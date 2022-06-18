USE [SoftUni]

--Part I – Queries for SoftUni Database
--Task 2

SELECT * FROM [Departments]

--Task 3
SELECT [Name]
  FROM [Departments]

--Task 4
SELECT [FirstName],[LastName],[Salary]
  FROM [Employees]

--Task 5
SELECT [FirstName],[MiddleName],[LastName]
  FROM [Employees]

--Task 6
SELECT CONCAT([FirstName],'.',[LastName],'@','softuni.bg')
	AS [FullEmailAddress]
  FROM [Employees]

--Task 7
SELECT DISTINCT [Salary]
  FROM [Employees]

--Task 8
SELECT * 
  FROM [Employees]
 WHERE [JobTitle] = 'Sales Representative'

--Task 9
SELECT [FirstName],[LastName],[JobTitle] 
  FROM [Employees]
 WHERE [Salary] BETWEEN 20000 AND 30000

--Task 10
--Variant 1
SELECT [FirstName]+' '+[MiddleName]+' '+[LastName]
	AS [Full Name]
  FROM [Employees]
 WHERE [Salary]=25000 OR [Salary]=14000 OR [Salary]=12500 OR [Salary]=23600

 --Variant 2

 SELECT CONCAT(e.[FirstName],' ',e.[MiddleName],' ',e.[LastName]) AS [Full Name]
   FROM [Employees] AS e
  WHERE e.[Salary] IN (25000,14000,12500,23600)


--Task 11
SELECT [FirstName],
	   [LastName]
  FROM [Employees]
 WHERE [ManagerID] IS NULL

--Task 12
  SELECT [FirstName],[LastName],[Salary]
    FROM [Employees]
   WHERE [Salary] > 50000
ORDER BY [Salary] DESC

--Task 13
  SELECT TOP (5) [FirstName],[LastName]
	FROM [Employees]
ORDER BY [Salary] DESC

--Task 14
SELECT [FirstName],[LastName]
  FROM [Employees]
 WHERE [DepartmentID] != 4

 --Task 15
  SELECT *
    FROM [Employees]
ORDER BY [Salary] DESC,[FirstName] ASC,[LastName] DESC,[MiddleName] ASC

--Task 16
GO
CREATE VIEW [V_EmployeesSalaries]
AS
	 SELECT [FirstName],[LastName],[Salary]
	   FROM [Employees]

--Task 17
GO
CREATE VIEW [V_EmployeeNameJobTitle] 
AS
SELECT ([FirstName]  + ' ' +  ISNULL([MiddleName], '')+ ' ' + [LastName]) 
	AS [Fullname],
	   [JobTitle]
  FROM [Employees]

--Task 18
SELECT DISTINCT [JobTitle]
  FROM [Employees]

--Task 19
  SELECT TOP (10) * 
    FROM [Projects]
ORDER BY [StartDate],[Name]

--Task 20
  SELECT TOP(7) [FirstName],[LastName],[HireDate]
    FROM [Employees]
ORDER BY [HireDate] DESC

--Task 21
UPDATE [Employees]
   SET [Salary] += [Salary] * 0.12
 WHERE [DepartmentID] IN (1,2,4,11)

 SELECT [Salary]
   FROM [Employees]

--Part II – Queries for Geography Database
--Task 22
USE [Geography]

  SELECT [PeakName]
    FROM [Peaks]
ORDER BY [PeakName]

--Task 23
SELECT TOP (30) [CountryName],[Population] 
	  FROM [Countries]
	 WHERE [ContinentCode] = 'EU'
  ORDER BY [Population] DESC,[CountryName]

--Task 24
  SELECT [CountryName],[CountryCode],
		CASE
			WHEN [CurrencyCode] = 'EUR' THEN 'Euro'
			ELSE 'Not Euro'
		END AS [Currency]
	FROM [Countries]
ORDER BY [CountryName]

--Part III – Queries for Diablo Database
--Task 25
USE [Diablo]

  SELECT [Name]
    FROM [Characters]
ORDER BY [Name]