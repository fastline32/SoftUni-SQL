CREATE DATABASE [Table_Relations]

USE [Table_Relations]

--Task 1
CREATE TABLE [Passports] (
	[PassportID] INT PRIMARY KEY IDENTITY (101,1),
	[PassportNumber] VARCHAR(10) NOT NULL
)
CREATE TABLE [Persons](
	[PersonID] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR NOT NULL,
	[Salary] DECIMAL (8,2) NOT NULL,
	[PassportID] INT FOREIGN KEY REFERENCES [Passports] ([PassportID]) UNIQUE NOT NULL
)

--Task 2
CREATE TABLE [Manufacturers](
	[ManufacturerID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	[EstablishedOn] DATETIME NOT NULL,
)

CREATE TABLE [Models](
	[ModelID] INT PRIMARY KEY IDENTITY (101,1),
	[Name] VARCHAR (30) NOT NULL,
	[ManufacturerID] INT FOREIGN KEY REFERENCES [Manufacturers]([ManufacturerID])
)

--Task 3
CREATE TABLE [Students](
	[StudentID] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR (20) NOT NULL
)

CREATE TABLE [Exams] (
	[ExamID] INT IDENTITY (101,1)PRIMARY KEY,
	[Name] NVARCHAR (50) NOT NULL
)

CREATE TABLE [StudentsExams](
	[StudentID] INT FOREIGN KEY REFERENCES [Students] ([StudentID]) ,
	[ExamID] INT FOREIGN KEY REFERENCES [Exams] ([ExamID]),
	PRIMARY KEY([StudentID],[ExamID])
)

--Task 4
CREATE TABLE [Teachers](
	[TeacherID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	[ManagerID] INT FOREIGN KEY REFERENCES [Teachers] ([TeacherID])
)

--Task 5
CREATE TABLE [Cities](
	[CityID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR (50) NOT NULL
)

CREATE TABLE [ItemTypes](
	[ItemTypeID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR (50) NOT NULL
)

CREATE TABLE [Items] (
	[ItemID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[ItemTypeID] INT FOREIGN KEY REFERENCES [ItemTypes] (ItemTypeID)
)

CREATE TABLE [Customers](
	[CustomerID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[Birthday] DATE NOT NULL,
	[CityID] INT FOREIGN KEY REFERENCES [Cities] ([CityID])
)

CREATE TABLE [Orders](
	[OrderID] INT PRIMARY KEY IDENTITY,
	[CustomerID] INT FOREIGN KEY REFERENCES [Customers] ([CustomerID])
)

CREATE TABLE [OrderItems] (
	[OrderID] INT FOREIGN KEY REFERENCES [Orders] ([OrderID]),
	[ItemID] INT FOREIGN KEY REFERENCES [Items] ([ItemID])
	PRIMARY KEY ([OrderID],[ItemID])
)

--Task 6
CREATE TABLE [Subjects](
	[SubjectID] INT PRIMARY KEY,
	[SubjectName] VARCHAR(50)
)
CREATE TABLE [Majors](
	[MajorID] INT PRIMARY KEY,
	[Name] VARCHAR(50)
)
CREATE TABLE [Students](
	[StudentID] INT PRIMARY KEY,
	[StudentNumber] INT,
	[StudentName] VARCHAR(50),
	[MajorID] INT FOREIGN KEY REFERENCES [Majors] (MajorID)
)
CREATE TABLE [Payments](
	[PaymentID] INT PRIMARY KEY,
	[PaymentDate] DATE,
	[PaymentAmount] DECIMAL,
	[StudentID] INT FOREIGN KEY REFERENCES [Students] ([StudentID])
)
CREATE TABLE [Agenda](
	[StudentID] INT FOREIGN KEY REFERENCES [Students] (StudentID),
	[SubjectID] INT FOREIGN KEY REFERENCES [Subjects] (SubjectID),
	PRIMARY KEY (StudentID,SubjectID)
)

--Task 7

USE [Geography]

  SELECT m.[MountainRange], p.PeakName,p.Elevation 
    FROM Mountains AS m
    JOIN [Peaks] AS p ON m.Id = p.MountainId
   WHERE m.Id = 17
ORDER BY p.Elevation DESC