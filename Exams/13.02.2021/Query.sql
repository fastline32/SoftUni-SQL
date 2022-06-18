CREATE DATABASE [13.02.2021]

USE [13.02.2021]
USE [08.04.2021]
--Task 1
CREATE TABLE [Users](
	[Id] INT PRIMARY KEY IDENTITY,
	[Username] VARCHAR(30) NOT NULL,
	[Password] VARCHAR(30) NOT NULL,
	[Email] VARCHAR(50) NOT NULL
)

CREATE TABLE [Repositories] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [RepositoriesContributors] (
	[RepositoryId] INT FOREIGN KEY REFERENCES [Repositories]([Id]),
	[ContributorId] INT FOREIGN KEY REFERENCES [Users]([Id]),
	PRIMARY KEY([RepositoryId],[ContributorId])
)

CREATE TABLE [Issues] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Title] VARCHAR(255) NOT NULL,
	[IssueStatus] VARCHAR(6) NOT NULL,
	[RepositoryId] INT FOREIGN KEY REFERENCES [Repositories]([Id]),
	[AssigneeId] INT FOREIGN KEY REFERENCES [Users]([Id])
)

CREATE TABLE [Commits] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Message] VARCHAR(255) NOT NULL,
	[IssueId] INT FOREIGN KEY REFERENCES [Issues]([Id]),
	[RepositoryId] INT FOREIGN KEY REFERENCES [Repositories]([Id]) NOT NULL,
	[ContributorId] INT FOREIGN KEY REFERENCES [Users]([Id]) NOT NULL
)

CREATE TABLE [Files] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	[Size] DECIMAL(18,2) NOT NULL,
	[ParentId] INT FOREIGN KEY REFERENCES [Files]([Id]),
	[CommitId] INT FOREIGN KEY REFERENCES [Commits]([Id]) NOT NULL
)

--Task 2
INSERT INTO [Files] ([Name],[Size],[ParentId],[CommitId])
VALUES
('Trade.idk',2598.0,1,1),
('menu.net',9238.31,2,2),
('Administrate.soshy',1246.93,3,3),
('Controller.php',7353.15,4,4),
('Find.java',9957.86,5,5),
('Controller.json',14034.87,3,6),
('Operate.xix',7662.92,7,7)

INSERT INTO [Issues] ([Title],[IssueStatus],[RepositoryId],[AssigneeId])
VALUES
('Critical Problem with HomeController.cs file','open',1,4),
('Typo fix in Judge.html','open',4,3),
('Implement documentation for UsersService.cs','closed',8,2),
('Unreachable code in Index.cs','open',9,8)

--Task 3
UPDATE [Issues]
SET[IssueStatus] = 'closed'
WHERE [AssigneeId] = 6

--Task 4
DELETE[RepositoriesContributors]
WHERE [RepositoryId] = 3

UPDATE[Commits]
SET[IssueId] = Null
WHERE [IssueId] = 3

DELETE[Issues]
WHERE [RepositoryId] = 3

--Task 5
SELECT [Id],
	   [Message],
	   [RepositoryId],
	   [ContributorId]
FROM [Commits]
ORDER BY [Id],[Message],[RepositoryId],[ContributorId]

--Task 6
SELECT [Id],
	   [Name],
	   [Size]
FROM [Files]
WHERE [Size] > 1000 AND [Name] LIKE'%html%'
ORDER BY [Size] DESC,[Id],[Name]

--Task 7
SELECT i.[Id],
	CONCAT(u.[Username],' : ',i.[Title]) AS [IssueAssignee]
FROM [Issues] AS i
JOIN [Users] AS u
ON i.[AssigneeId] = u.[Id]
ORDER BY i.[Id] DESC,i.[AssigneeId]

--Task 8
SELECT fp.[Id],
	   fp.[Name],
	   CONCAT(fp.Size,'KB') AS [Size]
FROM [Files] AS fc
FULL OUTER JOIN [Files] fp
ON fc.[ParentId] = fp.[Id]
WHERE fc.[Id] IS NULL
ORDER BY fp.[Id],fp.[Name],fp.[Size] DESC

--Task 9
SELECT TOP (5) r.[Id],
	           r.[Name],
	       COUNT (*) AS [Commits]
FROM [Repositories] AS r
LEFT JOIN [Commits] AS c
ON c.[RepositoryId] = r.[Id]
LEFT JOIN [RepositoriesContributors] AS rc
ON rc.[RepositoryId] = r.[Id]
GROUP BY r.[Id],r.[Name]
ORDER BY [Commits] DESC,r.[Id],r.[Name]

--Task 10
SELECT u.[Username],
	AVG(f.[Size]) AS [Size]
FROM [Users] AS u
JOIN [Commits] AS c
ON u.[Id] = c.[ContributorId]
JOIN [Files] AS f
ON c.[Id] = f.[CommitId]
GROUP BY u.[Id],u.[Username]
ORDER BY [Size] DESC, u.[Username]

--Task 11
GO
CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
BEGIN
	DECLARE @UserId INT = (SELECT [Id] FROM [Users] WHERE [Username] = @username)

	RETURN (SELECT COUNT ([Id]) 
              FROM [Commits]
             WHERE [ContributorId] = @UserId)
END
GO


--Task 12

CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
BEGIN
	SELECT [Id],
	       [Name],
	       CONCAT([Size],'KB') AS [Size]
      FROM [Files]
     WHERE [Name] LIKE CONCAT('%[.]',@fileExtension)
  ORDER BY [Id],[Name],[Size] DESC

END

