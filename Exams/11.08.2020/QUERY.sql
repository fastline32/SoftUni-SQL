CREATE DATABASE [11.08.2020]

USE [11.08.2020]

--Task 1
CREATE TABLE [Countries](
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE [Customers](
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(25),
	[LastName] NVARCHAR(25),
	[Gender] CHAR(1) CHECK([Gender] = 'M' OR [Gender] = 'F'),
	[Age] INT,
	[PhoneNumber] CHAR(10) CHECK(LEN([PhoneNumber]) = 10),
	[CountryId] INT FOREIGN KEY REFERENCES [Countries]([Id])
)

CREATE TABLE [Products](
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) UNIQUE,
	[Description] NVARCHAR(250),
	[Recipe] NVARCHAR(MAX),
	[Price] DECIMAL(18,2) CHECK([Price] >= 0)
)

CREATE TABLE [Feedbacks] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Description] NVARCHAR(255),
	[Rate]DECIMAL(4,2) CHECK([Rate] BETWEEN 0 AND 10),
	[ProductId] INT FOREIGN KEY REFERENCES [Products]([Id]),
	[CustomerId] INT FOREIGN KEY REFERENCES [Customers]([Id])
)

CREATE TABLE [Distributors](
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) UNIQUE,
	[AddressText] NVARCHAR(30),
	[Summary]NVARCHAR(200),
	[CountryId] INT FOREIGN KEY REFERENCES [Countries]([Id])
)

CREATE TABLE [Ingredients] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30),
	[Description] NVARCHAR(200),
	[OriginCountryId] INT FOREIGN KEY REFERENCES[Countries]([Id]),
	[DistributorId] INT FOREIGN KEY REFERENCES [Distributors]([Id])
)

CREATE TABLE [ProductsIngredients](
	[ProductId] INT FOREIGN KEY REFERENCES [Products]([Id]),
	[IngredientId] INT FOREIGN KEY REFERENCES [Ingredients]([Id]),
	PRIMARY KEY([ProductId],[IngredientId])
)

--Task 2
INSERT INTO [Distributors] ([Name],[CountryId],[AddressText],[Summary])
VALUES
('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO [Customers] ([FirstName],[LastName],[Age],[Gender],[PhoneNumber],CountryId)
VALUES
('Francoise','Rautenstrauch',15,'M','0195698399',5),
('Kendra','Loud',22,'F','0063631526',11),
('Lourdes','Bauswell',50,'M','0139037043',8),
('Hannah','Edmison',18,'F','0043343686',1),
('Tom','Loeza',31,'M','0144876096',23),
('Queenie','Kramarczyk',30,'F','0064215793',29),
('Hiu','Portaro',25,'M','0068277755',16),
('Josefa','Opitz',43,'F','0197887645',17)


--Task 3
UPDATE[Ingredients]
SET[DistributorId] = 35
WHERE[Name] IN ('Bay Leaf','Paprika','Poppy')
UPDATE[Ingredients]
SET[OriginCountryId]=14
WHERE[OriginCountryId]=8

--Task 4
DELETE[Feedbacks]
WHERE [CustomerId] = 14 OR [ProductId] = 5

--Task 5
  SELECT [Name],
	     [Price],
	     [Description]
    FROM [Products]
ORDER BY [Price] DESC,[Name]

--Task 6
  SELECT f.[ProductId],
		 f.[Rate],
		 f.[Description],
		 c.[Id],
		 c.[Age],
		 c.[Gender]
    FROM [Feedbacks] AS f
    LEFT JOIN [Customers] AS c
      ON f.[CustomerId] = c.[Id]
   WHERE f.[Rate] < 5.0
ORDER BY f.[ProductId] DESC,f.[Rate]

--Task 7
SELECT CONCAT(c.[FirstName],' ',c.[LastName]) AS [CustomerName],
	   c.[PhoneNumber],
	   c.[Gender]
FROM [Customers] AS c
LEFT JOIN[Feedbacks] AS f
ON c.[Id] = f.[CustomerId]
WHERE f.[CustomerId] IS NULL
ORDER BY c.[Id]

--Task 8
SELECT cus.[FirstName],
	   cus.[Age],
	   cus.[PhoneNumber]
FROM [Customers] AS cus
JOIN [Countries] AS cou
ON cus.[CountryId] = cou.[Id]
WHERE (cus.[Age] >= 21 AND cus.[FirstName] LIKE '%an%') OR (cus.[PhoneNumber] LIKE '%38' AND cou.[Name] != 'Greece')
ORDER BY cus.[FirstName],cus.[Age] DESC

--Task 9
SELECT d.[Name],
	   i.[Name],
	   pr.[Name],
	   AVG(f.Rate) AS [AverageRate]
FROM [Ingredients] AS i
LEFT JOIN [Distributors] AS d
ON i.[DistributorId] = d.[Id]
JOIN [ProductsIngredients] AS pri
ON i.[Id] = pri.[IngredientId]
JOIN [Products] AS pr
ON pri.ProductId = pr.[Id]
JOIN [Feedbacks] AS f
ON pr.[Id] = f.[ProductId]
GROUP BY i.[Id],d.[Name],i.[Name],pr.[Name]
HAVING (AVG(f.Rate) BETWEEN 5 AND 8)
ORDER BY d.[Name],i.[Name],pr.[Name]

--Task 10
SELECT temp.CountryName, temp.DisributorName FROM
(
SELECT c.[Name] AS [CountryName]
, d.[Name] AS [DisributorName]
, DENSE_RANK() OVER (PARTITION BY c.[Name] ORDER BY COUNT(i.Id) DESC) AS [Ranked]
FROM Countries AS c
JOIN Distributors AS d ON c.Id = d.CountryId
LEFT JOIN Ingredients AS i ON d.Id = i.DistributorId
GROUP BY d.[Name], c.[Name]) AS temp
WHERE temp.Ranked = 1
ORDER BY temp.CountryName, temp.DisributorName

--Task 11
GO
CREATE VIEW v_UserWithCountries
AS
SELECT CONCAT(c.[FirstName],' ',c.[LastName]) AS [CustomerName],
       c.[Age],
	   c.[Gender],
	   co.[Name] AS [CountryName]
FROM [Customers] AS c
JOIN [Countries] AS co
ON c.[CountryId] = co.Id
GO

--Task 12
GO
CREATE OR ALTER TRIGGER tr_DeleteProducts
ON Products INSTEAD OF DELETE
AS
BEGIN
DELETE FROM Feedbacks
WHERE ProductId = (SELECT Id FROM deleted)

DELETE FROM ProductsIngredients
WHERE ProductId = (SELECT Id FROM deleted)

DELETE FROM Products
WHERE Id = (SELECT Id FROM deleted)
END
GO