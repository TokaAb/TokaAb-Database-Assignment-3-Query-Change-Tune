--task 11


UPDATE academic.Courses
SET PassingScore = 65
WHERE Code LIKE 'DSAI%';


--11.2
UPDATE[delivery].[Enrollments]
SET FinalGrade =
    CASE
        WHEN FinalScore >= 90 THEN 'A'
        WHEN FinalScore >= 80 THEN 'B'
        WHEN FinalScore >= 70 THEN 'C'
        WHEN FinalScore >= 60 THEN 'D'
        ELSE 'F'
    END
WHERE CompletedAtUtc IS NOT NULL
  AND FinalScore IS NOT NULL;


  --11.3
  SELECT *
FROM[identity].[Roles]
WHERE Name = N'Teaching Assistant';
BEGIN TRANSACTION;

DELETE FROM [identity].[Roles]
WHERE Id =
(
    SELECT Id
    FROM [identity].[Roles]
    WHERE Name = N'Teaching Assistant'
);

DELETE FROM [identity].[Roles]
WHERE Name = N'Teaching Assistant';

COMMIT TRANSACTION;

--11.4
CREATE TABLE finance.PaymentStaging
(
    InvoiceId BIGINT,
    PaymentMethodId TINYINT,
    Amount DECIMAL(18,2),
    CurrencyCode CHAR(3),
    ExternalReference NVARCHAR(100),
    PaidAtUtc DATETIME2
);

INSERT INTO finance.PaymentStaging
(
    InvoiceId,
    PaymentMethodId,
    Amount,
    CurrencyCode,
    ExternalReference,
    PaidAtUtc
)
VALUES
(1, 1, 500.00, 'EGP', 'PAY-001', SYSUTCDATETIME()),
(2, 2, 750.00, 'EGP', 'PAY-002', SYSUTCDATETIME()),
(3, 1, 300.00, 'EGP', 'PAY-003', SYSUTCDATETIME());

TRUNCATE TABLE finance.PaymentStaging;

--Task12
CREATE TABLE academic.PassingScoreHistory
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CourseId INT,
    OldPassingScore DECIMAL(5,2),
    NewPassingScore DECIMAL(5,2),
    ChangedAtUtc DATETIME2,
    ChangedBy NVARCHAR(128)
);

DECLARE @ChangedBy NVARCHAR(128) = SUSER_SNAME();

UPDATE academic.Courses
SET PassingScore = 65
OUTPUT
    INSERTED.Id,
    DELETED.PassingScore,
    INSERTED.PassingScore,
    SYSUTCDATETIME(),
    @ChangedBy
INTO academic.PassingScoreHistory
(
    CourseId,
    OldPassingScore,
    NewPassingScore,
    ChangedAtUtc,
    ChangedBy
)
WHERE DepartmentId = 1;


--12.2

  SELECT *
INTO communication.AnnouncementsArchive
FROM communication.Announcements
WHERE 1 = 0;

DELETE FROM communication.Announcements
OUTPUT DELETED.*
INTO communication.AnnouncementsArchive
WHERE ExpiresAtUtc < DATEADD(MONTH, -6, SYSUTCDATETIME());




--Tak13

SELECT TOP (0)
    Id AS CourseId,
    Code,
    Title,
    CreditHours,
    CAST(1 AS BIT) AS IsVisible
INTO dbo.WebsiteCourseCatalog
FROM academic.Courses;



MERGE dbo.WebsiteCourseCatalog AS Target
USING academic.Courses AS Source
ON Target.CourseId = Source.Id

WHEN MATCHED AND
(
    EXISTS
    (
        SELECT Target.Code, Target.Title, Target.CreditHours, Target.IsVisible
        EXCEPT
        SELECT Source.Code, Source.Title, Source.CreditHours, Source.IsActive
    )
)
THEN UPDATE SET
    Target.Code = Source.Code,
    Target.Title = Source.Title,
    Target.CreditHours = Source.CreditHours,
    Target.IsVisible = Source.IsActive

WHEN NOT MATCHED BY TARGET AND Source.IsActive = 1
THEN INSERT (CourseId, Code, Title, CreditHours, IsVisible)
VALUES (Source.Id, Source.Code, Source.Title, Source.CreditHours, 1)

OUTPUT $action AS ActionType; 