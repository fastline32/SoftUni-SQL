CREATE DATABASE [19.06.2022]

USE [19.06.2022]
USE master
--Task 1
CREATE TABLE [Owners] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PhoneNumber] VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50)
)

CREATE TABLE [AnimalTypes] (
	[Id] INT PRIMARY KEY IDENTITY,
	[AnimalType] VARCHAR(30) NOT NULL
)


CREATE TABLE [Cages] (
	[Id] INT PRIMARY KEY IDENTITY,
	[AnimalTypeId] INT FOREIGN KEY REFERENCES [AnimalTypes]([Id]) NOT NULL
)

CREATE TABLE [Animals] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	[BirthDate] DATE NOT NULL,
	[OwnerId] INT FOREIGN KEY REFERENCES [Owners]([Id]),
	[AnimalTypeId] INT FOREIGN KEY REFERENCES [AnimalTypes]([Id]) NOT NULL
)

CREATE TABLE [AnimalsCages] (
	[CageId] INT FOREIGN KEY REFERENCES [Cages]([Id]),
	[AnimalId] INT FOREIGN KEY REFERENCES [Animals]([Id]),
	PRIMARY KEY([CageId],[AnimalId])
)

CREATE TABLE [VolunteersDepartments] (
	[Id] INT PRIMARY KEY IDENTITY,
	[DepartmentName] VARCHAR(30) NOT NULL
)

CREATE TABLE [Volunteers] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PhoneNumber] VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	[AnimalId] INT FOREIGN KEY REFERENCES [Animals]([Id]),
	[DepartmentId] INT FOREIGN KEY REFERENCES [VolunteersDepartments]([Id]) NOT NULL
)

--Task 2
INSERT INTO [Volunteers] ([Name],[PhoneNumber],[Address],[AnimalId],[DepartmentId])
VALUES
('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15 , 1),
('Dimitur Stoev','0877564223',null,42,4),
('Kalina Evtimova','0896321112','Silistra, 21 Breza str.',9,7),
('Stoyan Tomov','0898564100','Montana, 1 Bor str.',18,8),
('Boryana Mileva','0888112233',null,31,5)

INSERT INTO [Animals] ([Name],[BirthDate],[OwnerId],[AnimalTypeId])
VALUES
('Giraffe','2018-09-21',21,1),
('Harpy Eagle','2015-04-17',15,3),
('Hamadryas Baboon','2017-11-02',null,1),
('Tuatara','2021-06-30',2,4)

--Task 3
UPDATE[Animals]
SET[OwnerId] = 4
WHERE [OwnerId] IS NULL

--Task 4

DELETE [Volunteers]
WHERE [DepartmentId] = 2

DELETE[VolunteersDepartments]
WHERE [Id] = 2

--Task 5
  SELECT [Name],
		 [PhoneNumber],
		 [Address],
		 [AnimalId],
		 [DepartmentId]
    FROM [Volunteers]
ORDER BY [Name],[AnimalId],DepartmentId

--Task 6
  SELECT a.[Name],
	     ant.[AnimalType],
	     FORMAT(a.[BirthDate],'dd.MM.yyyy') AS [BirthDate]
    FROM [Animals] AS a
    JOIN [AnimalTypes] AS ant
      ON a.[AnimalTypeId] = ant.[Id]
ORDER BY a.[Name]

--Task 7
  SELECT TOP(5) o.[Name],
	     COUNT(a.Id) AS [CountOfAnimals]
    FROM [Animals] AS a
    JOIN [Owners] AS o
      ON a.[OwnerId] = o.[Id]
GROUP BY o.[Id],o.[Name]
ORDER BY [CountOfAnimals] DESC,o.[Name]

--Task 8
  SELECT CONCAT(o.[Name],'-',a.[Name]) AS [OwnersAnimals],
         o.[PhoneNumber],
	     ac.[CageId]
    FROM [Animals] AS a
    JOIN [AnimalTypes] AS [at]
      ON a.[AnimalTypeId] = [at].Id
    JOIN [Owners] AS o
      ON a.[OwnerId] = o.Id
    JOIN [AnimalsCages] AS ac
      ON a.[Id] = ac.AnimalId
   WHERE [at].AnimalType = 'Mammals'
ORDER BY o.[Name],a.[Name] DESC

--Task 9
  SELECT v.[Name],
         v.[PhoneNumber],
	     SUBSTRING(v.[Address],CHARINDEX(',',v.[Address])+1,LEN(v.[Address])-CHARINDEX(',',v.[Address])) AS [Address]
    FROM [Volunteers] AS v
    JOIN [VolunteersDepartments] AS vd
      ON v.[DepartmentId] = vd.[Id]
   WHERE vd.[Id] = 2 AND v.[Address] LIKE '%Sofia%'
ORDER BY v.[Name]

--Task 10
  SELECT a.[Name],
	     YEAR(a.[BirthDate]) AS [BirthYear],
	     ant.[AnimalType]
    FROM [Animals] AS a
    JOIN [AnimalTypes] AS ant
      ON a.[AnimalTypeId] = ant.[Id]
   WHERE [OwnerId] IS NULL AND ant.[Id] != 3 AND a.[BirthDate] > '2018/01/01'
ORDER BY a.[Name]

--Task 11
GO
CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(v.[Id]) 
			  FROM [VolunteersDepartments] AS vd
              JOIN [Volunteers] AS v
                ON vd.[Id] = v.[DepartmentId]
             WHERE vd.[DepartmentName] = @VolunteersDepartment)
END

GO

--Task 12
CREATE PROC usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
BEGIN 
	SELECT a.[Name],
	       ISNULL(o.[Name],'For adoption') AS [OwnersName]
      FROM [Animals] AS a 
      LEFT JOIN [Owners] AS o 
        ON a.[OwnerId] = o.[Id]
     WHERE a.[Name] = @AnimalName
END
