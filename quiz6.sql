
-- 1.
DECLARE @Count INT
SET @Count = (
    SELECT COUNT(*)
    FROM Invoices
    WHERE (InvoiceTotal - PaymentTotal - CreditTotal) > 5000
)
PRINT CAST(@Count AS VARCHAR) + ' invoices exceed $5,000.'
GO

-- 2. 
DECLARE @InvoiceCount  INT
DECLARE @TotalBalance  MONEY

SELECT @InvoiceCount = COUNT(*),
       @TotalBalance  = SUM(InvoiceTotal - PaymentTotal - CreditTotal)
FROM Invoices
WHERE (InvoiceTotal - PaymentTotal - CreditTotal) > 0

IF @TotalBalance >= 10000
BEGIN
    SELECT v.VendorName,
           i.InvoiceNumber,
           i.InvoiceDueDate,
           (InvoiceTotal - PaymentTotal - CreditTotal) AS Balance
    FROM Vendors v
        JOIN Invoices i ON v.VendorID = i.VendorID
    WHERE (InvoiceTotal - PaymentTotal - CreditTotal) > 0
    ORDER BY InvoiceDueDate ASC

    PRINT 'Number of unpaid invoices is '  + CAST(@InvoiceCount AS VARCHAR) + '.'
    PRINT 'Total balance due is $'         + CAST(@TotalBalance  AS VARCHAR) + '.'
END
ELSE
    PRINT 'Total balance due is less than $10,000.'
GO

-- 3. 
DROP PROCEDURE IF EXISTS spVendorsWithoutInvoices
GO
CREATE PROCEDURE spVendorsWithoutInvoices
    @VendorName VARCHAR(50)         -- required: no default value
AS
    SELECT VendorID, VendorName
    FROM Vendors
    WHERE VendorName LIKE @VendorName
      AND VendorID NOT IN (SELECT VendorID FROM Invoices)
    ORDER BY VendorName
GO

-- Call with 'service'
EXEC spVendorsWithoutInvoices @VendorName = '%service%'
GO
-- Call with 'services'
EXEC spVendorsWithoutInvoices @VendorName = '%services%'
GO

-- 4. 
DROP PROCEDURE IF EXISTS spVendorStateInvTotal
GO
CREATE PROCEDURE spVendorStateInvTotal
    @VendorState     VARCHAR(50) = NULL,    -- optional: defaults to NULL
    @SumInvoiceTotal MONEY       OUTPUT     -- output parameter
AS
    SELECT @SumInvoiceTotal = SUM(InvoiceTotal)
    FROM Invoices i
        JOIN Vendors v ON i.VendorID = v.VendorID
    WHERE VendorState LIKE ISNULL(@VendorState, VendorState)
GO

-- a.
DECLARE @Total MONEY
EXEC spVendorStateInvTotal @SumInvoiceTotal = @Total OUTPUT
PRINT CAST(@Total AS VARCHAR)
GO

-- b. 
DECLARE @Total MONEY
EXEC spVendorStateInvTotal
    @VendorState     = 'tx',
    @SumInvoiceTotal = @Total OUTPUT
PRINT CAST(@Total AS VARCHAR)
GO

-- c. 
DECLARE @Total MONEY
EXEC spVendorStateInvTotal
    @VendorState     = 't%',
    @SumInvoiceTotal = @Total OUTPUT
PRINT CAST(@Total AS VARCHAR)
GO