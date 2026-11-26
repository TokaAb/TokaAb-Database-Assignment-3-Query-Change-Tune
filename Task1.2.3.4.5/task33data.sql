--Task1
CREATE TABLE #Invoices
(
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceNumber] [varchar](30) NOT NULL,
	[StudentId] [bigint] NOT NULL,
	[TermId] [int] NOT NULL,
	[CurrencyCode] [char](3) NOT NULL,
	[IssuedAtUtc] [datetime2](0) NULL,
	[DueAtUtc] [datetime2](0) NULL,
	[TotalAmount] [decimal](12, 2) NOT NULL,
	[PaidAmount] [decimal](12, 2) NOT NULL,
	[CreatedAtUtc] [datetime2](0) NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[Status] [tinyint] NOT NULL,
);
INSERT INTO #Invoices
(
    InvoiceNumber,
    StudentId,
    TermId,
    CurrencyCode,
    IssuedAtUtc,
    DueAtUtc,
    TotalAmount,
    PaidAmount,
    CreatedAtUtc,
    Status
)
SELECT
    InvoiceNumber,
    StudentId,
    TermId,
    CurrencyCode,
    IssuedAtUtc,
    DueAtUtc,
    TotalAmount,
    PaidAmount,
    CreatedAtUtc,
    Status
FROM [finance].[Invoices];

--1.2
SELECT *
FROM
(
    SELECT
        Id,
        InvoiceNumber,
        StudentId AS WhoOwes,
        TotalAmount AS InvoiceAmount,
        PaidAmount,
        TotalAmount - PaidAmount AS RemainingAmount,

        CASE
            WHEN DueAtUtc IS NOT NULL
                 AND TotalAmount > PaidAmount
                 AND DueAtUtc < SYSUTCDATETIME()
            THEN DATEDIFF(DAY, DueAtUtc, SYSUTCDATETIME())
            ELSE 0
        END AS DaysLate,
--1.2
        CASE
            WHEN DueAtUtc IS NOT NULL
                 AND (
                     TotalAmount - PaidAmount > 10000
                     OR DueAtUtc < DATEADD(MONTH, -2, SYSUTCDATETIME())
                 )
            THEN 'Urgent'

            WHEN DueAtUtc IS NOT NULL
                 AND DueAtUtc < DATEADD(MONTH, -1, SYSUTCDATETIME())
            THEN 'Medium'

            ELSE 'Low'
        END AS Priority

    FROM #Invoices
) AS InvoiceReport
--1.3
ORDER BY
    CASE Priority
        WHEN 'Urgent' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END,
    RemainingAmount DESC;



--task2   
--2.1 


CREATE TABLE #NewDepartment
(
    Code VARCHAR(20),
    Name NVARCHAR(200),
    Description NVARCHAR(500),
    IsActive BIT,
    CreatedAtUtc DATETIME2,
    IsDeleted BIT
);

INSERT INTO #NewDepartment
(
    Code,
	Name,
	Description,
    IsActive,
	CreatedAtUtc,
	IsDeleted
)
VALUES
(
    'DSAI',
    'Data Science & Artificial Intelligence',
    'Department of Data Science and Artificial Intelligence',
    1,
    SYSUTCDATETIME(),
    0
);

INSERT INTO academic.Departments
(
    Code,
	Name,
	Description,
    IsActive,
	CreatedAtUtc,
	IsDeleted
)
SELECT
    N.Code,
    N.Name,
    N.Description,
    N.IsActive,
    N.CreatedAtUtc,
    N.IsDeleted
FROM #NewDepartment N

SELECT *
FROM [academic].[Departments]
WHERE Code = 'DSAI';



  -- 2.2 

CREATE TABLE #NewCourse
(
    DepartmentId INT,
    Code VARCHAR(20),
    Title NVARCHAR(200),
    Description NVARCHAR(500),
    CreditHours DECIMAL(4,2),
    PassingScore DECIMAL(5,2),
    IsActive BIT,
    CreatedAtUtc DATETIME2
);

INSERT INTO #NewCourse
(
    DepartmentId,
    Code,
    Title,
    Description,
    CreditHours,
    PassingScore,
    IsActive,
    CreatedAtUtc
)
SELECT
    D.Id,
    'DSAI-101',
    'Introduction to Data Analysis',
    'Introduction to Data Analysis course',
    3,
    60,
    1,
    SYSUTCDATETIME()
FROM [academic].[Departments] D
WHERE D.Code = 'DSAI';

INSERT INTO [academic].[Courses]
(
    DepartmentId,
    Code,
    Title,
    Description,
    CreditHours,
    PassingScore,
    IsActive,
    CreatedAtUtc
)
SELECT
    N.DepartmentId,
    N.Code,
    N.Title,
    N.Description,
    N.CreditHours,
    N.PassingScore,
    N.IsActive,
    N.CreatedAtUtc
FROM #NewCourse N

SELECT *
FROM [academic].[Courses]
WHERE Code = 'DSAI-101';

--2.3


CREATE TABLE #NewTerm
(
    AcademicYear SMALLINT,
    TermCode VARCHAR(20),
    Name NVARCHAR(200),
    StartDate DATE,
    EndDate DATE,
    RegistrationStartDate DATE,
    RegistrationEndDate DATE,
    Status TINYINT
);

INSERT INTO #NewTerm
(
    AcademicYear,
    TermCode,
    Name,
    StartDate,
    EndDate,
    RegistrationStartDate,
    RegistrationEndDate,
    Status
)
VALUES
(
    2027,
    'Summer',
    'Summer 2027',
    '2027-06-15',
    '2027-08-31',
    '2027-05-01',
    '2027-06-10',
    1
);

INSERT INTO [delivery].[AcademicTerms]
(
    AcademicYear,
    TermCode,
    Name,
    StartDate,
    EndDate,
    RegistrationStartDate,
    RegistrationEndDate,
    Status
)
SELECT
    N.AcademicYear,
    N.TermCode,
    N.Name,
    N.StartDate,
    N.EndDate,
    N.RegistrationStartDate,
    N.RegistrationEndDate,
    N.Status
FROM #NewTerm N

SELECT *
FROM delivery.AcademicTerms
WHERE AcademicYear = 2027
  AND TermCode = 'Summer';



--2.4

CREATE TABLE #NewAnnouncement
(
    SectionId BIGINT,
    Title NVARCHAR(400),
    Body NVARCHAR(MAX),
    PublishedAtUtc DATETIME2,
    ExpiresAtUtc DATETIME2,
    CreatedByUserId BIGINT,
    CreatedAtUtc DATETIME2,
    UpdatedAtUtc DATETIME2,
    Status TINYINT
);

INSERT INTO #NewAnnouncement
(
    SectionId,
    Title,
    Body,
    PublishedAtUtc,
    ExpiresAtUtc,
    CreatedByUserId,
    CreatedAtUtc,
    UpdatedAtUtc,
    Status
)
SELECT
    NULL,
    'Summer 2027 Registration',
    'Summer 2027 registration opens on May 1, 2027.',
    '2027-05-01',
    NULL,
    U.Id,
    SYSUTCDATETIME(),
    SYSUTCDATETIME(),
    1
FROM [identity].[Users] U
WHERE U.Email = 'it.admin@northbridge.edu';

SELECT *
FROM #NewAnnouncement;


INSERT INTO communication.Announcements
(
    SectionId,
    Title,
    Body,
    PublishedAtUtc,
    ExpiresAtUtc,
    CreatedByUserId,
    CreatedAtUtc,
    UpdatedAtUtc,
    Status
)
SELECT
    N.SectionId,
    N.Title,
    N.Body,
    N.PublishedAtUtc,
    N.ExpiresAtUtc,
    N.CreatedByUserId,
    N.CreatedAtUtc,
    N.UpdatedAtUtc,
    N.Status
FROM #NewAnnouncement N


SELECT *
FROM communication.Announcements
WHERE Title = 'Summer 2027 Registration';


--2.5


CREATE TABLE #NewRole
(
    Code VARCHAR(50),
    Name NVARCHAR(100),
    Description NVARCHAR(300),
    IsSystem BIT,
    IsDeleted BIT
);

INSERT INTO #NewRole
(
    Code,
    Name,
    Description,
    IsSystem,
    IsDeleted
)
VALUES
(
    'TA',
    'Teaching Assistant',
    'Teaching Assistant Role',
    0,
    0
);

INSERT INTO [identity].[Roles]
(
    Code,
    Name,
    Description,
    IsSystem,
    IsDeleted
)
SELECT
    N.Code,
    N.Name,
    N.Description,
    N.IsSystem,
    N.IsDeleted
FROM #NewRole N

SELECT *
FROM [identity].[Roles]
WHERE Code = 'TA';


--Task3

--3.1
CREATE SEQUENCE finance.InvoiceNumberSequence
    AS BIGINT
    START WITH 1
    INCREMENT BY 1;

DECLARE @NextNumber BIGINT;
SET @NextNumber = NEXT VALUE FOR finance.InvoiceNumberSequence;

SELECT
    'LAB-INV-2026-' +
    RIGHT('000000' + CAST(@NextNumber AS VARCHAR(20)), 6)
    AS InvoiceNumber;



--3.2
DECLARE @NextNumberr BIGINT;
DECLARE @InvoiceNumber VARCHAR(50);

SET @NextNumberr = NEXT VALUE FOR finance.InvoiceNumberSequence;

SET @InvoiceNumber =
    'LAB-INV-2026-' +
    RIGHT('000000' + CAST(@NextNumberr AS VARCHAR(20)), 6);

INSERT INTO [finance].[Invoices]
(
    InvoiceNumber,
    StudentId,
    TermId,
    CurrencyCode,
    IssuedAtUtc,
    DueAtUtc,
    TotalAmount,
    PaidAmount,
    CreatedAtUtc,
    Status
)
VALUES
(
    @InvoiceNumber,
    304,
    12,
    'EGP',
    GETUTCDATE(),
    DATEADD(DAY, 30, GETUTCDATE()),
    4500,
    0,
    GETUTCDATE(),
    1
);



--3.3
BEGIN TRANSACTION;

SELECT NEXT VALUE FOR [finance].[InvoiceNumberSequence];

ROLLBACK TRANSACTION;



--Task4

DECLARE @OldTermId INT;
DECLARE @NewTermId INT;

SELECT TOP 1
    @OldTermId = Id
FROM [delivery].[AcademicTerms]
ORDER BY EndDate DESC;

SELECT
    @NewTermId = Id
FROM [delivery].[AcademicTerms]
WHERE AcademicYear = 2027
  AND Name LIKE '%Summer%';

INSERT INTO [delivery].[Sections]
(
    CourseId,
    TermId,
    SectionCode,
    Capacity,
    Location,
    CreatedAtUtc,
    DeliveryMode,
    Status
)
SELECT
    CourseId,
    @NewTermId,
    SectionCode,
    Capacity,
    Location,
    SYSUTCDATETIME(),
    DeliveryMode,
    Status
FROM [delivery].[Sections]
WHERE TermId = @OldTermId;

SELECT *
FROM [delivery].[Sections]
WHERE TermId = @NewTermId
ORDER BY Id;





--task5

-- 5.1
SELECT
    Code AS [Course Code],
    Title ,
    CreditHours 
FROM [academic].[Courses]
ORDER BY
    CreditHours DESC,
    Title ASC;


-- 5.2
SELECT TOP 5 *
FROM [delivery].[Enrollments]
ORDER BY NEWID();


-- 5.3
SELECT *
FROM [identity].[Users]
WHERE Email LIKE ' %'
   OR DATALENGTH(Email) >
      DATALENGTH(RTRIM(Email));



-- 5.4
SELECT *
FROM [identity].[Users]
WHERE Email COLLATE Latin1_General_100_BIN2
   <> LOWER(Email) COLLATE Latin1_General_100_BIN2;



-- 5.5
SELECT *
FROM [identity].[Users]
WHERE Email NOT LIKE '%@%'
   OR Email LIKE '@%'
   OR Email NOT LIKE '%@%.%';



-- 5.6
SELECT DISTINCT
    SUBSTRING(
        Email,
        CHARINDEX('@', Email) + 1,
        LEN(Email)
    ) AS EmailProvider
FROM [identity].[Users]
WHERE Email LIKE '%@%'
ORDER BY EmailProvider ASC;



-- 5.7
SELECT *
FROM [identity].[Users]
ORDER BY LastLoginAtUtc DESC;



-- 5.8
SELECT *
FROM [finance].[Payments]
WHERE PaidAtUtc >= '2026-10-01'
  AND PaidAtUtc < '2026-11-01';



  
-- 5.9
SELECT
    PaymentMethodId,
    Amount,
    PaidAtUtc AT TIME ZONE 'UTC'
        AT TIME ZONE 'Egypt Standard Time' AS CairoPaymentTime
FROM [finance].[Payments]
WHERE CONVERT(
    TIME,
    PaidAtUtc AT TIME ZONE 'UTC'
        AT TIME ZONE 'Egypt Standard Time'
) >= '00:00:00'
AND CONVERT(
    TIME,
    PaidAtUtc AT TIME ZONE 'UTC'
        AT TIME ZONE 'Egypt Standard Time'
) < '05:00:00';



-- 5.10
SELECT *
FROM [attendance].[AttendanceSessions]
WHERE DATENAME(WEEKDAY, SessionDate) = 'Friday';


--5.11
SELECT *
FROM [identity].[Users]
WHERE
 REPLACE(
        REPLACE(
            REPLACE(PhoneNumber, ' ', ''),
            '-', ''
        ),
        '+', ''
    ) LIKE '010%'
OR REPLACE(REPLACE(REPLACE(PhoneNumber, ' ', ''), '-', ''), '+', '') LIKE '011%'
OR REPLACE(REPLACE(REPLACE(PhoneNumber, ' ', ''), '-', ''), '+', '') LIKE '012%'
OR REPLACE(REPLACE(REPLACE(PhoneNumber, ' ', ''), '-', ''), '+', '') LIKE '015%';




-- 5.12
SELECT
    PhoneNumber,
    LEFT(PhoneNumber, 3)
    + REPLICATE('*', LEN(PhoneNumber) - 5)
    + RIGHT(PhoneNumber, 2) AS MaskedPhoneNumber
FROM [identity].[Users]
WHERE LEN(PhoneNumber) >= 5;





-- 5.13
SELECT
    InvoiceNumber,
    TRY_CONVERT(
        BIGINT,
        RIGHT(
            InvoiceNumber,
            CHARINDEX('-', REVERSE(InvoiceNumber)) - 1
        )
    ) AS RunningNumber
FROM [finance].[Invoices]
ORDER BY RunningNumber ASC;


-- 5.14
SELECT
    ID,
    Title,
    CASE
        WHEN EstimatedMinutes IS NULL
            THEN 'Not set'
        ELSE CONCAT(
            EstimatedMinutes / 60,
            ' h ',
            EstimatedMinutes % 60,
            ' min'
        )
    END AS LessonDuration
FROM [content].[Lessons];



-- 5.15
SELECT *
FROM [communication].[Announcements]
WHERE Title LIKE '%[%]%';



-- 5.16
SELECT TOP 5 WITH TIES *
FROM [finance].[Invoices]
ORDER BY TotalAmount DESC;



-- 5.17
SELECT TOP 10 PERCENT *
FROM [finance].[Payments]
ORDER BY Amount DESC;



-- 5.18
SELECT *
FROM [delivery].[Sections]
WHERE Location <> 'Hall A'
   OR Location IS NULL;



   
-- 5.19
SELECT
    ID,
    TotalAmount,
    PaidAmount,

    TotalAmount - PaidAmount AS AmountOwed,

    CASE
        WHEN PaidAmount = 0 THEN 'Not Paid'
        ELSE 'Partially Paid'
    END AS PaymentStatus,

    CASE
        WHEN DueAtUtc < GETDATE() THEN 'Overdue'
        ELSE 'Not Overdue'
    END AS OverdueStatus,

    CAST(
        COALESCE(
            PaidAmount * 100.0 / NULLIF(TotalAmount, 0),
            0
        )
        AS DECIMAL(5,1)
    ) AS PaidPercentage

FROM [finance].[Invoices]

WHERE TotalAmount - PaidAmount > 0

ORDER BY AmountOwed DESC;




-- 5.20
SELECT *
FROM [identity].[Users]
ORDER BY CreatedAtUtc DESC, ID DESC
OFFSET 40 ROWS
FETCH NEXT 20 ROWS ONLY;


-- 5.21
DECLARE @LastSeenID INT = 500000;
SELECT TOP 50 *
FROM [operations].[AuditLogs]
WHERE ID > @LastSeenID
ORDER BY ID ASC;



-- 5.22
SELECT TOP 10 *
FROM [finance].[Payments]
ORDER BY
    PaidAtUtc DESC,
    ID DESC;


	

-- 5.23
SELECT TOP 10
    UPPER(LTRIM(RTRIM(Title))) AS LessonTitle,

    LEN(LTRIM(RTRIM(Title))) AS TitleLength,

    CASE
        WHEN MAX(EstimatedMinutes) IS NULL
            THEN 'Not set'

        WHEN MAX(EstimatedMinutes) <= 15
            THEN 'Quick'

        WHEN MAX(EstimatedMinutes) <= 45
            THEN 'Standard'

        ELSE 'Long'
    END AS LessonCategory

FROM [content].[Lessons]

WHERE IsPublished = 1
  AND LEN(LTRIM(RTRIM(Title))) > 40

GROUP BY
    UPPER(LTRIM(RTRIM(Title))),
    LEN(LTRIM(RTRIM(Title)))

ORDER BY
    LEN(LTRIM(RTRIM(Title))) DESC,
    UPPER(LTRIM(RTRIM(Title))) ASC;



-- 5.24
SELECT TOP 12

    CONVERT(CHAR(7),
	DueatUtc, 120) AS DueMonth,
    CurrencyCode,
  CASE
        WHEN PaidAmount = 0
            THEN 'Not Paid'
        ELSE 'Partially Paid'
    END AS PaymentState,
    COUNT(*) AS InvoiceCount,
    SUM(TotalAmount - PaidAmount) AS TotalOutstanding

FROM [finance].[Invoices]

WHERE DueatUtc < GETDATE()
  AND TotalAmount > PaidAmount

GROUP BY
    CONVERT(CHAR(7), DueatUtc, 120),
    CurrencyCode,
    CASE
        WHEN PaidAmount = 0
            THEN 'Not Paid'
        ELSE 'Partially Paid'
    END
ORDER BY DueMonth DESC;




