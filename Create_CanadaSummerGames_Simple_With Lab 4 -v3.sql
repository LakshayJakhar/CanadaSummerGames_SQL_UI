USE master
GO
--VERSION WITH LAB 4 SOLUTION IN PLACE
IF  EXISTS (SELECT name FROM sys.databases WHERE (name = N'CanadaSummerGames_Simple'))
BEGIN
	ALTER DATABASE [CanadaSummerGames_Simple]
	SET OFFLINE WITH ROLLBACK IMMEDIATE
	ALTER DATABASE [CanadaSummerGames_Simple]
	SET ONLINE
	DROP DATABASE [CanadaSummerGames_Simple]
END
GO

CREATE DATABASE [CanadaSummerGames_Simple]
GO

ALTER DATABASE [CanadaSummerGames_Simple] SET RECOVERY SIMPLE 

GO
USE [CanadaSummerGames_Simple]
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetAge]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Note: there are lots of ways to calculate Age and this is only one.
--From http://www.sql-server-helper.com/functions/get-age.aspx
--Note the checks for earlier month and/or month/day to decide if
--you need to subtract 1.
--YOU WERE NOT REQUIRED TO CREATE A FUNCTION!
--I will accept solutions that calculate Age without using a function as well.

CREATE FUNCTION [dbo].[ufn_GetAge] ( @pDateOfBirth    DATETIME, 
                                     @pAsOfDate       DATETIME )
RETURNS INT
AS
BEGIN

    DECLARE @vAge         INT
    
    IF @pDateOfBirth >= @pAsOfDate
        RETURN 0

    SET @vAge = DATEDIFF(YY, @pDateOfBirth, @pAsOfDate)

    IF MONTH(@pDateOfBirth) > MONTH(@pAsOfDate) OR
      (MONTH(@pDateOfBirth) = MONTH(@pAsOfDate) AND
       DAY(@pDateOfBirth)   > DAY(@pAsOfDate))
        SET @vAge = @vAge - 1

    RETURN @vAge
END
GO
/****** Object:  Table [dbo].[Athlete]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Athlete](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[AthleteCode] [nvarchar](7) NOT NULL,
	[DOB] [datetime2](7) NOT NULL,
	[Height] [float] NOT NULL,
	[Weight] [float] NOT NULL,
	[MediaInfo] [nvarchar](2000) NOT NULL,
	[EMail] [nvarchar](150) NULL,
	[RowVersion] [timestamp] NULL,
	[ContingentID] [int] NOT NULL,
	[GenderID] [int] NOT NULL,
 CONSTRAINT [PK_Athletes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Contingent]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Contingent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](2) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Contingents] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Gender]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gender](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Genders] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_Athlete]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--2 a) - Eagerly Loaded View
CREATE VIEW [dbo].[v_Athlete]
AS
SELECT   Athlete.ID, Athlete.FirstName, Athlete.MiddleName, Athlete.LastName, Athlete.AthleteCode, 
			Athlete.DOB, Athlete.Height, Athlete.Weight, Athlete.MediaInfo, Athlete.EMail, 
			Athlete.RowVersion, Athlete.ContingentID, Athlete.GenderID, 
			CONCAT(FirstName, ' ', UPPER(SUBSTRING(Middlename,1,1)), '. ',LastName) AS Summary,
			dbo.ufn_GetAge(DOB,'2022-08-01') AS Age,
			Gender.Name as Gender, 
			Contingent.Name AS Contingent
FROM      Athlete INNER JOIN
                Gender ON Athlete.GenderID = Gender.ID INNER JOIN
                Contingent ON Athlete.ContingentID = Contingent.ID
GO
/****** Object:  Table [dbo].[AthleteSport]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AthleteSport](
	[AthleteID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
 CONSTRAINT [PK_AthleteSports] PRIMARY KEY CLUSTERED 
(
	[AthleteID] ASC,
	[SportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Event]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Event](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](10) NOT NULL,
	[SportID] [int] NOT NULL,
	[GenderID] [int] NOT NULL,
 CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Placement]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Placement](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Place] [int] NOT NULL,
	[Comments] [nvarchar](2000) NULL,
	[EventID] [int] NOT NULL,
	[AthleteID] [int] NOT NULL,
 CONSTRAINT [PK_Placements] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sport]    Script Date: 8/6/2023 8:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](3) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Sports] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Athlete] ON 
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (1, N'Lukas', N'A', N'Watts', N'8242000', CAST(N'2003-08-19T00:00:00.0000000' AS DateTime2), 184, 92, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'lawatts@canadasg.ca', 8, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (2, N'Jamison', N'A', N'Watts', N'8997914', CAST(N'2001-09-26T00:00:00.0000000' AS DateTime2), 195, 97, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'jawatts@canadasg.ca', 3, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (3, N'Chanel', N'A', N'Watts', N'7063732', CAST(N'2003-07-31T00:00:00.0000000' AS DateTime2), 185, 97, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'cawatts@canadasg.ca', 10, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (4, N'Ruth', N'A', N'Watts', N'8436882', CAST(N'1993-09-10T00:00:00.0000000' AS DateTime2), 173, 81, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'rawatts@canadasg.ca', 8, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (5, N'Lukas', N'A', N'Randall', N'3518273', CAST(N'1997-07-18T00:00:00.0000000' AS DateTime2), 194, 89, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'larandall@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (6, N'Braden', N'A', N'Randall', N'7028785', CAST(N'2003-09-10T00:00:00.0000000' AS DateTime2), 184, 82, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'barandall@canadasg.ca', 6, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (7, N'Kyler', N'A', N'Randall', N'5165879', CAST(N'2007-02-04T00:00:00.0000000' AS DateTime2), 176, 91, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'karandall@canadasg.ca', 4, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (8, N'Moses', N'A', N'Randall', N'7345988', CAST(N'1997-11-05T00:00:00.0000000' AS DateTime2), 196, 86, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'marandall@canadasg.ca', 5, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (9, N'Quintin', N'R', N'Arias', N'9684090', CAST(N'2003-12-24T00:00:00.0000000' AS DateTime2), 172, 91, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'qrarias@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (10, N'Lukas', N'R', N'Arias', N'2765254', CAST(N'2003-05-17T00:00:00.0000000' AS DateTime2), 197, 81, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'lrarias@canadasg.ca', 4, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (11, N'Braden', N'R', N'Arias', N'2825090', CAST(N'2003-02-14T00:00:00.0000000' AS DateTime2), 193, 97, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'brarias@canadasg.ca', 8, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (12, N'Natalee', N'R', N'Arias', N'9525381', CAST(N'2000-03-06T00:00:00.0000000' AS DateTime2), 177, 90, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'nrarias@canadasg.ca', 9, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (13, N'Emilia', N'E', N'Weber', N'7294425', CAST(N'2005-10-13T00:00:00.0000000' AS DateTime2), 179, 98, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'eeweber@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (14, N'Tyler', N'E', N'Weber', N'7507095', CAST(N'1998-04-25T00:00:00.0000000' AS DateTime2), 190, 84, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'teweber@canadasg.ca', 3, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (15, N'Antoinette', N'E', N'Weber', N'4289101', CAST(N'1998-09-29T00:00:00.0000000' AS DateTime2), 181, 80, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'aeweber@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (16, N'Kendal', N'E', N'Weber', N'5875662', CAST(N'2004-01-17T00:00:00.0000000' AS DateTime2), 175, 91, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'keweber@canadasg.ca', 6, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (17, N'Lyric', N'T', N'Stone', N'1112460', CAST(N'2001-12-22T00:00:00.0000000' AS DateTime2), 188, 95, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'ltstone@canadasg.ca', 8, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (18, N'Clarence', N'T', N'Stone', N'6937077', CAST(N'1998-11-11T00:00:00.0000000' AS DateTime2), 178, 80, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'ctstone@canadasg.ca', 4, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (19, N'Jakayla', N'T', N'Stone', N'5945167', CAST(N'2001-05-13T00:00:00.0000000' AS DateTime2), 190, 84, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'jtstone@canadasg.ca', 13, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (20, N'Tyler', N'T', N'Stone', N'1553956', CAST(N'2003-05-20T00:00:00.0000000' AS DateTime2), 170, 84, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'ttstone@canadasg.ca', 8, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (21, N'Lyric', N'A', N'Carlson', N'4241350', CAST(N'2008-09-14T00:00:00.0000000' AS DateTime2), 176, 81, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'lacarlson@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (22, N'Jamison', N'A', N'Carlson', N'1155029', CAST(N'2009-08-05T00:00:00.0000000' AS DateTime2), 186, 94, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'jacarlson@canadasg.ca', 7, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (23, N'Quintin', N'A', N'Carlson', N'4247883', CAST(N'1997-07-17T00:00:00.0000000' AS DateTime2), 194, 99, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'qacarlson@canadasg.ca', 4, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (24, N'Lukas', N'A', N'Carlson', N'3347850', CAST(N'2009-07-24T00:00:00.0000000' AS DateTime2), 179, 96, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'lacarlson@canadasg.ca', 2, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (25, N'Jamison', N'O', N'Robles', N'8791211', CAST(N'1994-06-11T00:00:00.0000000' AS DateTime2), 184, 97, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'jorobles@canadasg.ca', 10, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (26, N'Clarence', N'O', N'Robles', N'6802310', CAST(N'1999-11-10T00:00:00.0000000' AS DateTime2), 173, 93, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'corobles@canadasg.ca', 7, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (27, N'Moses', N'O', N'Robles', N'2724761', CAST(N'2004-01-16T00:00:00.0000000' AS DateTime2), 191, 85, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'morobles@canadasg.ca', 2, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (28, N'Ruth', N'O', N'Robles', N'7804672', CAST(N'2003-06-30T00:00:00.0000000' AS DateTime2), 172, 92, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'rorobles@canadasg.ca', 3, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (29, N'Yadiel', N'R', N'Frederick', N'8523470', CAST(N'1996-05-26T00:00:00.0000000' AS DateTime2), 172, 98, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'yrfrederick@canadasg.ca', 5, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (30, N'Lyric', N'R', N'Frederick', N'8041579', CAST(N'1999-05-05T00:00:00.0000000' AS DateTime2), 176, 95, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'lrfrederick@canadasg.ca', 12, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (31, N'Emilia', N'R', N'Frederick', N'9336198', CAST(N'1993-01-14T00:00:00.0000000' AS DateTime2), 171, 83, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'erfrederick@canadasg.ca', 13, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (32, N'Vivian', N'R', N'Frederick', N'1675365', CAST(N'2002-04-03T00:00:00.0000000' AS DateTime2), 182, 93, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'vrfrederick@canadasg.ca', 8, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (33, N'Ruth', N'A', N'Parker', N'3478008', CAST(N'1996-03-01T00:00:00.0000000' AS DateTime2), 182, 82, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'raparker@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (34, N'Natalee', N'A', N'Parker', N'6862477', CAST(N'1992-12-29T00:00:00.0000000' AS DateTime2), 192, 92, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'naparker@canadasg.ca', 3, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (35, N'Moses', N'A', N'Parker', N'1381505', CAST(N'2006-11-17T00:00:00.0000000' AS DateTime2), 173, 89, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'maparker@canadasg.ca', 1, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (36, N'Emilia', N'A', N'Parker', N'6213440', CAST(N'2005-02-19T00:00:00.0000000' AS DateTime2), 193, 96, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'eaparker@canadasg.ca', 11, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (37, N'Braden', N'O', N'Morris', N'4849910', CAST(N'1993-08-17T00:00:00.0000000' AS DateTime2), 187, 94, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'bomorris@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (38, N'Ruth', N'O', N'Morris', N'5310973', CAST(N'1998-02-03T00:00:00.0000000' AS DateTime2), 189, 82, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'romorris@canadasg.ca', 1, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (39, N'Lukas', N'O', N'Morris', N'4875366', CAST(N'1996-08-26T00:00:00.0000000' AS DateTime2), 197, 85, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'lomorris@canadasg.ca', 8, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (40, N'Lyric', N'O', N'Morris', N'6424102', CAST(N'1994-08-03T00:00:00.0000000' AS DateTime2), 171, 99, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'lomorris@canadasg.ca', 2, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (41, N'Braden', N'O', N'Soto', N'9753555', CAST(N'2000-03-12T00:00:00.0000000' AS DateTime2), 183, 84, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'bosoto@canadasg.ca', 8, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (42, N'Kendal', N'O', N'Soto', N'9373598', CAST(N'1995-04-23T00:00:00.0000000' AS DateTime2), 178, 81, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'kosoto@canadasg.ca', 7, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (43, N'Moses', N'O', N'Soto', N'2114639', CAST(N'2003-05-03T00:00:00.0000000' AS DateTime2), 175, 99, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'mosoto@canadasg.ca', 9, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (44, N'Natalee', N'O', N'Soto', N'4569873', CAST(N'2002-02-22T00:00:00.0000000' AS DateTime2), 179, 82, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'nosoto@canadasg.ca', 6, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (45, N'Clarence', N'R', N'Bruce', N'8481777', CAST(N'2000-01-22T00:00:00.0000000' AS DateTime2), 196, 81, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'crbruce@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (46, N'Antoinette', N'R', N'Bruce', N'4270322', CAST(N'1997-10-02T00:00:00.0000000' AS DateTime2), 178, 95, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'arbruce@canadasg.ca', 4, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (47, N'Lukas', N'R', N'Bruce', N'5314782', CAST(N'2010-01-11T00:00:00.0000000' AS DateTime2), 197, 97, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'lrbruce@canadasg.ca', 3, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (48, N'Kendal', N'R', N'Bruce', N'1266050', CAST(N'2000-12-26T00:00:00.0000000' AS DateTime2), 180, 84, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'krbruce@canadasg.ca', 1, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (49, N'Ruth', N'R', N'Orozco', N'9877713', CAST(N'2004-11-06T00:00:00.0000000' AS DateTime2), 173, 89, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'rrorozco@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (50, N'Lyric', N'R', N'Orozco', N'2027844', CAST(N'2009-06-12T00:00:00.0000000' AS DateTime2), 175, 99, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'lrorozco@canadasg.ca', 1, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (51, N'Jakayla', N'R', N'Orozco', N'7011617', CAST(N'2009-03-11T00:00:00.0000000' AS DateTime2), 171, 92, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'jrorozco@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (52, N'Tyler', N'R', N'Orozco', N'6290585', CAST(N'1995-08-17T00:00:00.0000000' AS DateTime2), 196, 84, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'trorozco@canadasg.ca', 11, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (53, N'Jamison', N'O', N'Boyer', N'7317606', CAST(N'2004-05-07T00:00:00.0000000' AS DateTime2), 190, 98, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'joboyer@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (54, N'Quintin', N'O', N'Boyer', N'6696861', CAST(N'2003-11-17T00:00:00.0000000' AS DateTime2), 185, 80, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'qoboyer@canadasg.ca', 2, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (55, N'Clarence', N'O', N'Boyer', N'9206439', CAST(N'1997-10-04T00:00:00.0000000' AS DateTime2), 193, 86, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'coboyer@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (56, N'Kendal', N'O', N'Boyer', N'5437190', CAST(N'2009-01-21T00:00:00.0000000' AS DateTime2), 197, 89, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'koboyer@canadasg.ca', 3, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (57, N'Vivian', N'U', N'Burns', N'2810833', CAST(N'2009-02-16T00:00:00.0000000' AS DateTime2), 192, 83, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'vuburns@canadasg.ca', 6, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (58, N'Braden', N'U', N'Burns', N'2881805', CAST(N'2008-10-22T00:00:00.0000000' AS DateTime2), 188, 97, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'buburns@canadasg.ca', 2, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (59, N'Antoinette', N'U', N'Burns', N'1823384', CAST(N'2002-12-28T00:00:00.0000000' AS DateTime2), 185, 83, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'auburns@canadasg.ca', 10, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (60, N'Jamison', N'U', N'Burns', N'9986424', CAST(N'1993-01-20T00:00:00.0000000' AS DateTime2), 187, 90, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'juburns@canadasg.ca', 5, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (61, N'Antoinette', N'O', N'Cobb', N'8703186', CAST(N'2008-08-24T00:00:00.0000000' AS DateTime2), 181, 89, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'aocobb@canadasg.ca', 4, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (62, N'Emilia', N'O', N'Cobb', N'1910376', CAST(N'1997-01-18T00:00:00.0000000' AS DateTime2), 170, 83, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'eocobb@canadasg.ca', 3, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (63, N'Kendal', N'O', N'Cobb', N'5288149', CAST(N'1998-05-11T00:00:00.0000000' AS DateTime2), 172, 82, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'kocobb@canadasg.ca', 1, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (64, N'Jamison', N'O', N'Cobb', N'4641401', CAST(N'1996-08-12T00:00:00.0000000' AS DateTime2), 179, 99, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'jocobb@canadasg.ca', 11, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (65, N'Natalee', N'L', N'Blankenship', N'4924063', CAST(N'2006-12-23T00:00:00.0000000' AS DateTime2), 174, 84, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'nlblankenship@canadasg.ca', 5, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (66, N'Quintin', N'L', N'Blankenship', N'5506728', CAST(N'2006-11-20T00:00:00.0000000' AS DateTime2), 178, 89, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'qlblankenship@canadasg.ca', 5, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (67, N'Jakayla', N'L', N'Blankenship', N'9163716', CAST(N'2005-04-08T00:00:00.0000000' AS DateTime2), 175, 85, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'jlblankenship@canadasg.ca', 1, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (68, N'Yadiel', N'L', N'Blankenship', N'5292649', CAST(N'2004-09-20T00:00:00.0000000' AS DateTime2), 190, 91, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'ylblankenship@canadasg.ca', 10, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (69, N'Natalee', N'O', N'Houston', N'7931997', CAST(N'2010-03-10T00:00:00.0000000' AS DateTime2), 179, 80, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'nohouston@canadasg.ca', 2, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (70, N'Antoinette', N'O', N'Houston', N'1972775', CAST(N'2009-12-27T00:00:00.0000000' AS DateTime2), 180, 94, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'aohouston@canadasg.ca', 13, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (71, N'Camilla', N'O', N'Houston', N'2203687', CAST(N'2008-09-04T00:00:00.0000000' AS DateTime2), 184, 90, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'cohouston@canadasg.ca', 5, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (72, N'Ruth', N'O', N'Houston', N'6754789', CAST(N'2010-03-22T00:00:00.0000000' AS DateTime2), 185, 91, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'rohouston@canadasg.ca', 5, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (73, N'Braden', N'S', N'Estes', N'6778167', CAST(N'2003-11-29T00:00:00.0000000' AS DateTime2), 173, 80, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'bsestes@canadasg.ca', 3, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (74, N'Kendal', N'S', N'Estes', N'3660677', CAST(N'2007-07-07T00:00:00.0000000' AS DateTime2), 184, 87, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'ksestes@canadasg.ca', 2, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (75, N'Vivian', N'S', N'Estes', N'3007840', CAST(N'2001-02-07T00:00:00.0000000' AS DateTime2), 193, 86, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'vsestes@canadasg.ca', 4, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (76, N'Karla', N'S', N'Estes', N'5060642', CAST(N'2007-06-13T00:00:00.0000000' AS DateTime2), 197, 97, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'ksestes@canadasg.ca', 7, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (77, N'Antoinette', N'T', N'Atkins', N'4236454', CAST(N'1995-07-05T00:00:00.0000000' AS DateTime2), 199, 96, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'atatkins@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (78, N'Chanel', N'T', N'Atkins', N'7124318', CAST(N'2007-10-03T00:00:00.0000000' AS DateTime2), 193, 81, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'ctatkins@canadasg.ca', 9, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (79, N'Quintin', N'T', N'Atkins', N'4515342', CAST(N'2002-12-29T00:00:00.0000000' AS DateTime2), 185, 87, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'qtatkins@canadasg.ca', 2, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (80, N'Jamison', N'T', N'Atkins', N'3322863', CAST(N'2001-09-24T00:00:00.0000000' AS DateTime2), 198, 87, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'jtatkins@canadasg.ca', 8, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (81, N'Lyric', N'I', N'Miranda', N'9494974', CAST(N'1999-01-18T00:00:00.0000000' AS DateTime2), 176, 81, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'limiranda@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (82, N'Jamison', N'I', N'Miranda', N'6042640', CAST(N'2001-04-07T00:00:00.0000000' AS DateTime2), 182, 86, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'jimiranda@canadasg.ca', 5, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (83, N'Natalee', N'I', N'Miranda', N'4085096', CAST(N'2007-08-10T00:00:00.0000000' AS DateTime2), 191, 88, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'nimiranda@canadasg.ca', 9, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (84, N'Ruth', N'I', N'Miranda', N'2184281', CAST(N'1999-01-16T00:00:00.0000000' AS DateTime2), 186, 89, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'rimiranda@canadasg.ca', 13, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (85, N'Ruth', N'U', N'Zuniga', N'4114464', CAST(N'2007-10-19T00:00:00.0000000' AS DateTime2), 195, 83, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'ruzuniga@canadasg.ca', 9, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (86, N'Antoinette', N'U', N'Zuniga', N'6164911', CAST(N'2001-12-30T00:00:00.0000000' AS DateTime2), 189, 97, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'auzuniga@canadasg.ca', 11, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (87, N'Clarence', N'U', N'Zuniga', N'9474639', CAST(N'2009-01-05T00:00:00.0000000' AS DateTime2), 198, 94, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'cuzuniga@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (88, N'Camilla', N'U', N'Zuniga', N'3499442', CAST(N'2008-05-07T00:00:00.0000000' AS DateTime2), 172, 99, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'cuzuniga@canadasg.ca', 10, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (89, N'Lukas', N'A', N'Ward', N'2140804', CAST(N'2002-07-28T00:00:00.0000000' AS DateTime2), 174, 96, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'laward@canadasg.ca', 4, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (90, N'Moses', N'A', N'Ward', N'2144642', CAST(N'2008-08-07T00:00:00.0000000' AS DateTime2), 174, 90, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'maward@canadasg.ca', 2, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (91, N'Clarence', N'A', N'Ward', N'6994752', CAST(N'2003-02-11T00:00:00.0000000' AS DateTime2), 197, 86, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'caward@canadasg.ca', 5, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (92, N'Braden', N'A', N'Ward', N'7014358', CAST(N'1993-09-26T00:00:00.0000000' AS DateTime2), 187, 85, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'baward@canadasg.ca', 13, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (93, N'Tyler', N'A', N'Mayo', N'6812539', CAST(N'1993-01-02T00:00:00.0000000' AS DateTime2), 188, 80, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'tamayo@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (94, N'Chanel', N'A', N'Mayo', N'3409823', CAST(N'2001-09-09T00:00:00.0000000' AS DateTime2), 193, 96, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'camayo@canadasg.ca', 13, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (95, N'Clarence', N'A', N'Mayo', N'6044162', CAST(N'2003-03-07T00:00:00.0000000' AS DateTime2), 183, 96, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'camayo@canadasg.ca', 10, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (96, N'Karla', N'A', N'Mayo', N'6635082', CAST(N'2003-12-07T00:00:00.0000000' AS DateTime2), 196, 94, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'kamayo@canadasg.ca', 9, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (97, N'Kendal', N'O', N'Costa', N'2827154', CAST(N'2004-06-22T00:00:00.0000000' AS DateTime2), 198, 97, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'kocosta@canadasg.ca', 6, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (98, N'Moses', N'O', N'Costa', N'9121063', CAST(N'1995-12-09T00:00:00.0000000' AS DateTime2), 175, 84, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'mocosta@canadasg.ca', 13, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (99, N'Natalee', N'O', N'Costa', N'3964942', CAST(N'2003-10-24T00:00:00.0000000' AS DateTime2), 172, 84, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'nocosta@canadasg.ca', 12, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (100, N'Ruth', N'O', N'Costa', N'6869287', CAST(N'1996-05-07T00:00:00.0000000' AS DateTime2), 188, 80, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'rocosta@canadasg.ca', 4, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (101, N'Clarence', N'E', N'Reeves', N'5722295', CAST(N'2002-09-05T00:00:00.0000000' AS DateTime2), 172, 87, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'cereeves@canadasg.ca', 6, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (102, N'Tyler', N'E', N'Reeves', N'9533684', CAST(N'2005-10-08T00:00:00.0000000' AS DateTime2), 192, 88, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'tereeves@canadasg.ca', 1, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (103, N'Camilla', N'E', N'Reeves', N'9792166', CAST(N'1996-03-24T00:00:00.0000000' AS DateTime2), 171, 90, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'cereeves@canadasg.ca', 5, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (104, N'Vivian', N'E', N'Reeves', N'8497961', CAST(N'1993-02-16T00:00:00.0000000' AS DateTime2), 188, 97, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'vereeves@canadasg.ca', 9, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (105, N'Kendal', N'N', N'Anthony', N'8376389', CAST(N'2004-11-23T00:00:00.0000000' AS DateTime2), 177, 91, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'knanthony@canadasg.ca', 10, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (106, N'Jamison', N'N', N'Anthony', N'4363058', CAST(N'2007-02-13T00:00:00.0000000' AS DateTime2), 175, 92, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'jnanthony@canadasg.ca', 4, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (107, N'Emilia', N'N', N'Anthony', N'7483320', CAST(N'2002-11-23T00:00:00.0000000' AS DateTime2), 193, 99, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'enanthony@canadasg.ca', 4, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (108, N'Tyler', N'N', N'Anthony', N'3190044', CAST(N'1997-06-09T00:00:00.0000000' AS DateTime2), 191, 82, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'tnanthony@canadasg.ca', 9, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (109, N'Lyric', N'O', N'Cook', N'4598291', CAST(N'2003-09-08T00:00:00.0000000' AS DateTime2), 184, 86, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'locook@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (110, N'Antoinette', N'O', N'Cook', N'2701840', CAST(N'2001-03-25T00:00:00.0000000' AS DateTime2), 187, 97, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'aocook@canadasg.ca', 6, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (111, N'Ruth', N'O', N'Cook', N'3529905', CAST(N'1994-04-27T00:00:00.0000000' AS DateTime2), 171, 87, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'rocook@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (112, N'Chanel', N'O', N'Cook', N'1666507', CAST(N'1993-08-20T00:00:00.0000000' AS DateTime2), 187, 84, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'cocook@canadasg.ca', 10, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (113, N'Kendal', N'R', N'Krueger', N'2228031', CAST(N'1995-10-21T00:00:00.0000000' AS DateTime2), 197, 88, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'krkrueger@canadasg.ca', 9, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (114, N'Camilla', N'R', N'Krueger', N'6578483', CAST(N'2002-09-15T00:00:00.0000000' AS DateTime2), 172, 90, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'crkrueger@canadasg.ca', 2, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (115, N'Kyler', N'R', N'Krueger', N'7732051', CAST(N'2010-02-20T00:00:00.0000000' AS DateTime2), 190, 80, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'krkrueger@canadasg.ca', 5, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (116, N'Braden', N'R', N'Krueger', N'9537805', CAST(N'1994-09-10T00:00:00.0000000' AS DateTime2), 177, 86, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'brkrueger@canadasg.ca', 7, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (117, N'Camilla', N'R', N'Crane', N'7183618', CAST(N'1996-11-28T00:00:00.0000000' AS DateTime2), 173, 88, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'crcrane@canadasg.ca', 9, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (118, N'Moses', N'R', N'Crane', N'2773305', CAST(N'1999-12-13T00:00:00.0000000' AS DateTime2), 185, 80, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'mrcrane@canadasg.ca', 1, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (119, N'Clarence', N'R', N'Crane', N'5150489', CAST(N'1996-05-25T00:00:00.0000000' AS DateTime2), 175, 83, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'crcrane@canadasg.ca', 3, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (120, N'Antoinette', N'R', N'Crane', N'8539260', CAST(N'2003-11-20T00:00:00.0000000' AS DateTime2), 180, 82, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', N'arcrane@canadasg.ca', 1, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (121, N'Jamison', N'A', N'Watts', N'3793014', CAST(N'2008-05-03T00:00:00.0000000' AS DateTime2), 184, 89, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'jawatts@canadasg.ca', 5, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (122, N'Quintin', N'A', N'Watts', N'7948738', CAST(N'2009-01-24T00:00:00.0000000' AS DateTime2), 177, 99, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'qawatts@canadasg.ca', 8, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (123, N'Ruth', N'A', N'Watts', N'2777378', CAST(N'1993-12-04T00:00:00.0000000' AS DateTime2), 181, 82, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'rawatts@canadasg.ca', 9, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (124, N'Jakayla', N'A', N'Watts', N'9530808', CAST(N'2005-07-08T00:00:00.0000000' AS DateTime2), 196, 99, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'jawatts@canadasg.ca', 13, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (125, N'Karla', N'I', N'Little', N'8904029', CAST(N'2004-05-04T00:00:00.0000000' AS DateTime2), 189, 83, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'kilittle@canadasg.ca', 10, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (126, N'Ruth', N'I', N'Little', N'7498710', CAST(N'2001-05-14T00:00:00.0000000' AS DateTime2), 180, 97, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'rilittle@canadasg.ca', 10, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (127, N'Kendal', N'I', N'Little', N'1610953', CAST(N'1998-12-18T00:00:00.0000000' AS DateTime2), 198, 85, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'kilittle@canadasg.ca', 2, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (128, N'Natalee', N'I', N'Little', N'4108298', CAST(N'1993-04-27T00:00:00.0000000' AS DateTime2), 177, 95, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'nilittle@canadasg.ca', 7, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (129, N'Jamison', N'E', N'Henderson', N'5383996', CAST(N'1994-03-29T00:00:00.0000000' AS DateTime2), 196, 89, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'jehenderson@canadasg.ca', 13, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (130, N'Clarence', N'E', N'Henderson', N'6634442', CAST(N'2005-01-10T00:00:00.0000000' AS DateTime2), 197, 83, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', N'cehenderson@canadasg.ca', 9, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (131, N'Yadiel', N'E', N'Henderson', N'6154952', CAST(N'1994-12-13T00:00:00.0000000' AS DateTime2), 173, 92, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'yehenderson@canadasg.ca', 11, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (132, N'Vivian', N'E', N'Henderson', N'1737543', CAST(N'1996-01-14T00:00:00.0000000' AS DateTime2), 184, 85, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'vehenderson@canadasg.ca', 9, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (133, N'Quintin', N'I', N'Bishop', N'6623217', CAST(N'2005-07-05T00:00:00.0000000' AS DateTime2), 176, 90, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', N'qibishop@canadasg.ca', 9, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (134, N'Jakayla', N'I', N'Bishop', N'5786908', CAST(N'2006-10-20T00:00:00.0000000' AS DateTime2), 195, 85, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'jibishop@canadasg.ca', 13, 1)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (135, N'Yadiel', N'I', N'Bishop', N'8667376', CAST(N'1996-07-05T00:00:00.0000000' AS DateTime2), 189, 88, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', N'yibishop@canadasg.ca', 7, 2)
GO
INSERT [dbo].[Athlete] ([ID], [FirstName], [MiddleName], [LastName], [AthleteCode], [DOB], [Height], [Weight], [MediaInfo], [EMail], [ContingentID], [GenderID]) VALUES (136, N'Vivian', N'I', N'Bishop', N'9744200', CAST(N'2009-05-09T00:00:00.0000000' AS DateTime2), 170, 86, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', N'vibishop@canadasg.ca', 1, 1)
GO
SET IDENTITY_INSERT [dbo].[Athlete] OFF
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (45, 1)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (114, 1)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (116, 2)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (128, 2)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (19, 3)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (71, 3)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (90, 3)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (121, 3)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (16, 4)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (23, 4)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (89, 5)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (73, 6)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (88, 6)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (129, 6)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (31, 8)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (51, 8)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (97, 8)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (135, 8)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (48, 9)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (60, 9)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (61, 9)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (109, 10)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (25, 11)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (95, 11)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (87, 12)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (115, 12)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (125, 12)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (27, 13)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (30, 13)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (74, 13)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (34, 14)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (55, 14)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (82, 14)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (108, 14)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (130, 14)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (21, 15)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (53, 15)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (33, 16)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (94, 16)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (6, 17)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (11, 17)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (14, 18)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (43, 19)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (98, 19)
GO
INSERT [dbo].[AthleteSport] ([AthleteID], [SportID]) VALUES (133, 19)
GO
SET IDENTITY_INSERT [dbo].[Contingent] ON 
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (1, N'ON', N'Ontario')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (2, N'PE', N'Prince Edward Island')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (3, N'NB', N'New Brunswick')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (4, N'BC', N'British Columbia')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (5, N'NL', N'Newfoundland and Labrador')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (6, N'SK', N'Saskatchewan')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (7, N'NS', N'Nova Scotia')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (8, N'MB', N'Manitoba')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (9, N'QC', N'Quebec')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (10, N'YT', N'Yukon')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (11, N'NU', N'Nunavut')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (12, N'NT', N'Northwest Territories')
GO
INSERT [dbo].[Contingent] ([ID], [Code], [Name]) VALUES (13, N'AB', N'Alberta')
GO
SET IDENTITY_INSERT [dbo].[Contingent] OFF
GO
SET IDENTITY_INSERT [dbo].[Event] ON 
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (1, N'Backetball', N'Team', 9, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (2, N'Quad (M4x)', N'Team', 16, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (3, N'Double (W2x)', N'Team', 16, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (4, N'Eight (W8+)', N'Team', 16, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (5, N'Four (W4-)', N'Team', 16, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (6, N'Lightweight Double (LW2x)', N'Team', 16, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (7, N'Pair (W2-)', N'Team', 16, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (8, N'Quad (W4x)', N'Team', 16, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (9, N'Rugby Sevens', N'Team', 17, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (10, N'Single Handed Laser', N'Individual', 18, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (11, N'Pair (M2-)', N'Team', 16, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (12, N'Single Handed Laser Radial', N'Individual', 18, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (13, N'Double Handed 29er', N'Team', 18, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (14, N'Soccer', N'Team', 1, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (15, N'Soccer', N'Team', 1, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (16, N'Softball', N'Team', 6, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (17, N'Softball', N'Team', 6, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (18, N'100m Backstroke', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (19, N'100m Breaststroke', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (20, N'100m Butterfly', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (21, N'100m Freestyle', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (22, N'Double Handed 29er', N'Team', 18, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (23, N'Lightweight Double (LM2x)', N'Team', 16, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (24, N'Four (M4-)', N'Team', 16, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (25, N'Eight (M8+)', N'Team', 16, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (26, N'Road Cycling Road Race', N'Individual', 11, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (27, N'Road Cycling Criterium', N'Individual', 11, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (28, N'Road Cycling Individual Time Trial', N'Individual', 11, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (29, N'Road Cycling Road Race', N'Individual', 11, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (30, N'1m springboard', N'Individual', 13, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (31, N'3m springboard', N'Individual', 13, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (32, N'Artistic', N'Individual', 13, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (33, N'Platform', N'Individual', 13, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (34, N'1m springboard', N'Individual', 13, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (35, N'3m springboard', N'Individual', 13, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (36, N'Artistic', N'Individual', 13, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (37, N'Platform', N'Individual', 13, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (38, N'Individual Golf', N'Individual', 14, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (39, N'Individual Golf', N'Individual', 14, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (40, N'Team Golf', N'Team', 14, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (41, N'Team Golf', N'Team', 14, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (42, N'Men''s Lacrosse', N'Team', 15, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (43, N'Women''s Lacrosse', N'Team', 15, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (44, N'Single (M1x)', N'Individual', 16, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (45, N'Single (W1x)', N'Individual', 16, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (46, N'Double (M2x)', N'Team', 16, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (47, N'1500m Freestyle', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (48, N'200m Backstroke', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (49, N'200m Breaststroke', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (50, N'200m Butterfly', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (51, N'98 to 120kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (52, N'up to 48kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (53, N'up to 52kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (54, N'up to 56kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (55, N'up to 60kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (56, N'up to 65kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (57, N'up to 70kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (58, N'up to 76kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (59, N'up to 85kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (60, N'up to 98kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (61, N'38 to 40kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (62, N'up to 44kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (63, N'up to 48kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (64, N'up to 52kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (65, N'up to 56kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (66, N'up to 60kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (67, N'up to 64kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (68, N'up to 69kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (69, N'up to 74kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (70, N'up to 79kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (71, N'up to 84kg', N'Individual', 20, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (72, N'40-44kg', N'Individual', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (73, N'Road Cycling Individual Time Trial', N'Individual', 11, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (74, N'Indoor Vollyball', N'Team', 19, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (75, N'Beach Vollyball', N'Team', 2, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (76, N'200m Freestyle', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (77, N'200m IM', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (78, N'3000m Open Water', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (79, N'400m Freestyle', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (80, N'400m IM', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (81, N'50m Backstroke', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (82, N'50m Backstroke - SOC', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (83, N'50m Breaststroke', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (84, N'50m Breaststroke - SOC', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (85, N'50m Butterfly', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (86, N'50m Freestyle', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (87, N'50m Freestyle - SOC', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (88, N'800m Freestyle', N'Individual', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (89, N'4 x 100m Freestyle relay', N'Team', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (90, N'4 x 100m Medley relay', N'Team', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (91, N'4 x 200m Freestyle relay', N'Team', 5, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (92, N'Sprint', N'Individual', 3, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (93, N'Supersprint', N'Individual', 3, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (94, N'Sprint', N'Individual', 3, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (95, N'Supersprint', N'Individual', 3, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (96, N'Beach Vollyball', N'Team', 2, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (97, N'Indoor Vollyball', N'Team', 19, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (98, N'Road Cycling Criterium', N'Individual', 11, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (99, N'Mountain Bike Relay', N'Team', 12, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (100, N'Mountain Bike Relay', N'Team', 12, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (101, N'1500m', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (102, N'100m wheelchair', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (103, N'100m Special Olympics', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (104, N'100m hurdles', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (105, N'100m', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (106, N'Triple Jump', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (107, N'Shot Put', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (108, N'Pole Vault', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (109, N'Para Shot Put', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (110, N'Para Discus', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (111, N'Long Jump', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (112, N'Javelin', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (113, N'High Jump', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (114, N'Hammer', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (115, N'Discus', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (116, N'Decathlon', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (117, N'800m', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (118, N'5000m', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (119, N'400m wheelchair', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (120, N'400m hurdles', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (121, N'400m', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (122, N'1500m wheelchair', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (123, N'3000m steeplechase', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (124, N'200m', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (125, N'3000m steeplechase', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (126, N'Baseball', N'Team', 8, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (127, N'4x400m relay', N'Team', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (128, N'4x100m relay', N'Team', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (129, N'4x400m relay', N'Team', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (130, N'4x100m relay', N'Team', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (131, N'Triple Jump', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (132, N'Shotput', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (133, N'Pole Vault', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (134, N'Para Shot Put', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (135, N'Para Discus', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (136, N'Long Jump', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (137, N'Javelin', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (138, N'High Jump', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (139, N'Heptathlon', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (140, N'Hammer', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (141, N'Discus', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (142, N'800m', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (143, N'5000m', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (144, N'400m wheelchair', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (145, N'400m hurdles', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (146, N'400m', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (147, N'200m Special Olympics', N'Individual', 7, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (148, N'Wrestling', N'Team', 20, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (149, N'200m Special Olympics', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (150, N'1500m wheelchair', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (151, N'IC-4, 200m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (152, N'IC-4, 500m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (153, N'K-2, 1000m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (154, N'K-2, 200m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (155, N'K-2, 500m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (156, N'K-4, 200m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (157, N'K-4, 500m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (158, N'C-2, 1000m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (159, N'C-2, 200m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (160, N'C-2, 500m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (161, N'IC-4, 200m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (162, N'IC-4, 500m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (163, N'K-2, 1000m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (164, N'K-2, 200m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (165, N'K-2, 500m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (166, N'K-4, 200m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (167, N'K-4, 500m', N'Team', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (168, N'Mountain Bike Cross Country', N'Individual', 12, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (169, N'Mountain Bike Sprint', N'Individual', 12, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (170, N'Mountain Bike Cross Country', N'Individual', 12, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (171, N'Mountain Bike Sprint', N'Individual', 12, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (172, N'C-2, 500m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (173, N'200m', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (174, N'C-2, 200m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (175, N'K-1, 500m', N'Individual', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (176, N'1500m', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (177, N'110m hurdles', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (178, N'100m wheelchair', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (179, N'100m Special Olympics', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (180, N'100m', N'Individual', 7, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (181, N'Basketball', N'Team', 9, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (182, N'C-1, 1000m', N'Individual', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (183, N'C-1, 200m', N'Individual', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (184, N'C-1, 5000m', N'Individual', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (185, N'C-1, 500m', N'Individual', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (186, N'K-1, 1000m', N'Individual', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (187, N'K-1, 200m', N'Individual', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (188, N'K-1, 5000m', N'Individual', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (189, N'K-1, 500m', N'Individual', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (190, N'C-1, 1000m', N'Individual', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (191, N'C-1, 200m', N'Individual', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (192, N'C-1, 5000m', N'Individual', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (193, N'C-1, 500m', N'Individual', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (194, N'K-1, 1000m', N'Individual', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (195, N'K-1, 200m', N'Individual', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (196, N'K-1, 5000m', N'Individual', 10, 2)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (197, N'C-2, 1000m', N'Team', 10, 1)
GO
INSERT [dbo].[Event] ([ID], [Name], [Type], [SportID], [GenderID]) VALUES (198, N'Wrestling', N'Team', 20, 2)
GO
SET IDENTITY_INSERT [dbo].[Event] OFF
GO
SET IDENTITY_INSERT [dbo].[Gender] ON 
GO
INSERT [dbo].[Gender] ([ID], [Code], [Name]) VALUES (1, N'M', N'Men')
GO
INSERT [dbo].[Gender] ([ID], [Code], [Name]) VALUES (2, N'W', N'Women')
GO
SET IDENTITY_INSERT [dbo].[Gender] OFF
GO
SET IDENTITY_INSERT [dbo].[Placement] ON 
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (1, 7, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 1, 54)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (2, 6, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 1, 112)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (3, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 1, 28)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (4, 4, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 1, 58)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (5, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 1, 64)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (6, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 1, 100)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (7, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 1, 42)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (8, 6, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 2, 124)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (9, 5, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 2, 96)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (10, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 2, 40)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (11, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 2, 46)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (12, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 2, 116)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (13, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 2, 88)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (14, 6, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 3, 131)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (15, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 3, 105)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (16, 4, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 3, 129)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (17, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 3, 127)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (18, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 3, 45)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (19, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 3, 69)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (20, 6, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 4, 69)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (21, 5, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 4, 105)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (22, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 4, 127)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (23, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 4, 129)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (24, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 4, 45)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (25, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 4, 131)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (26, 6, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 5, 45)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (27, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 5, 131)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (28, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 5, 69)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (29, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 5, 105)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (30, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 5, 129)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (31, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 5, 127)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (32, 6, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 6, 105)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (33, 5, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 6, 129)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (34, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 6, 131)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (35, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 6, 69)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (36, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 6, 45)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (37, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 6, 127)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (38, 6, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 7, 127)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (39, 5, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 7, 131)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (40, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 7, 129)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (41, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 7, 105)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (42, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 7, 69)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (43, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 7, 45)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (44, 6, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 8, 105)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (45, 5, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 8, 127)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (46, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 8, 45)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (47, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 8, 69)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (48, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 8, 129)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (49, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 8, 131)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (50, 4, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 9, 113)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (51, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 9, 43)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (52, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 9, 9)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (53, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 9, 75)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (54, 6, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 11, 88)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (55, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 11, 124)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (56, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 11, 40)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (57, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 11, 46)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (58, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 11, 96)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (59, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 11, 116)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (60, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 12, 41)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (61, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 13, 41)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (62, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 14, 108)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (63, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 14, 118)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (64, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 14, 12)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (65, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 14, 48)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (66, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 15, 93)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (67, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 15, 107)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (68, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 15, 35)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (69, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 15, 111)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (70, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 16, 80)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (71, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 16, 22)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (72, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 16, 4)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (73, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 17, 73)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (74, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 17, 85)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (75, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 17, 57)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (76, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 17, 21)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (77, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 17, 95)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (78, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 18, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (79, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 18, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (80, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 18, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (81, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 19, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (82, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 19, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (83, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 19, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (84, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 20, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (85, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 20, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (86, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 20, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (87, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 21, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (88, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 21, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (89, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 21, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (90, 6, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 23, 88)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (91, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 23, 40)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (92, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 23, 124)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (93, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 23, 116)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (94, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 23, 96)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (95, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 23, 46)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (96, 6, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 24, 40)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (97, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 24, 46)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (98, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 24, 124)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (99, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 24, 96)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (100, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 24, 88)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (101, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 24, 116)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (102, 6, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 25, 124)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (103, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 25, 96)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (104, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 25, 40)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (105, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 25, 116)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (106, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 25, 46)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (107, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 25, 88)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (108, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 26, 102)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (109, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 26, 32)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (110, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 26, 52)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (111, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 27, 33)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (112, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 27, 125)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (113, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 28, 125)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (114, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 28, 33)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (115, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 29, 33)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (116, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 29, 125)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (117, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 30, 106)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (118, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 30, 98)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (119, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 30, 38)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (120, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 31, 98)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (121, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 31, 106)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (122, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 31, 38)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (123, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 32, 98)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (124, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 32, 106)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (125, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 32, 38)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (126, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 33, 106)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (127, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 33, 38)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (128, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 33, 98)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (129, 5, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 34, 19)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (130, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 34, 59)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (131, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 34, 135)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (132, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 34, 101)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (133, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 34, 15)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (134, 5, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 35, 101)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (135, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 35, 15)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (136, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 35, 19)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (137, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 35, 135)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (138, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 35, 59)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (139, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 36, 59)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (140, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 36, 15)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (141, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 36, 19)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (142, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 36, 101)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (143, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 36, 135)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (144, 5, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 37, 101)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (145, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 37, 135)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (146, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 37, 19)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (147, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 37, 15)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (148, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 37, 59)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (149, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 38, 2)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (150, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 38, 130)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (151, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 38, 132)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (152, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 38, 136)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (153, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 39, 55)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (154, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 39, 99)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (155, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 39, 49)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (156, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 39, 117)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (157, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 40, 136)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (158, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 40, 130)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (159, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 40, 132)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (160, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 40, 2)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (161, 4, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 41, 99)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (162, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 41, 55)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (163, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 41, 117)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (164, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 41, 49)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (165, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 42, 114)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (166, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 42, 82)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (167, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 42, 110)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (168, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 43, 81)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (169, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 43, 91)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (170, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 43, 77)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (171, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 43, 27)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (172, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 43, 123)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (173, 6, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 44, 40)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (174, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 44, 96)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (175, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 44, 116)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (176, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 44, 124)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (177, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 44, 88)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (178, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 44, 46)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (179, 6, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 45, 105)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (180, 5, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 45, 45)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (181, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 45, 69)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (182, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 45, 129)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (183, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 45, 131)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (184, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 45, 127)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (185, 6, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 46, 46)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (186, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 46, 124)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (187, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 46, 88)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (188, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 46, 96)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (189, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 46, 116)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (190, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 46, 40)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (191, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 47, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (192, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 47, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (193, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 47, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (194, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 48, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (195, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 48, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (196, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 48, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (197, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 49, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (198, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 49, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (199, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 49, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (200, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 50, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (201, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 50, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (202, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 50, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (203, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 51, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (204, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 51, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (205, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 52, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (206, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 52, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (207, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 53, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (208, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 53, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (209, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 54, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (210, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 54, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (211, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 55, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (212, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 55, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (213, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 56, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (214, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 56, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (215, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 57, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (216, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 57, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (217, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 58, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (218, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 58, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (219, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 59, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (220, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 59, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (221, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 60, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (222, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 60, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (223, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 61, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (224, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 61, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (225, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 62, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (226, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 62, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (227, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 63, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (228, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 63, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (229, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 64, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (230, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 64, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (231, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 65, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (232, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 65, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (233, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 66, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (234, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 66, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (235, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 67, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (236, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 67, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (237, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 68, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (238, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 68, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (239, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 69, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (240, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 69, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (241, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 70, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (242, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 70, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (243, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 71, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (244, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 71, 25)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (245, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 72, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (246, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 72, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (247, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 73, 102)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (248, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 73, 52)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (249, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 73, 32)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (250, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 74, 133)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (251, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 75, 47)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (252, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 75, 89)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (253, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 76, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (254, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 76, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (255, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 76, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (256, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 77, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (257, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 77, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (258, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 77, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (259, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 78, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (260, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 78, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (261, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 78, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (262, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 79, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (263, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 79, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (264, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 79, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (265, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 80, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (266, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 80, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (267, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 80, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (268, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 81, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (269, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 81, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (270, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 81, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (271, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 82, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (272, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 82, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (273, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 82, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (274, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 83, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (275, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 83, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (276, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 83, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (277, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 84, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (278, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 84, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (279, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 84, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (280, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 85, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (281, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 85, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (282, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 85, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (283, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 86, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (284, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 86, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (285, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 86, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (286, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 87, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (287, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 87, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (288, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 87, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (289, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 88, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (290, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 88, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (291, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 88, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (292, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 89, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (293, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 89, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (294, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 89, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (295, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 90, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (296, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 90, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (297, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 90, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (298, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 91, 24)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (299, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 91, 34)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (300, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 91, 134)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (301, 7, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 92, 16)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (302, 6, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 92, 94)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (303, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 92, 50)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (304, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 92, 86)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (305, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 92, 68)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (306, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 92, 8)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (307, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 92, 20)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (308, 7, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 93, 50)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (309, 6, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 93, 68)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (310, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 93, 86)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (311, 4, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 93, 94)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (312, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 93, 20)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (313, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 93, 16)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (314, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 93, 8)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (315, 4, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 94, 51)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (316, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 94, 71)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (317, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 94, 65)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (318, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 94, 83)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (319, 4, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 95, 51)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (320, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 95, 83)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (321, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 95, 71)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (322, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 95, 65)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (323, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 96, 120)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (324, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 96, 44)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (325, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 96, 14)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (326, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 97, 18)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (327, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 97, 70)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (328, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 97, 72)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (329, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 97, 30)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (330, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 98, 32)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (331, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 98, 52)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (332, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 98, 102)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (333, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 99, 37)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (334, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 99, 121)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (335, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 100, 26)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (336, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 100, 122)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (337, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 101, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (338, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 102, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (339, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 103, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (340, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 104, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (341, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 105, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (342, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 106, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (343, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 107, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (344, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 108, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (345, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 109, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (346, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 110, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (347, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 111, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (348, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 112, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (349, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 113, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (350, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 114, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (351, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 115, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (352, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 116, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (353, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 117, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (354, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 118, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (355, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 119, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (356, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 120, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (357, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 121, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (358, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 122, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (359, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 123, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (360, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 124, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (361, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 125, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (362, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 126, 36)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (363, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 126, 104)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (364, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 126, 6)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (365, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 126, 66)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (366, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 126, 60)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (367, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 127, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (368, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 128, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (369, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 129, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (370, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 130, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (371, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 131, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (372, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 132, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (373, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 133, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (374, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 134, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (375, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 135, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (376, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 136, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (377, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 137, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (378, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 138, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (379, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 139, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (380, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 140, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (381, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 141, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (382, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 142, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (383, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 143, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (384, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 144, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (385, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 145, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (386, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 146, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (387, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 147, 29)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (388, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 148, 76)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (389, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 148, 10)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (390, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 149, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (391, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 150, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (392, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 151, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (393, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 152, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (394, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 153, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (395, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 154, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (396, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 155, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (397, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 156, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (398, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 157, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (399, 5, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 158, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (400, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 158, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (401, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 158, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (402, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 158, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (403, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 158, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (404, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 159, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (405, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 159, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (406, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 159, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (407, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 159, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (408, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 159, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (409, 5, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 160, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (410, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 160, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (411, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 160, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (412, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 160, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (413, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 160, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (414, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 161, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (415, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 161, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (416, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 161, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (417, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 161, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (418, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 161, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (419, 5, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 162, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (420, 4, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 162, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (421, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 162, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (422, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 162, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (423, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 162, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (424, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 163, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (425, 4, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 163, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (426, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 163, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (427, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 163, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (428, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 163, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (429, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 164, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (430, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 164, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (431, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 164, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (432, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 164, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (433, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 164, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (434, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 165, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (435, 4, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 165, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (436, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 165, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (437, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 165, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (438, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 165, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (439, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 166, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (440, 4, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 166, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (441, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 166, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (442, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 166, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (443, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 166, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (444, 5, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 167, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (445, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 167, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (446, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 167, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (447, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 167, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (448, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 167, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (449, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 168, 26)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (450, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 168, 122)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (451, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 169, 122)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (452, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 169, 26)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (453, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 170, 121)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (454, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 170, 37)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (455, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 171, 121)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (456, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 171, 37)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (457, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 172, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (458, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 173, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (459, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 174, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (460, 5, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 175, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (461, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 175, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (462, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 175, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (463, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 175, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (464, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 175, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (465, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 176, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (466, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 177, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (467, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 178, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (468, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 179, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (469, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 180, 126)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (470, 8, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 181, 23)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (471, 7, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 181, 109)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (472, 6, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 181, 61)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (473, 5, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 181, 53)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (474, 4, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 181, 79)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (475, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 181, 103)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (476, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 181, 3)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (477, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 181, 87)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (478, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 182, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (479, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 183, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (480, 1, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 184, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (481, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 185, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (482, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 186, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (483, 1, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 187, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (484, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 188, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (485, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 189, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (486, 5, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 190, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (487, 4, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 190, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (488, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 190, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (489, 2, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 190, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (490, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 190, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (491, 5, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 191, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (492, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 191, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (493, 3, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 191, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (494, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 191, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (495, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 191, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (496, 5, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 192, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (497, 4, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 192, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (498, 3, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 192, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (499, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 192, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (500, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 192, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (501, 5, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 193, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (502, 4, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 193, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (503, 3, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 193, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (504, 2, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 193, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (505, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 193, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (506, 5, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 194, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (507, 4, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 194, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (508, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 194, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (509, 2, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 194, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (510, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 194, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (511, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 195, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (512, 4, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 195, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (513, 3, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 195, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (514, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 195, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (515, 1, N'Porchetta pork belly swine filet mignon jowl turducken salami boudin pastrami jerky spare ribs short ribs sausage andouille. Turducken flank ribeye boudin corned beef burgdoggen. Prosciutto pancetta sirloin rump shankle ball tip filet mignon corned beef frankfurter biltong drumstick chicken swine bacon shank. Buffalo kevin andouille porchetta short ribs cow, ham hock pork belly drumstick pastrami capicola picanha venison.', 195, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (516, 5, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 196, 115)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (517, 4, N'Picanha andouille salami, porchetta beef ribs t-bone drumstick. Frankfurter tail landjaeger, shank kevin pig drumstick beef bresaola cow. Corned beef pork belly tri-tip, ham drumstick hamburger swine spare ribs short loin cupim flank tongue beef filet mignon cow. Ham hock chicken turducken doner brisket. Strip steak cow beef, kielbasa leberkas swine tongue bacon burgdoggen beef ribs pork chop tenderloin.', 196, 39)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (518, 3, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 196, 11)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (519, 2, N'Kielbasa porchetta shoulder boudin, pork strip steak brisket prosciutto t-bone tail. Doner pork loin pork ribeye, drumstick brisket biltong boudin burgdoggen t-bone frankfurter. Flank burgdoggen doner, boudin porchetta andouille landjaeger ham hock capicola pork chop bacon. Landjaeger turducken ribeye leberkas pork loin corned beef. Corned beef turducken landjaeger pig bresaola t-bone bacon andouille meatball beef ribs doner. T-bone fatback cupim chuck beef ribs shank tail strip steak bacon.', 196, 119)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (520, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 196, 5)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (521, 1, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 197, 56)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (522, 2, N'Sirloin shank t-bone capicola strip steak salami, hamburger kielbasa burgdoggen jerky swine andouille rump picanha. Sirloin porchetta ribeye fatback, meatball leberkas swine pancetta beef shoulder pastrami capicola salami chicken. Bacon cow corned beef pastrami venison biltong frankfurter short ribs chicken beef. Burgdoggen shank pig, ground round brisket tail beef ribs turkey spare ribs tenderloin shankle ham rump. Doner alcatra pork chop leberkas spare ribs hamburger t-bone. Boudin filet mignon bacon andouille, shankle pork t-bone landjaeger. Rump pork loin bresaola prosciutto pancetta venison, cow flank sirloin sausage.', 198, 1)
GO
INSERT [dbo].[Placement] ([ID], [Place], [Comments], [EventID], [AthleteID]) VALUES (523, 1, N'Bacon ipsum dolor amet meatball corned beef kevin, alcatra kielbasa biltong drumstick strip steak spare ribs swine. Pastrami shank swine leberkas bresaola, prosciutto frankfurter porchetta ham hock short ribs short loin andouille alcatra. Andouille shank meatball pig venison shankle ground round sausage kielbasa. Chicken pig meatloaf fatback leberkas venison tri-tip burgdoggen tail chuck sausage kevin shank biltong brisket.', 198, 25)
GO
SET IDENTITY_INSERT [dbo].[Placement] OFF
GO
SET IDENTITY_INSERT [dbo].[Sport] ON 
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (1, N'SOC', N'Soccer')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (2, N'VBB', N'Volleyball - Beach')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (3, N'TRA', N'Triathlon')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (4, N'TEN', N'Tennis')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (5, N'SWM', N'Swimming')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (6, N'SBA', N'Softball')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (7, N'ATH', N'Athletics')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (8, N'BAB', N'Baseball')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (9, N'BKB', N'Basketball')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (10, N'CKY', N'Canoe Kayak')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (11, N'CYR', N'Cycling - Road Cycling')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (12, N'CYM', N'Cycling - Mountain Bike')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (13, N'DIV', N'Diving')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (14, N'GLF', N'Golf')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (15, N'LAC', N'Lacrosse')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (16, N'ROW', N'Rowing')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (17, N'RGS', N'Rugby Sevens')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (18, N'SAL', N'Sailing')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (19, N'VBI', N'Volleyball - Indoor')
GO
INSERT [dbo].[Sport] ([ID], [Code], [Name]) VALUES (20, N'WRS', N'Wrestling')
GO
SET IDENTITY_INSERT [dbo].[Sport] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Athletes_AthleteCode]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Athletes_AthleteCode] ON [dbo].[Athlete]
(
	[AthleteCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Athletes_ContingentID]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE NONCLUSTERED INDEX [IX_Athletes_ContingentID] ON [dbo].[Athlete]
(
	[ContingentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Athletes_GenderID]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE NONCLUSTERED INDEX [IX_Athletes_GenderID] ON [dbo].[Athlete]
(
	[GenderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AthleteSports_SportID]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE NONCLUSTERED INDEX [IX_AthleteSports_SportID] ON [dbo].[AthleteSport]
(
	[SportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Contingents_Code]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Contingents_Code] ON [dbo].[Contingent]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Events_GenderID]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE NONCLUSTERED INDEX [IX_Events_GenderID] ON [dbo].[Event]
(
	[GenderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Events_SportID]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE NONCLUSTERED INDEX [IX_Events_SportID] ON [dbo].[Event]
(
	[SportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Genders_Code]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Genders_Code] ON [dbo].[Gender]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Placements_AthleteID_EventID]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Placements_AthleteID_EventID] ON [dbo].[Placement]
(
	[AthleteID] ASC,
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Placements_EventID]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE NONCLUSTERED INDEX [IX_Placements_EventID] ON [dbo].[Placement]
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Sports_Code]    Script Date: 8/6/2023 8:28:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Sports_Code] ON [dbo].[Sport]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Athlete]  WITH CHECK ADD  CONSTRAINT [FK_Athletes_Contingents_ContingentID] FOREIGN KEY([ContingentID])
REFERENCES [dbo].[Contingent] ([ID])
GO
ALTER TABLE [dbo].[Athlete] CHECK CONSTRAINT [FK_Athletes_Contingents_ContingentID]
GO
ALTER TABLE [dbo].[Athlete]  WITH CHECK ADD  CONSTRAINT [FK_Athletes_Genders_GenderID] FOREIGN KEY([GenderID])
REFERENCES [dbo].[Gender] ([ID])
GO
ALTER TABLE [dbo].[Athlete] CHECK CONSTRAINT [FK_Athletes_Genders_GenderID]
GO
ALTER TABLE [dbo].[AthleteSport]  WITH CHECK ADD  CONSTRAINT [FK_AthleteSports_Athletes_AthleteID] FOREIGN KEY([AthleteID])
REFERENCES [dbo].[Athlete] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AthleteSport] CHECK CONSTRAINT [FK_AthleteSports_Athletes_AthleteID]
GO
ALTER TABLE [dbo].[AthleteSport]  WITH CHECK ADD  CONSTRAINT [FK_AthleteSports_Sports_SportID] FOREIGN KEY([SportID])
REFERENCES [dbo].[Sport] ([ID])
GO
ALTER TABLE [dbo].[AthleteSport] CHECK CONSTRAINT [FK_AthleteSports_Sports_SportID]
GO
ALTER TABLE [dbo].[Event]  WITH CHECK ADD  CONSTRAINT [FK_Events_Genders_GenderID] FOREIGN KEY([GenderID])
REFERENCES [dbo].[Gender] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Event] CHECK CONSTRAINT [FK_Events_Genders_GenderID]
GO
ALTER TABLE [dbo].[Event]  WITH CHECK ADD  CONSTRAINT [FK_Events_Sports_SportID] FOREIGN KEY([SportID])
REFERENCES [dbo].[Sport] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Event] CHECK CONSTRAINT [FK_Events_Sports_SportID]
GO
ALTER TABLE [dbo].[Placement]  WITH CHECK ADD  CONSTRAINT [FK_Placements_Athletes_AthleteID] FOREIGN KEY([AthleteID])
REFERENCES [dbo].[Athlete] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Placement] CHECK CONSTRAINT [FK_Placements_Athletes_AthleteID]
GO
ALTER TABLE [dbo].[Placement]  WITH CHECK ADD  CONSTRAINT [FK_Placements_Events_EventID] FOREIGN KEY([EventID])
REFERENCES [dbo].[Event] ([ID])
GO
ALTER TABLE [dbo].[Placement] CHECK CONSTRAINT [FK_Placements_Events_EventID]
GO
/****** Object:  StoredProcedure [dbo].[usp_AthleteDelete]    Script Date: 8/6/2023 8:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AthleteDelete] --Delete Procedure
	@ID INT
AS 
BEGIN
	SET NOCOUNT OFF
	DELETE FROM ATHLETE
	WHERE ID = @ID
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AthleteInsert]    Script Date: 8/6/2023 8:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AthleteInsert] --Insert
	@First NVARCHAR(50),
	@Middle NVARCHAR(50),
	@Last NVARCHAR(100),
	@AthleteCode NVARCHAR(7),
	@Dob DATETIME2(7),
	@Height FLOAT,
	@Weight FLOAT,
	@Media NVARCHAR(2000),
	@Email NVARCHAR(150),
    @ContingentID INT,
    @GenderID INT,
    @ID INT OUTPUT
AS
BEGIN 
	SET NOCOUNT OFF
	INSERT INTO ATHLETE (
		FirstName, 
		MiddleName, 
		LastName, 
		AthleteCode, 
		DOB, 
		Height,
		Weight,
        MediaInfo, 
		EMail, 
		ContingentID, 
		GenderID
	)
	VALUES (
		@First, 
		@Middle, 
		@Last, 
		@AthleteCode, 
		@Dob, 
		@Height, 
		@Weight, 
		@Media,
        @Email, 
		@ContingentID, 
		@GenderID
	)
	SELECT @ID = SCOPE_IDENTITY() WHERE @@ROWCOUNT=1
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AthleteSelectAll]    Script Date: 8/6/2023 8:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--2 b) - 5 Standard Stored Procedures
CREATE PROCEDURE [dbo].[usp_AthleteSelectAll] --Select All
AS
BEGIN
	SET NOCOUNT ON
	SELECT   ID, FirstName, MiddleName, LastName, AthleteCode, DOB, Height, Weight, 
		MediaInfo, EMail, RowVersion, ContingentID, GenderID, 
		Summary, Age, Gender, Contingent
	FROM      v_Athlete
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AthleteSelectByID]    Script Date: 8/6/2023 8:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AthleteSelectByID] --Select By ID
	@ID INT
AS
BEGIN 
	SET NOCOUNT ON
	SELECT   ID, FirstName, MiddleName, LastName, AthleteCode, DOB, Height, Weight, 
		MediaInfo, EMail, RowVersion, ContingentID, GenderID, 
		Summary, Age, Gender, Contingent
	FROM      v_Athlete
	WHERE ID = @ID
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AthleteSelectByX]    Script Date: 8/6/2023 8:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2 c) - Select By X (Multiple Criteria)

CREATE PROCEDURE [dbo].[usp_AthleteSelectByX]
	@ContingentID INT = 0,
	@GenderID INT = 0,
	@NameFilter NVARCHAR(255) = NULL,
	@DobMin DATETIME2 = NULL,
	@DobMax DATETIME2 = NULL
AS
BEGIN
	SET NOCOUNT ON
	--SET DATE RANGE
	SET @DobMin = ISNULL(@DobMin,'0001-01-01')
	SET @DobMax = ISNULL(@DobMax,'9999-12-31')

	--Handle NULL text type search string
	SET @NameFilter = ISNULL(@NameFilter,'')

	SELECT   ID, FirstName, MiddleName, LastName, AthleteCode, DOB, Height, Weight, 
		MediaInfo, EMail, RowVersion, ContingentID, GenderID, 
		Summary, Age, Gender, Contingent
	FROM      v_Athlete
	WHERE (ContingentID = @ContingentID OR @ContingentID = 0)
		AND (GenderID = @GenderID OR @GenderID = 0)
		AND (Summary LIKE '%' + @NameFilter + '%' )
		AND (DOB Between @DobMin and @DobMax)
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AthleteUpdate]    Script Date: 8/6/2023 8:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		
CREATE PROCEDURE [dbo].[usp_AthleteUpdate] --Update
	@ID INT,
	@First NVARCHAR(50),
	@Middle NVARCHAR(50),
	@Last NVARCHAR(100),
	@AthleteCode NVARCHAR(7),
	@Dob DATETIME2(7),
	@Height FLOAT,
	@Weight FLOAT,
	@Media NVARCHAR(2000),
	@Email NVARCHAR(150),
    @ContingentID INT,
    @GenderID INT,
	@RowVersion TIMESTAMP
AS
BEGIN 
	SET NOCOUNT OFF
	UPDATE ATHLETE
	SET FirstName = @First,
		MiddleName = @Middle,
		LastName = @Last,
		AthleteCode = @AthleteCode,
		DOB = @Dob,
		Height = @Height,
		Weight = @Weight,
		MediaInfo = @Media,
		EMail = @Email,
		ContingentID = @ContingentID,
		GenderID = @GenderID
	WHERE ID = @ID AND RowVersion = @RowVersion
END
GO
/****** Object:  StoredProcedure [dbo].[usp_ContingentList]    Script Date: 8/6/2023 8:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2 c) - List Style Stored Procedures

CREATE PROCEDURE [dbo].[usp_ContingentList] --Contingent List Style Procedure
AS
BEGIN
	SET NOCOUNT ON
	SELECT ID, Name AS DisplayText
	FROM CONTINGENT
	ORDER BY DisplayText
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GenderList]    Script Date: 8/6/2023 8:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GenderList] --Gender List Style Procedure
AS
BEGIN
	SET NOCOUNT ON
	SELECT ID, Name AS DisplayText
	FROM GENDER
	ORDER BY DisplayText
END
GO
USE [master]
GO
ALTER DATABASE [CanadaSummerGames_Simple] SET  READ_WRITE 
GO
