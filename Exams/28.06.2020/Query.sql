CREATE DATABASE [28.06.2020]

USE[28.06.2020]
USE[08.04.2021]

--Task 1

CREATE TABLE [Planets] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE [Spaceports] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PlanetId] INT FOREIGN KEY REFERENCES [Planets]([Id]) NOT NULL
)

CREATE TABLE [Spaceships] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[Manufacturer] VARCHAR(30) NOT NULL,
	[LightSpeedRate] INT DEFAULT(0)
)

CREATE TABLE [Colonists] (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(20) NOT NULL,
	[LastName] VARCHAR(20) NOT NULL,
	[Ucn] VARCHAR(10) NOT NULL UNIQUE,
	[BirthDate] DATE NOT NULL
)

CREATE TABLE [Journeys] (
	[Id] INT PRIMARY KEY IDENTITY,
	[JourneyStart] DATETIME NOT NULL,
	[JourneyEnd] DATETIME NOT NULL,
	[Purpose] VARCHAR(11) NOT NULL CHECK([Purpose] IN ('Medical','Technical','Educational','Military')),
	[DestinationSpaceportId] INT FOREIGN KEY REFERENCES [Spaceports]([Id]) NOT NULL,
	[SpaceshipId] INT FOREIGN KEY REFERENCES [Spaceships]([Id]) NOT NULL
)

CREATE TABLE [TravelCards] (
	[Id] INT PRIMARY KEY IDENTITY,
	[CardNumber] CHAR(10) NOT NULL UNIQUE,
	[JobDuringJourney] VARCHAR(8) CHECK([JobDuringJourney] in ('Pilot','Engineer','Trooper','Cleaner','Cook')),
	[ColonistId] INT FOREIGN KEY REFERENCES [Colonists]([Id]) NOT NULL,
	[JourneyId] INT FOREIGN KEY REFERENCES [Journeys]([Id]) NOT NULL
)

--Task 2
INSERT INTO [Planets] ([Name])
VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO [Spaceships] ([Name],[Manufacturer],[LightSpeedRate])
VALUES
('Golf','VW',3),
('WakaWaka','Wakanda',4),
('Falcon9','SpaceX',1),
('Bed','Vidolov',6)

--Task 3
UPDATE[Spaceships]
SET[LightSpeedRate] += 1
WHERE [Id] BETWEEN 8 AND 12

--Task 4
DELETE[TravelCards]
WHERE[JourneyId] BETWEEN 1 AND 3
DELETE[Journeys]
WHERE [Id] BETWEEN 1 AND 3

--Task 5
SELECT [Id],
	   FORMAT(JourneyStart,'dd/MM/yyyy') AS [JourneyStart],
	   FORMAT(JourneyEnd,'dd/MM/yyyy') AS [JourneyEnd]
FROM [Journeys]
WHERE [Purpose] = 'Military'
ORDER BY [JourneyStart]

--Task 6
SELECT  c.[Id],
		(c.[FirstName] + ' ' + c.[LastName]) AS [full_name]
FROM [Colonists] AS c
JOIN [TravelCards] AS tc
ON c.Id = tc.[ColonistId]
WHERE tc.[JobDuringJourney] = 'Pilot'
ORDER BY c.[Id]

--Task 7
SELECT  COUNT(*) AS [count]
FROM [Colonists] AS c
JOIN [TravelCards] AS tc
ON c.Id = tc.[ColonistId]
WHERE JobDuringJourney = 'Engineer'
GROUP BY [JobDuringJourney]

--Task 8
SELECT s.[Name],
	   s.[Manufacturer]
FROM [Spaceships] AS s
JOIN [Journeys] AS j
ON s.[Id] = j.[SpaceshipId]
JOIN [TravelCards] AS tc
ON j.[Id] = tc.[JourneyId]
LEFT JOIN [Colonists] AS c
ON tc.[ColonistId] = c.[Id] 
WHERE JobDuringJourney = 'Pilot' AND (c.[BirthDate] > '01/01/1989' AND c.[BirthDate] < '01/01/2019')
GROUP BY s.[Name],s.[Manufacturer]

--Task 9
SELECT p.[Name] AS [PlanetName],
	COUNT(j.[Id]) AS [JourneysCount]
FROM [Planets] AS p
JOIN [Spaceports] AS s 
ON p.[Id] = s.[PlanetId]
JOIN [Journeys] AS j
ON s.[Id] = j.[DestinationSpaceportId]
GROUP BY p.[Name]
ORDER BY [JourneysCount] DESC,[PlanetName]

--Task 10
SELECT * FROM
             (SELECT tc.JobDuringJourney,
             CONCAT (FirstName, ' ', LastName) AS [FullName] ,
             DENSE_RANK() OVER(PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate) AS [JobRank]
                FROM Colonists AS c
               JOIN TravelCards AS tc ON c.Id = tc.ColonistId) AS temp
WHERE temp.[JobRank] = 2

--Task 11

GO
CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR(30))
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(*) FROM [Planets] AS p
              JOIN [Spaceports] AS s
				ON p.[Id] = s.[PlanetId]
			  JOIN [Journeys] AS j
				ON s.[Id] = j.[DestinationSpaceportId]
			  JOIN [TravelCards] AS tc
			    ON j.[Id] = tc.[JourneyId]
			 WHERE p.[Name] = @PlanetName)
END
GO

--Task 12

CREATE PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN
	DECLARE @JourneyPurpose VARCHAR(11) = (SELECT [Purpose] 
										 FROM [Journeys] 
										WHERE [Id] = @JourneyId)

	IF(@JourneyPurpose IS NULL)
		THROW 50011,'The journey does not exist!',1
	IF(@JourneyPurpose = @NewPurpose)
		THROW 50012,'You cannot change the purpose!',1
	UPDATE [Journeys]
	   SET [Purpose] = @NewPurpose
	 WHERE [Id] = @JourneyId
END
GO

