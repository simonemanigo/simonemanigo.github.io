-- 1. 
DROP VIEW IF EXISTS VendorAddress
GO
CREATE VIEW VendorAddress WITH SCHEMABINDING
AS
SELECT VendorID, VendorAddress1, VendorAddress2, VendorCity, VendorState, VendorZipCode
FROM dbo.Vendors
GO

-- 2. 
SELECT * FROM VendorAddress WHERE VendorID = 4
GO

-- 3. 
DROP VIEW IF EXISTS InvoiceBasic
GO
CREATE VIEW InvoiceBasic
AS
SELECT InvoiceNumber, InvoiceTotal
FROM dbo.Invoices
GO

SELECT * FROM InvoiceBasic
ORDER BY InvoiceTotal DESC
GO

-- 4. 
DROP VIEW IF EXISTS VendorInvoice
GO
CREATE VIEW VendorInvoice
AS
SELECT VendorName, InvoiceNumber, InvoiceTotal
FROM dbo.Vendors v
    JOIN dbo.Invoices i ON v.VendorID = i.VendorID
GO

SELECT * FROM VendorInvoice
WHERE VendorName LIKE '[ANOP]%'
ORDER BY VendorName
GO

-- 5. 
GO
ALTER VIEW VendorInvoice
AS
SELECT VendorName, InvoiceNumber, InvoiceTotal, TermsDescription
FROM dbo.Vendors v
    JOIN dbo.Invoices i ON v.VendorID = i.VendorID
    JOIN dbo.Terms t ON i.TermsID = t.TermsID
GO

SELECT * FROM VendorInvoice
WHERE VendorName LIKE '[ANOP]%'
  AND TermsDescription = 'Net due 10 days'
ORDER BY VendorName
GO

-- 6. 
GO
ALTER VIEW VendorInvoice
AS
SELECT VendorName, InvoiceNumber, InvoiceTotal, TermsDescription,
       (InvoiceTotal - PaymentTotal - CreditTotal) AS Balance
FROM dbo.Vendors v
    JOIN dbo.Invoices i ON v.VendorID = i.VendorID
    JOIN dbo.Terms t ON i.TermsID = t.TermsID
GO

SELECT * FROM VendorInvoice
WHERE VendorName LIKE '[ANOP]%'
  AND TermsDescription = 'Net due 10 days'
ORDER BY VendorName
GO

-- 7. 
DROP VIEW IF EXISTS [InvoiceTotalPlus10%]
GO
CREATE VIEW [InvoiceTotalPlus10%] WITH ENCRYPTION
AS
SELECT InvoiceTotal,
       InvoiceTotal * 0.10                    AS [10Percent],
       InvoiceTotal + InvoiceTotal * 0.10     AS [InvoiceTotalPlus10%]
FROM dbo.Invoices
GO

SELECT * FROM [InvoiceTotalPlus10%]
ORDER BY [InvoiceTotalPlus10%] DESC
GO

-- 8. 
DROP VIEW IF EXISTS InvoicePerVendor
GO
CREATE VIEW InvoicePerVendor
AS
SELECT VendorName,
       COUNT(InvoiceID)  AS InvoiceQty,
       SUM(InvoiceTotal) AS InvoiceSum
FROM dbo.Vendors v
    LEFT JOIN dbo.Invoices i ON v.VendorID = i.VendorID
GROUP BY VendorName
GO

SELECT * FROM InvoicePerVendor
ORDER BY InvoiceQty ASC
GO

-- 9. 
DROP VIEW IF EXISTS Top10PaidInvoices
GO
CREATE VIEW Top10PaidInvoices
AS
SELECT TOP 10
       VendorName,
       MAX(InvoiceDate)  AS LastInvoice,
       SUM(InvoiceTotal) AS SumOfInvoices
FROM dbo.Vendors v
    JOIN dbo.Invoices i ON v.VendorID = i.VendorID
WHERE PaymentDate IS NOT NULL
GROUP BY VendorName
ORDER BY SumOfInvoices DESC
GO

SELECT * FROM Top10PaidInvoices
GO