--ÔN TẬP
--A. TẠO VIEW A_VIEW HIỂN THỊ TÊN VÀ SỐ TIỀN MUA CỦA 5 CỬA HÀNG MUA NHIỀU NHẤT THEO NĂM ĐÃ CHO.
CREATE VIEW A_VIEW
AS
SELECT TOP(5)V.Name, SUM(POH.SubTotal) AS TONGTIEN
FROM Purchasing.PurchaseOrderHeader AS POH
     INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID AND POH.VendorID=V.BusinessEntityID
     INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POH.PurchaseOrderID=POD.PurchaseOrderID AND POH.PurchaseOrderID=POD.PurchaseOrderID
GROUP BY V.Name
HAVING(SUM(POH.SubTotal)IN(SELECT TOP(5)SUM(POH.SubTotal) AS TONGTIEN
                           FROM Purchasing.PurchaseOrderHeader AS POH
                                INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID AND POH.VendorID=V.BusinessEntityID
                                INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POH.PurchaseOrderID=POD.PurchaseOrderID AND POH.PurchaseOrderID=POD.PurchaseOrderID
                           GROUP BY V.Name
                           ORDER BY TONGTIEN))
GO
SELECT * FROM A_VIEW
GO
DROP VIEW A_VIEW
GO
--ORDER BY TONGTIEN DESC
--B. TẠO THỦ TỤC B_PROC HIỂN THỊ TÊN VÀ SỐ TIỀN MUA CỦA CỬA HÀNG THEO THAM SỐ ĐẦU VÀO LÀ NĂM ĐÃ CHO.
CREATE PROC B_PROC @NAM INT
AS BEGIN
    SELECT V.Name, SUM(POH.SubTotal) AS TONGTIEN
    FROM Purchasing.PurchaseOrderHeader AS POH
         INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID AND POH.VendorID=V.BusinessEntityID
         INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POH.PurchaseOrderID=POD.PurchaseOrderID AND POH.PurchaseOrderID=POD.PurchaseOrderID
    WHERE YEAR(POH.OrderDate)=@NAM
    GROUP BY V.Name
END
GO
EXEC B_PROC 2005
GO
--C. TẠO THỦ TỤC C_PROC CÓ THAM SỐ ĐẦU VÀO LÀ NĂM ĐÃ CHO VÀ TÊN CỬA HÀNG, THAM SỐ ĐẦU RA LÀ SỐ TIỀN MUA CỦA CỬA HÀNG.
CREATE PROC C_PROC @NAM INT, @TEN NVARCHAR(50), @TONGTIEN MONEY OUT
AS BEGIN
	SELECT @TONGTIEN = SUM(POH.SubTotal)
    FROM Purchasing.PurchaseOrderHeader AS POH
         INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID AND POH.VendorID=V.BusinessEntityID
         INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POH.PurchaseOrderID=POD.PurchaseOrderID AND POH.PurchaseOrderID=POD.PurchaseOrderID
    WHERE YEAR(POH.OrderDate)=@NAM AND V.Name = @TEN
    GROUP BY V.Name
END
GO

DROP PROC C_PROC
GO

DECLARE @NAM INT, @TEN NVARCHAR(50), @TONGTIEN MONEY
SET @NAM = 2005
SET @TEN = N'Advanced Bicycles'
EXEC C_PROC @NAM, @TEN,  @TONGTIEN OUT
PRINT '' + CONVERT(CHAR(10), @TONGTIEN)
GO

--D. TẠO HÀM D_FUNC CÓ THAM SỐ LÀ NĂM ĐÃ CHO VÀ TÊN CỦA CỬA HÀNG. HÀM TRẢ VỀ SỐ TIỀN MUA CỦA CỬA HÀNG (DÙNG SCALAR FUNCTION).
CREATE FUNCTION D_FUNC(@NAM INT, @TEN NVARCHAR(50))
RETURNS INT
AS BEGIN
	DECLARE @TONGTIEN MONEY
	SELECT @TONGTIEN = SUM(POH.SubTotal)
    FROM Purchasing.PurchaseOrderHeader AS POH
         INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID AND POH.VendorID=V.BusinessEntityID
         INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POH.PurchaseOrderID=POD.PurchaseOrderID AND POH.PurchaseOrderID=POD.PurchaseOrderID
    WHERE YEAR(POH.OrderDate)=@NAM AND V.Name = @TEN
    GROUP BY V.Name
	RETURN @TONGTIEN
END

SELECT DBO.D_FUNC(2005, 'Advanced Bicycles')

--E. TẠO HÀM E_FUNC CÓ THAM SỐ LÀ NĂM ĐÃ CHO. HÀM TRẢ VỀ DANH SÁCH GỒM TÊN CỦA CỬA HÀNG VÀ SỐ TIỀN MUA (DÙNG INLINE TABLE VALUED FUNCTION).
CREATE FUNCTION E_FUNC(@NAM INT)
RETURNS TABLE
AS RETURN(
	SELECT V.Name, SUM(POH.SubTotal) AS TONGTIEN
    FROM Purchasing.PurchaseOrderHeader AS POH
         INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID AND POH.VendorID=V.BusinessEntityID
         INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POH.PurchaseOrderID=POD.PurchaseOrderID AND POH.PurchaseOrderID=POD.PurchaseOrderID
    WHERE YEAR(POH.OrderDate)=@NAM
    GROUP BY V.Name)

SELECT * FROM DBO.E_FUNC(2005)
GO

--F. TẠO HÀM F_FUNC CÓ THAM SỐ LÀ NĂM ĐÃ CHO. HÀM TRẢ VỀ DANH SÁCH GỒM TÊN CỦA CỬA HÀNG VÀ SỐ TIỀN MUA (DÙNG MULTI STATEMENT TABLE FUNCTION).
CREATE FUNCTION F_FUNC(@NAM INT)
RETURNS @TABLE_FUNC TABLE (TEN NVARCHAR(50), TONGTIEN MONEY)
AS BEGIN
	INSERT INTO @TABLE_FUNC
	SELECT V.Name, SUM(POH.SubTotal)
    FROM Purchasing.PurchaseOrderHeader AS POH
         INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID AND POH.VendorID=V.BusinessEntityID
         INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POH.PurchaseOrderID=POD.PurchaseOrderID AND POH.PurchaseOrderID=POD.PurchaseOrderID
    WHERE YEAR(POH.OrderDate)=@NAM
    GROUP BY V.Name
	RETURN
END
GO

SELECT * FROM DBO.F_FUNC(2005)