CREATE DATABASE [21.06.2020]

USE [21.06.2020]


--Task 1 - 22/30 points
CREATE TABLE[Cities](
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	[CountryCode] CHAR(2) NOT NULL
)

CREATE TABLE[Hotels](
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	[CityId] INT FOREIGN KEY REFERENCES[Cities]([Id]) NOT NULL,
	[EmployeeCount] INT NOT NULL,
	[BaseRate] DECIMAL(18,2)
)

CREATE TABLE[Rooms](
	[Id] INT PRIMARY KEY IDENTITY,
	[Price] DECIMAL (18 ,2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	[Beds] INT NOT NULL,
	[HotelId] INT FOREIGN KEY REFERENCES[Hotels]([Id]) NOT NULL
)

CREATE TABLE[Trips](
	[Id] INT PRIMARY KEY IDENTITY,
	[RoomId] INT FOREIGN KEY REFERENCES[Rooms]([Id]) NOT NULL,
	[BookDate] DATE NOT NULL,
	[ArrivalDate] DATE NOT NULL,
	[ReturnDate] DATE NOT NULL,
	[CancelDate] DATE,
	CHECK([ArrivalDate] > [BookDate]),
	CHECK([ArrivalDate] < [ReturnDate])
)

CREATE TABLE[Accounts](
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(50) NOT NULL,
	[MiddleName] NVARCHAR(20),
	[LastName] NVARCHAR(50) NOT NULL,
	[CityId] INT FOREIGN KEY REFERENCES[Cities]([Id]) NOT NULL,
	[BirthDate] DATE NOT NULL,
	[Email] VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE[AccountsTrips](
	[AccountId] INT FOREIGN KEY REFERENCES[Accounts]([Id]) NOT NULL,
	[TripId] INT FOREIGN KEY REFERENCES[Trips]([Id]) NOT NULL,
	[Luggage] INT NOT NULL,
	PRIMARY KEY([AccountId],[TripId]),
	CHECK([Luggage] >= 0)
)


--Task 2
INSERT INTO [Accounts] ([FirstName],[MiddleName],[LastName],[CityId],[BirthDate],[Email])
VALUES
('John','Smith','Smith', 34 ,'1975-07-21','j_smith@gmail.com'),
('Gosho',NULL,'Petrov', 11 ,'1978-05-16','g_petrov@gmail.com'),
('Ivan','Petrovich','Pavlov', 59 ,'1849-09-26','i_pavlov@softuni.bg'),
('Friedrich','Wilhelm','Nietzsche', 2 ,'1844-10-15','f_nietzsche@softuni.bg')

INSERT INTO[Trips]([RoomId],[BookDate],[ArrivalDate],[ReturnDate],[CancelDate])
VALUES
(101,'2015-04-12','2015-04-14','2015-04-20','2015-02-02'),
(102,'2015-07-07','2015-07-15','2015-07-22','2015-04-29'),
(103,'2013-07-17','2013-07-23','2013-07-24',NULL),
(104,'2012-03-17','2012-03-31','2012-04-01','2012-01-10'),
(109,'2017-08-07','2017-08-28','2017-08-29',NULL)

--Tast 3
UPDATE [Rooms]
   SET [Price] *= 1.14
 WHERE [HotelId] IN(5,7,9)


 --Task 4
 DELETE FROM[AccountsTrips]
 WHERE [AccountId] = 47

 --Task 5
 SELECT a.[FirstName],
		a.[LastName],
		FORMAT(a.[BirthDate], 'MM-dd-yyyy'),
		c.[Name] AS [Hometown],
		a.[Email]
   FROM [Accounts] AS a
 LEFT JOIN[Cities] AS c
     ON  a.[CityId] = c.[Id]
  WHERE a.[Email] LIKE 'e%'
ORDER BY c.[Name]

--Task 6
SELECT c.[Name] AS [City],
	(SELECT COUNT(*) FROM [Hotels] h WHERE h.[CityId] = c.[Id]) AS Hotel 
FROM [Cities] AS c
WHERE (SELECT COUNT(*) FROM [Hotels] h WHERE h.[CityId] = c.[Id]) > 0
ORDER BY [Hotel] DESC , c.[Name]

--Task 7
SELECT a.[Id],
	   (a.FirstName + ' ' + a.LastName) AS [FullName],
	   MAX(DATEDIFF(DAY,t.[ArrivalDate],t.ReturnDate)) AS [LongestTrip],
	   MIN(DATEDIFF(DAY,t.[ArrivalDate],t.[ReturnDate])) AS [ShortestTrip]
FROM[Trips] AS t
LEFT JOIN[AccountsTrips] AS ac
ON t.Id = ac.TripId
LEFT JOIN [Accounts] AS a
ON ac.[AccountId] = a.[Id]
WHERE[CancelDate] IS NULL AND [MiddleName] IS NULL AND a.[Id] IS NOT NULL
GROUP BY a.[Id],a.[FirstName],a.[LastName]
ORDER BY [LongestTrip] DESC,[ShortestTrip]

--Task 8
SELECT TOP (10)
	c.[Id],
	c.[Name] AS [City],
	c.[CountryCode] AS [Country],
	COUNT(*) AS [Accounts]
FROM[Accounts] AS a
JOIN [Cities] as c
ON a.[CityId] = c.[Id]
GROUP BY c.[Id],c.[Name],c.[CountryCode]
ORDER BY [Accounts] DESC

--Task 9
SELECT AccountId,
	   Email,
	   ac.[Name],
	   COUNT(*) AS [Trips]
FROM [AccountsTrips] AS act
JOIN [Accounts] as a
ON act.[AccountId] = a.[Id]
JOIN [Cities] AS ac
ON a.[CityId] = ac.[Id]
JOIN [Trips] AS t
ON act.[TripId] = t.[Id]
JOIN [Rooms] AS r
ON t.[RoomId] = r.[Id]
JOIN [Hotels] AS h
ON r.[HotelId] = h.[Id]
JOIN [Cities] as hc
ON h.[CityId] = hc.[Id]
WHERE a.[CityId] = hc.[Id]
GROUP BY AccountId,Email,ac.[Name]
ORDER BY [Trips] DESC , AccountId

--Task 10
SELECT 
	t.[Id],
	(a.[FirstName] + ' ' + ISNULL(a.MiddleName + ' ' , '') + a.LastName) AS [FullName],
	ac.[Name] AS [From],
	hc.[Name] AS [To],
	CASE 
		WHEN CancelDate IS NULL THEN (CONVERT(VARCHAR ,DATEDIFF(DAY,ArrivalDate,ReturnDate)) + ' days')
		ELSE 'Canceled' END
	 AS [Duration]
FROM [AccountsTrips] AS act
JOIN [Accounts] AS a
ON act.[AccountId] = a.[Id]
JOIN [Cities] AS ac
ON a.[CityId] = ac.[Id]
JOIN [Trips] AS t
ON act.[TripId] = t.[Id]
JOIN [Rooms] AS r
ON t.[RoomId] = r.[Id]
JOIN [Hotels] AS h
ON r.[HotelId] = h.[Id]
JOIN [Cities] as hc
ON h.[CityId] = hc.[Id]
ORDER BY [FullName],[TripId]

--Task 11
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS NVARCHAR(MAX)
BEGIN
  DECLARE @RoomInfo VARCHAR(MAX) = (SELECT TOP (1) 'Room ' + CONVERT(VARCHAR,r.[Id]) + ': '+r.[Type]+' (' + CONVERT(VARCHAR ,r.[Beds])+ ' beds) - $' +  
							 CONVERT(VARCHAR, (h.[BaseRate] + r.Price) * @People)
						FROM [Rooms] AS r
						JOIN [Hotels] AS h
						  ON r.[HotelId] = h.[Id]
					    WHERE r.[Beds] >= @People AND h.[Id] = @HotelId AND
							NOT EXISTS (SELECT * FROM [Trips] t WHERE t.[RoomId] = r.[Id]
										AND t.[CancelDate] IS NULL
										AND @Date BETWEEN t.[ArrivalDate] AND t.[ReturnDate])  
					 ORDER BY (h.[BaseRate] + r.Price) * @People DESC)

		IF(@RoomInfo IS NULL)
		BEGIN
			RETURN 'No rooms available'
		END
	RETURN @RoomInfo
END
GO

--TASK 12
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
	DECLARE @TripHotelId INT = (SELECT r.[HotelId] FROM [Trips] AS t
							   JOIN [Rooms] AS r
							   ON t.[RoomId] = r.[Id]
							   WHERE t.[Id] = @TripId);
	DECLARE @TargetRoomHotelId INT = (SELECT r.[HotelId] FROM [Rooms] AS r
									  WHERE r.Id = @TargetRoomId);

	IF(@TripHotelId != @TargetRoomHotelId)
			THROW 50001 , 'Target room is in another hotel!' , 1

	DECLARE @TripAccount INT = (SELECT COUNT(*) FROM[AccountsTrips] WHERE TripId = @TripId);
	DECLARE @TargetRoomBed INT = (SELECT r.[Beds] FROM [Rooms] AS r
								  WHERE r.[Id] = @TargetRoomHotelId);
	IF(@TripAccount > @TargetRoomBed)
			THROW 50002 , 'Not enough beds in target room!' , 1
	UPDATE [Trips] SET [RoomId] = @TargetRoomId WHERE [Trips].[Id] = @TripId
GO


EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10

