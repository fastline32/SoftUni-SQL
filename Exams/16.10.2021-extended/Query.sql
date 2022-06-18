CREATE DATABASE CigarShop

USE CigarShop

--Taks 1
CREATE TABLE[Sizes](
	[Id] INT PRIMARY KEY IDENTITY,
	[Length] INT NOT NULL CHECK([Length] BETWEEN 10 AND 25),
	[RingRange] DECIMAL (3,2) NOT NULL CHECK([RingRange] BETWEEN 1.5 AND 7.5)
)

CREATE TABLE[Tastes](
	[Id] INT PRIMARY KEY IDENTITY,
	[TasteType] VARCHAR(20) NOT NULL,
	[TasteStrength] VARCHAR(15) NOT NULL,
	[ImageURL] NVARCHAR(100) NOT NULL
)

CREATE TABLE[Brands](
	[Id] INT PRIMARY KEY IDENTITY,
	[BrandName] VARCHAR(30) NOT NULL UNIQUE,
	[BrandDescription] VARCHAR(MAX)
)

CREATE TABLE[Cigars](
	[Id] INT PRIMARY KEY IDENTITY,
	[CigarName] VARCHAR(80) NOT NULL,
	[BrandId] INT FOREIGN KEY REFERENCES [Brands]([Id]) NOT NULL,
	[TastId] INT FOREIGN KEY REFERENCES [Tastes]([Id]) NOT NULL,
	[SizeId] INT FOREIGN KEY REFERENCES [Sizes]([Id]) NOT NULL,
	[PriceForSingleCigar] DECIMAL(18,2) NOT NULL,
	[ImageURL] NVARCHAR(100) NOT NULL
)

CREATE TABLE[Addresses](
	[Id] INT PRIMARY KEY IDENTITY,
	[Town] VARCHAR(30) NOT NULL,
	[Country] NVARCHAR(30) NOT NULL,
	[Streat] NVARCHAR(100) NOT NULL,
	[ZIP] VARCHAR(20) NOT NULL,
)

CREATE TABLE[Clients](
	[Id] INT PrimaRY KEY IDENTITY,
	[FirstName] NVARCHAR(30) NOT NULL,
	[LastName] NVARCHAR(30) NOT NULL,
	[Email] NVARCHAR(50) NOT NULL,
	[AddressId] INT FOREIGN KEY REFERENCES [Addresses]([Id])
)

CREATE TABLE[ClientsCigars](
	[ClientId] INT FOREIGN KEY REFERENCES [Clients]([Id]),
	[CigarId] INT FOREIGN KEY REFERENCES [Cigars]([Id]),
	PRIMARY KEY ([ClientId],[CigarId])
)

--Task 2
INSERT INTO [Cigars] ([CigarName],[BrandId],[TastId],[SizeId],[PriceForSingleCigar],[ImageURL])
VALUES
('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg'),
('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg'),
('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50, 'hoyo-du-maire-stick_17.jpg'),
('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00, 'hoyo-de-san-juan-stick_20.jpg'),
('TRINIDAD COLONIALES', 2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg')

INSERT INTO[Addresses]([Town],[Country],[Streat],[ZIP])
VALUES
('Sofia','Bulgaria','18 Bul. Vasil levski','1000'),
('Athens','Greece','4342 McDonald Avenue','10435'),
('Zagreb','Croatia','4333 Lauren Drive','10000')

--Task 3
UPDATE [Cigars]
SET [PriceForSingleCigar] *= 1.2
SELECT * FROM[Cigars] AS c
JOIN [Tastes] AS t
ON c.[TastId] = t.[Id]
WHERE t.[TasteType] = 'Spicy'
UPDATE[Brands]
SET[BrandDescription] = 'New description'
WHERE[BrandDescription] IS NULL

--Task 4

DELETE [Clients]
WHERE[AddressId] IN (SELECT [Id] FROM[Addresses]
WHERE [Country] LIKE'C%')

DELETE[Addresses]
WHERE [Country] LIKE'C%'


--Task 5
SELECT [CigarName],
	   [PriceForSingleCigar],
	   [ImageURL]
  FROM [Cigars]
ORDER BY [PriceForSingleCigar],[CigarName] DESC

--Task 6
SELECT c.[Id],
	   c.[CigarName],
	   c.[PriceForSingleCigar],
	   t.[TasteType],
	   t.[TasteStrength]
FROM [Cigars] AS c
JOIN [Tastes] AS t
ON c.TastId = t.[Id]
WHERE t.[TasteType] IN ('Earthy','Woody')
ORDER BY c.[PriceForSingleCigar] DESC

--Task 7
SELECT c.[Id],
	    CONCAT(c.[FirstName],' ',c.[LastName]) AS [ClientName],
		c.[Email]
FROM[Clients] AS c
LEFT JOIN [ClientsCigars] AS ac
ON c.[Id] = ac.[ClientId]
WHERE ac.ClientId IS NULL
ORDER BY [ClientName]

--Task 8
SELECT TOP(5) c.[CigarName],
	   c.[PriceForSingleCigar],
	   c.[ImageURL]
FROM [Cigars] AS c
LEFT JOIN [Sizes] AS s
ON c.[SizeId] = s.[Id]
WHERE s.[Length] > 12 AND (c.CigarName LIKE '%ci%' OR c.PriceForSingleCigar > 50) AND s.[RingRange] > 2.55
ORDER BY c.[CigarName],c.[PriceForSingleCigar] DESC

--Problem 9
SELECT NewQuery.FullName,
	   NewQuery.Country,
	   NewQuery.ZIP,
	   CONCAT('$',MAX(NewQuery.CigarPrice)) AS [CigarPrice]
FROM 
        (SELECT 
		(c.[FirstName] + ' ' + c.[LastName]) AS [FullName],
		a.[Country],
		a.[ZIP],
		ci.[PriceForSingleCigar] AS [CigarPrice]
		FROM [Clients] AS c
		JOIN[Addresses] AS a
		ON c.[AddressId] = a.[Id]
		JOIN [ClientsCigars] AS cc
		ON c.[Id] = cc.[ClientId]
		JOIN [Cigars] AS ci
		ON cc.[CigarId] = ci.[Id]
		WHERE a.[ZIP] NOT LIKE '%[A-Z]%') AS [NewQuery]
GROUP BY FullName,Country,ZIP
ORDER BY FullName

SELECT  cl.[LastName],
		AVG(s.[Length]) AS [CiagrLength],
		CEILING(AVG(s.[RingRange])) AS [CiagrRingRange]
  FROM [Clients] AS cl
LEFT JOIN [ClientsCigars] AS cc
ON cl.Id = cc.[ClientId]
LEFT JOIN [Cigars] AS c
ON cc.[CigarId] = c.[Id]
LEFT JOIN [Sizes] AS s
ON c.[SizeId] = s.[Id]
WHERE cc.[ClientId] IS NOT NULL
GROUP BY cl.[LastName]
ORDER BY AVG(s.[Length]) DESC


--Task 11
CREATE FUNCTION udf_ClientWithCigars (@name NVARCHAR(30))
RETURNS INT
BEGIN
	DECLARE @clientId INT= (SELECT [ID] FROM [Clients] AS cl
							WHERE cl.[FirstName] =@name);

	RETURN (
			SELECT COUNT(cc.CigarId)
			FROM [ClientsCigars] AS cc
			JOIN [Clients] AS c
			ON cc.ClientId = c.[Id]
			WHERE c.[Id] = @clientId
			)
END
GO

--Task 12
CREATE PROC usp_SearchByTaste(@taste VARCHAR(20))
AS
BEGIN
	DECLARE @TasteId INT = (SELECT [Id] 
							  FROM [Tastes]
							 WHERE [Tastes].[TasteType] = @taste);

	SELECT c.CigarName,
	       CONCAT('$',(c.PriceForSingleCigar)) AS [Price],
		   t.[TasteType],
	       b.[BrandName],
	       CONCAT(s.[Length],' ','cm') AS [CigarLenght],
	       CONCAT(s.[RingRange],' ','cm') AS [CigarRingRange]
	  FROM [Cigars] AS c
	  JOIN [Tastes] AS t
		ON c.[TastId] = t.[Id]
	  JOIN [Sizes] AS s
		ON c.[SizeId] = s.[Id]
	  JOIN [Brands] AS b
		ON c.[BrandId] = b.[Id]
	 WHERE t.[Id] = @TasteId
  ORDER BY [CigarLenght],[CigarRingRange] DESC

END
GO

SELECT c.CigarName,
	   CONCAT('$',(c.PriceForSingleCigar)) AS [Price],
	   t.[TasteType],
	   b.[BrandName],
	   CONCAT(s.[Length],'cm') AS [CigarLenght],
	   CONCAT(s.[RingRange],'cm') AS [CigarRingRange]
FROM [Cigars] AS c
JOIN [Tastes] AS t
ON c.[TastId] = t.[Id]
JOIN [Sizes] AS s
ON c.[SizeId] = s.[Id]
JOIN [Brands] AS b
ON c.[BrandId] = b.[Id]
WHERE t.[Id] = 3
ORDER BY [CigarLenght],[CigarRingRange] DESC