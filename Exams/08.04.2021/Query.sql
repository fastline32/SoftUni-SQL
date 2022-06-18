CREATE DATABASE [08.04.2021]

USE [08.04.2021]

--Task 1
CREATE TABLE [Users] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Username] VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(50) NOT NULL,
	[Name] VARCHAR(50),
	[Birthdate] DATETIME2,
	[Age] INT CHECK([Age] BETWEEN 14 AND 110),
	[Email] VARCHAR(50) NOT NULL
)

CREATE TABLE [Departments] (
	 [Id] INT PRIMARY KEY IDENTITY,
	 [Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [Employees] (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(25),
	[LastName] VARCHAR(25),
	[Birthdate] DATETIME2,
	[Age] INT CHECK([Age] BETWEEN 18 AND 110),
	[DepartmentId] INT FOREIGN KEY REFERENCES [Departments]([Id])
)

CREATE TABLE [Categories] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[DepartmentId] INT FOREIGN KEY REFERENCES [Departments]([Id])
)

CREATE TABLE [Status] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Label] VARCHAR(30) NOT NULL
)

CREATE TABLE [Reports] (
	[Id] INT PRIMARY KEY IDENTITY,
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories]([Id]) NOT NULL,
	[StatusId] INT FOREIGN KEY REFERENCES [Status]([Id]) NOT NULL,
	[OpenDate] DATETIME2 NOT NULL,
	[CloseDate] DATETIME2,
	[Description] VARCHAR(200) NOT NULL,
	[UserId] INT FOREIGN KEY REFERENCES [Users]([Id]) NOT NULL,
	[EmployeeId] INT FOREIGN KEY REFERENCES [Employees]([Id])
)

--Task 2
INSERT INTO [Employees] ([FirstName],[LastName],[Birthdate],[DepartmentId])
VALUES
('Marlo','O''''Malley','1958-9-21',1),
('Niki','Stanaghan','1969-11-26',4),
('Ayrton','Senna','1960-03-21',9),
('Ronnie','Peterson','1944-02-14',9),
('Giovanna','Amati','1959-07-20',5)

INSERT INTO [Reports] ([CategoryId],[StatusId],[OpenDate],[CloseDate],[Description],[UserId],[EmployeeId])
VALUES
(1,	1,'2017-04-13',NULL,'Stuck Road on Str.133',6,2),
(6,	3,'2015-09-05','2015-12-06','Charity trail running',3,5),
(14,2,'2015-09-07',NULL,'Falling bricks on Str.58',5,2),
(4,	3,'2017-07-03','2017-07-06','Cut off streetlight on Str.11',1,1)


--Task 3
DECLARE @CurrentDate DATETIME2 = GETDATE()
UPDATE[Reports]
SET [CloseDate] = @CurrentDate
WHERE [CloseDate] IS NULL

--Task 4
DELETE[Reports]
WHERE [StatusId] = 4

--Task 5
SELECT r.[Description],
	   FORMAT(r.[OpenDate],'dd-MM-yyyy') AS [OpenDate]
FROM [Reports] AS r
WHERE [EmployeeId] IS NULL
ORDER BY r.[OpenDate] ASC,[Description]

--Task 6
SELECT r.[Description],
	   c.[Name] AS [CategoryName]
FROM [Reports] AS r
JOIN [Categories] AS c
ON r.[CategoryId] = c.[Id]
ORDER BY r.[Description],c.[Name]

--Task 7
SELECT TOP(5)  c.[Name] AS [CategoryName],
		COUNT(*) AS [ReportsNumber]
FROM [Reports] AS r
LEFT JOIN [Categories] AS c
ON r.[CategoryId] = c.[Id]
GROUP BY c.[Id],c.[Name]
ORDER BY [ReportsNumber] DESC, [CategoryName]

--Task 8
SELECT u.[Username],
	   c.[Name] AS [CategoryName]
FROM [Users] AS u
JOIN [Reports] AS r
ON u.[Id] = r.[UserId]
JOIN [Categories] AS c
ON r.[CategoryId] = c.[Id]
WHERE ((DATEPART(DAY,u.[Birthdate]) = DATEPART(DAY,r.[OpenDate])) AND (DATEPART(MONTH,u.[Birthdate]) = DATEPART(MONTH,r.[OpenDate])))
ORDER BY u.[Username],c.[Name]

--Task 9
SELECT CONCAT(e.[FirstName],' ',e.[LastName]) AS [FullName],
      COUNT(u.Id) AS [UserCount]
FROM [Employees] AS e
LEFT JOIN [Reports] AS r
ON e.[Id] = r.[EmployeeId]
LEFT JOIN [Users] AS u
ON r.[UserId] = u.[Id]
GROUP BY e.[Id],e.[FirstName],e.[LastName]
ORDER BY [UserCount] DESC,[FullName]

--Task 10
SELECT ISNULL((e.[FirstName] + ' ' + e.[LastName]),'None') AS [Employee],
       ISNULL(d.[Name],'None') AS [Department],
	   c.[Name] AS [Category],
	   r.[Description],
	   FORMAT(r.[OpenDate],'dd.MM.yyyy') AS [OpenDate],
	   s.[Label] AS [Status],
	   u.[Name] AS [User]
FROM [Reports] AS r
JOIN [Categories] AS c
ON r.[CategoryId] = c.[Id]
JOIN [Status] AS s 
ON r.[StatusId] = s.[Id]
JOIN [Users] AS u
ON r.[UserId] = u.[Id]
LEFT JOIN [Employees] AS e
ON r.[EmployeeId] = e.[Id]
LEFT JOIN [Departments] AS d
ON e.[DepartmentId] = d.[Id]
ORDER BY e.[FirstName] DESC,e.[LastName] DESC,[Department],[Category],[Description],[OpenDate],[Status],[User]

--Task 11
GO
CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN
	RETURN (SELECT DATEDIFF(HOUR,r.[OpenDate],r.[CloseDate]) 
			  FROM Reports as r
			 WHERE r.[OpenDate] = @StartDate AND r.[CloseDate] = @EndDate)
END
GO

--Task 12

GO
CREATE PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN
	DECLARE @EmployeeDepartmentId INT = (SELECT [DepartmentId]
                                           FROM [Employees]
					    				   WHERE [Id] = @EmployeeId)
	DECLARE @ReportDepartmentId INT = (SELECT c.[DepartmentId]
										 FROM [Reports] AS r
										 LEFT JOIN [Categories] AS c
										   ON r.[CategoryId] = c.[Id]
										WHERE r.[Id] = @ReportId)
	IF(@EmployeeDepartmentId <> @ReportDepartmentId)
		THROW 50011,'Employee doesn''t belong to the appropriate department!',1

	UPDATE [Reports]
	SET [EmployeeId] = @EmployeeId
	WHERE [Reports].[Id] = @ReportId
END
GO

SELECT * FROM [Reports] AS r
LEFT JOIN [Categories] AS c
ON r.[CategoryId] = c.[Id]
