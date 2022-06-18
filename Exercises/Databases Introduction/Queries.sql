
--Task 1
CREATE DATABASE [Minions]

USE [Minions]

--Task 2

CREATE TABLE [Minions] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(Max),
	[Age] INT
)

CREATE TABLE [Towns] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(Max)
)

--Task 3
ALTER TABLE [Minions]
ADD [TownId] INT FOREIGN KEY REFERENCES [Towns]([Id])

--Task 4
INSERT INTO [Minions] ([Name],[Age],[TownId])
VALUES
('Kevin',22,1),
('Bob',15,3),
('Steward',NULL,2)

INSERT INTO [Towns] ([Name])
VALUES
('Sofia'),
('Plovdiv'),
('Varna')

--Task 5 
TRUNCATE TABLE [Minions]

--Task 6
DROP TABLE [Minions]
DROP TABLE [Towns]

--Task 7
CREATE TABLE [People](
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200)NOT NULL,
	[Picture] VARBINARY(MAX),
	CHECK (DATALENGTH([Picture]) <= 2000000),
	[Height] DECIMAL (3,2),
	[Weight] DECIMAL (5,2),
	[Gender] CHAR (1) NOT NULL,
	CHECK([Gender] = 'm' OR [Gender] = 'f'),
	[Birthdate] DATE NOT NULL,
	[Biography] NVARCHAR(MAX)
)

INSERT INTO [People] ([Name],[Height],[Gender],[Birthdate])
	VALUES
	('Pesho',1.73,'m','1990-05-13'),
	('Qna',1.68,'f','1989-11-11'),
	('Svilen',1.99,'m','2000-01-02'),
	('Viki',1.31,'f','2014-10-22'),
	('Bobi',0.81,'f','2021-07-05')

--Task 8
CREATE TABLE [Users] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Username] VARCHAR(30) NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	[ProfilePicture] VARBINARY(MAX) CHECK(DATALENGTH([ProfilePicture]) <= 900000),
	[LastLoginTime] DATETIME,
	[IsDeleted] BIT
)

INSERT INTO Users (Username, [Password], LastLoginTime, IsDeleted) VALUES
('Pesho', 'peshoto', 07/05/1999, 0),
('Gosho', 'goshoto', 08/05/2002, 0),
('Mina', 'minata', 03/03/1999, 1),
('Kina', 'kinata', 07/05/1997, 0),
('Vasha', 'vashata', 06/08/1998, 1)

--Task 9
ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC077DB0E3A1

ALTER TABLE Users
ADD CONSTRAINT PK_IdUsername PRIMARY KEY (Id, Username)

--Task 10
ALTER TABLE [Users]
ADD CONSTRAINT CH_Username CHECK(LEN([Password]) >= 5)

--Task 11
ALTER TABLE [Users]
ADD CONSTRAINT df_LastLoginTime DEFAULT GETDATE() FOR LastLoginTime;

--Task 12
ALTER TABLE Users
DROP CONSTRAINT PK_IdUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Id PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CH_Username CHECK (LEN(Username)>=3)

--Task 13
CREATE DATABASE [Movies]

USE [Movies]

CREATE TABLE [Directors] (
	[Id]INT PRIMARY KEY IDENTITY,
	[DirectorName] NVARCHAR(50) NOT NULL,
	[Notes] NVARCHAR(255)
)

CREATE TABLE [Genres] (
	[Id] INT PRIMARY KEY IDENTITY,
	[GenreName] NVARCHAR(30) NOT NULL,
	[Notes] NVARCHAR(255)
)

CREATE TABLE [Categories] (
	[Id] INT PRIMARY KEY IDENTITY,
	[CategoryName] NVARCHAR(50) NOT NULL,
	[Notes] NVARCHAR(255)
)

CREATE TABLE [Movies] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Title] NVARCHAR(50) NOT NULL,
	[DirectorId] INT FOREIGN KEY REFERENCES [Directors]([Id]) NOT NULL,
	[CopyrightYear] DATE NOT NULL,
	[Length] TIME NOT NULL,
	[GenreId] INT FOREIGN KEY REFERENCES [Genres]([Id]) NOT NULL,
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories]([Id]) NOT NULL,
	[Rating] INT,
	[Notes] NVARCHAR(255)
)

INSERT INTO Directors ([DirectorName],[Notes]) 
VALUES
('Pesho Peshev' , 'Aaaaaaaa'),
('Gosho Peshev' , 'Aaaaaaaa'),
('Vasa Peshev' , 'Aaaaaaaa'),
('Dimo Peshev' , 'Aaaaaaaa'),
('Geca Peshev' , 'Aaaaaaaa')

INSERT INTO Genres ([GenreName],[Notes]) 
VALUES
('Drama', NULL),
('Comedy', NULL),
('Romance', NULL),
('Fiction', NULL),
('Action', NULL)

INSERT INTO Categories ([CategoryName],[Notes]) 
VALUES
('A', NULL),
('B', NULL),
('C', NULL),
('D', NULL),
('E', NULL)

INSERT INTO Movies ([Title],[DirectorId],[CopyrightYear],[Length],[GenreId],[CategoryId],[Rating],[Notes]) 
VALUES 
('Movie1', 1, '05/05/2002', '01:35:25', 1, 1, 25, NULL),
('Movie2', 2, '06/05/2001', '01:30:03', 2, 2, 21, NULL),
('Movie3', 3, '02/02/2000', '00:35:45', 3, 3, 20, NULL),
('Movie4', 4, '06/08/1999', '02:25:05', 4, 4, 26, NULL),
('Movie5', 5, '07/08/1998', '01:25:08', 5, 5, 27, NULL)