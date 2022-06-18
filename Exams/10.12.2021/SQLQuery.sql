CREATE DATABASE [10.12.2021]

USE [10.12.2021]

--Task 1
CREATE TABLE [Passengers] (
	[Id] INT PRIMARY KEY IDENTITY,
	[FullName] VARCHAR(100) NOT NULL UNIQUE,
	[Email] VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE[Pilots] (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(30) NOT NULL UNIQUE,
	[LastName] VARCHAR(30) NOT NULL UNIQUE,
	[Age] TINYINT NOT NULL CHECK([Age] BETWEEN 21 AND 62),
	[Rating] FLOAT(53) CHECK([Rating] >= 0.0 AND [Rating] <= 10.0)

)

CREATE TABLE[AircraftTypes](
	[Id] INT PRIMARY KEY IDENTITY,
	[TypeName] VARCHAR(30) NOT NULL UNIQUE
)


CREATE TABLE[Aircraft] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Manufacturer] VARCHAR(25) NOT NULL,
	[Model] VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	[FlightHours] INT,
	[Condition] CHAR(1) NOT NULL,
	[TypeId] INT FOREIGN KEY REFERENCES[AircraftTypes] ([Id]) NOT NULL
)

CREATE TABLE[PilotsAircraft](
	[AircraftId] INT FOREIGN KEY REFERENCES [Aircraft]([Id]) NOT NULL,
	[PilotId] INT FOREIGN KEY REFERENCES [Pilots]([Id]) NOT NULL,
	PRIMARY KEY([AircraftId],[PilotId])
)

CREATE TABLE[Airports](
	[Id] INT PRIMARY KEY IDENTITY,
	[AirportName] VARCHAR(70) NOT NULL UNIQUE,
	[Country]VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE[FlightDestinations](
	[Id] INT PRIMARY KEY IDENTITY,
	[AirportId] INT FOREIGN KEY REFERENCES [Airports]([Id]) NOT NULL,
	[Start] DATETIME NOT NULL,
	[AircraftId] INT FOREIGN KEY REFERENCES [Aircraft]([Id]) NOT NULL,
	[PassengerId] INT FOREIGN KEY REFERENCES [Passengers]([Id]) NOT NULL,
	[TicketPrice] DECIMAL(18,2) DEFAULT(15.00) NOT NULL
)

--Task 2
DECLARE @PilotId INT = 5

WHILE @PilotId <=15
BEGIN
INSERT INTO Passengers VALUES
((SELECT CONCAT(FirstName, ' ', LastName) FROM Pilots WHERE Id = @PilotId), (SELECT CONCAT(FirstName,LastName,'@gmail.com') FROM Pilots WHERE Id=@PilotId))
SET @PilotId += 1
END

--Task 3
UPDATE[Aircraft]
SET [Condition] = 'A' WHERE ([Condition]= 'C' OR [Condition] ='B') AND ([FlightHours] IS NULL OR [FlightHours] <= 100) AND [Year] >= 2013

--TASK 4
DELETE[Passengers] WHERE(LEN([FullName]) <= 10)

--Task 5
SELECT a.[Manufacturer],
	   a.[Model],
	   a.[FlightHours],
	   a.[Condition]
  FROM [Aircraft] AS a
ORDER BY a.[FlightHours] DESC

--Task 6
SELECT  p.[FirstName],
		p.[LastName],
		a.[Manufacturer],
		a.[Model],
		a.[FlightHours]
FROM[PilotsAircraft] AS pa
JOIN [Aircraft] AS a
ON pa.[AircraftId] = a.[Id]
JOIN [Pilots] AS p
ON pa.[PilotId] = p.[Id]
WHERE a.[FlightHours] IS NOT NULL AND a.[FlightHours] < 304
ORDER BY a.[FlightHours] DESC, p.[FirstName]

--Task 7
SELECT TOP(20) 
		fd.[Id] AS [DestinationID],
		fd.[Start],
		p.[FullName],
		a.[AirportName],
		fd.[TicketPrice]
FROM[FlightDestinations] AS fd
JOIN [Airports] AS a
ON fd.[AirportId] = a.[Id]
JOIN [Passengers] AS p
ON fd.[PassengerId] = p.[Id]
WHERE DATEPART(DAY,fd.[Start]) % 2 = 0
ORDER BY fd.[TicketPrice] DESC, a.[AirportName]

--Task 8
SELECT * 
	FROM(SELECT a.[Id] AS [AircraftId],
				a.[Manufacturer],
				a.[FlightHours],
				COUNT(*) AS [FlightDestinationsCount],
				ROUND(AVG(fd.[TicketPrice]),2) AS [AvgPrice]
			FROM[Aircraft] AS a
		JOIN[FlightDestinations] AS fd
		ON a.[Id] = fd.[AircraftId]
		GROUP BY a.[Id],a.[Manufacturer],a.[FlightHours]
		) AS [Query]
WHERE [FlightDestinationsCount] > 1
ORDER BY [FlightDestinationsCount] DESC,[AircraftId]

--Task 9
SELECT * 
FROM (
		SELECT p.[FullName],
			   COUNT(a.[Id]) AS [CountOfAircraft],
			   SUM(fd.[TicketPrice]) AS [TotalPayed]
		FROM[Passengers] AS p
		JOIN[FlightDestinations] AS fd
		ON p.[Id] = fd.[PassengerId]
		JOIN[Aircraft] AS a
		ON fd.[AircraftId] = a.[Id]
		WHERE p.[FullName] LIKE '_a%'
		GROUP BY p.[Id] ,p.[FullName]
	  ) AS [NextQuery]
WHERE [CountOfAircraft] > 1
ORDER BY [FullName]

--Task 10
SELECT ap.[AirportName],
	   fd.[Start] AS [DayTime],
	   fd.[TicketPrice],
	   p.[FullName],
	   ac.[Manufacturer],
	   ac.[Model]
FROM[FlightDestinations] AS fd
JOIN[Airports] AS ap
ON fd.[AirportId] = ap.[Id]
JOIN[Aircraft] AS ac
ON fd.[AircraftId] = ac.[Id]
JOIN[Passengers] AS p
ON fd.[PassengerId] = p.[Id]
WHERE (DATEPART(HOUR , fd.[Start]) BETWEEN 6 AND 20) AND fd.[TicketPrice] > 2500
ORDER BY ac.[Model]

--Task 11
CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(fd.[Id]) 
			  FROM [Passengers] AS p
			  JOIN [FlightDestinations] AS fd
			    ON p.[Id] = fd.[PassengerId]
			 WHERE p.Email = @email)
END
GO


CREATE PROC usp_SearchByAirportName(@airportName VARCHAR(70))
AS
BEGIN
	SELECT 
	       a.[AirportName],
	       p.[FullName],
		 CASE
			WHEN fd.[TicketPrice] <= 400 THEN 'Low'
			WHEN fd.[TicketPrice] BETWEEN 401 AND 1500 THEN 'Medium'
			WHEN fd.[TicketPrice] > 1500 THEN 'High' END AS [LevelOfTickerPrice],
	       ac.[Manufacturer],
	       ac.[Condition],
	       act.[TypeName]
     FROM [Airports] AS a
     JOIN [FlightDestinations] AS fd
       ON a.[Id] = fd.[AirportId]
     JOIN [Passengers] AS p
       ON fd.[PassengerId] = p.[Id]
     JOIN [Aircraft] AS ac
       ON fd.[AircraftId] = ac.Id
     JOIN [AircraftTypes] AS act
       ON ac.[TypeId] = act.[Id]
    WHERE a.[AirportName] = @airportName
 ORDER BY ac.[Manufacturer],p.[FullName]
END
