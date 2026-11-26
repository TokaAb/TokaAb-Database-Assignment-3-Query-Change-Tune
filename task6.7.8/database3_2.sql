--Task7

CREATE INDEX IX_Users_Email ON [identity].[Users] (Email) INCLUDE (FirstName, LastName);
CREATE INDEX IX_Users_LastName ON [identity].[Users] (LastName) INCLUDE (FirstName, Email);
CREATE INDEX IX_Users_CreatedAtUtc ON [identity].[Users] (CreatedAtUtc) INCLUDE (Email);
CREATE INDEX IX_Payments_PaidAtUtc ON finance.Payments (PaidAtUtc) INCLUDE (InvoiceId, Amount);
CREATE INDEX IX_Invoices_Number ON finance.Invoices (InvoiceNumber);--7.1SELECT Id, Email
FROM [identity].[Users]
WHERE CreatedAtUtc >= '2026-03-01'
AND CreatedAtUtc < '2026-04-01';



--7.2
SELECT Id, InvoiceId, Amount
FROM finance.Payments
WHERE PaidAtUtc >= DATEADD(DAY, -30, SYSUTCDATETIME());


--7.3
SELECT Id, FirstName, LastName
FROM [identity].[Users]
WHERE LastName LIKE N'Abd%';

--7.4
SELECT *
FROM operations.AuditLogs
WHERE Id = 50000;


--7.5
SELECT Id, TotalAmount, PaidAmount
FROM finance.Invoices
WHERE InvoiceNumber
 = 'LAB-INV-2026-000001';



 --7.6
DECLARE @Email NVARCHAR(320) = N'...';
SELECT Id, FirstName, LastName
FROM [identity].[Users]
WHERE Email = @Email;



--7.7
DECLARE @LastName NVARCHAR(100) = N'Hassan';
SELECT Id, FirstName, Email
FROM [identity].[Users]
WHERE (@LastName IS NULL
OR LastName = @LastName)
OPTION (RECOMPILE);


--7.8
--slow query
SELECT *
FROM [content].[Lessons]
WHERE YEAR(PublishedAtUtc) = 2026;


--fast query
SELECT *
FROM content.Lessons
WHERE PublishedAtUtc >= '2026-01-01'
AND PublishedAtUtc < '2027-01-01';




--Task8

--warning tempdb to spill
SELECT
    Id,
    ActorUserId,
    ActionCode,
    EntityKey,
    OccurredAtUtc
FROM operations.AuditLogs
ORDER BY
    EntityKey,
    OccurredAtUtc DESC,
    ActionCode
OPTION (MAX_GRANT_PERCENT = 1);

--fix

SELECT
    Id,
    ActorUserId,
    ActionCode,
    EntityKey,
    OccurredAtUtc
FROM operations.AuditLogs
ORDER BY
    EntityKey,
    OccurredAtUtc DESC,
    ActionCode
OPTION (MAX_GRANT_PERCENT = 100);





