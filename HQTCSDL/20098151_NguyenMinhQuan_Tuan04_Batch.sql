--I) BATCH
--1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm 
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt hàng”
DECLARE @tongsoHD INT
SELECT @tongsoHD=COUNT(SOH.SalesOrderID)
FROM Production.Product AS P
     INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE P.ProductID=778
GROUP BY P.ProductID
IF @tongsoHD>500 
	PRINT N'Sản phẩm 778 có trên 500 hóa đơn.' 
ELSE 
	PRINT N'Sản phẩm 778 có ít đơn đặt hàng.'
GO
--NÂNG CẤP 1

DECLARE @tongsoHD INT, @maHD INT
SET @maHD = 777
SELECT @tongsoHD=COUNT(SOH.SalesOrderID)
FROM Production.Product AS P
     INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE P.ProductID=@maHD
GROUP BY P.ProductID
IF @tongsoHD>500 
	PRINT N'Sản phẩm ' + CONVERT(CHAR(5), @maHD) + N' có trên 500 hóa đơn, cụ thể là ' + CONVERT(CHAR(5), @tongsoHD) 
ELSE 
	PRINT N'Sản phẩm ' + CONVERT(CHAR(5), @maHD) + N' có ít đơn đặt hàng, cụ thể là ' + CONVERT(CHAR(5), @tongsoHD)

GO
--NÂNG CẤP 2
DECLARE @tongsoHD INT, @maSP INT
SET @maSP=24696
IF EXISTS (SELECT * FROM Production.Product AS P WHERE P.ProductID=@maSP)BEGIN
    SELECT @tongsoHD=COUNT(SOH.SalesOrderID)
    FROM Production.Product AS P
         INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
         INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
    WHERE P.ProductID=@maSP
    GROUP BY P.ProductID
    IF @tongsoHD>500
        PRINT N'Sản phẩm '+CONVERT(CHAR(5), @maSP)+N' có trên 500 hóa đơn, cụ thể là '+CONVERT(CHAR(5), @tongsoHD)
    ELSE
        PRINT N'Sản phẩm '+CONVERT(CHAR(5), @maSP)+N' có ít đơn đặt hàng, cụ thể là '+CONVERT(CHAR(5), @tongsoHD)
END
ELSE PRINT N'Không có mã sản phẩm này '+CONVERT(CHAR(10), @maSP)

--2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách 
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2004), nếu
--@n>0 thì in ra chuỗi: “Khách hàng có @n hóa đơn trong năm 2004” ngược lại 
--nếu @n=0 thì in ra chuỗi “Khách hàng không có hóa đơn nào trong năm 2004”
DECLARE @maKH INT, @n INT, @nam INT
SET @maKH=1
SET @nam=2005
IF EXISTS (SELECT * FROM Sales.Customer AS C WHERE @maKH=C.CustomerID)BEGIN
    SELECT @n=COUNT(SOH.SalesOrderID)
    FROM Sales.Customer AS C
         INNER JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID=SOH.CustomerID
    WHERE C.CustomerID=@maKH AND YEAR(SOH.OrderDate)=@nam
    IF @n>0
        PRINT N'Khách hàng có '+CONVERT(CHAR(10), @n)+N' hóa đơn trong năm '+CONVERT(CHAR(4), @nam)
    ELSE
        PRINT N'Khách hàng không có hóa đơn nào trong năm '+CONVERT(CHAR(4), @nam)
END
ELSE PRINT N'Mã khách hàng '+CONVERT(CHAR(10), @maKH)+N' không tồn tại'


--Tìm dữ liệu test
SELECT *
FROM Sales.Customer AS C
     INNER JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID=SOH.CustomerID
WHERE YEAR(SOH.OrderDate)=2005

GO

--3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng 
--tiền>100000, thông tin gồm [SalesOrderID], Subtotal=sum([LineTotal]), 
--Discount (tiền giảm), với Discount được tính như sau:
-- Những hóa đơn có Subtotal<100000 thì không giảm,
-- Subtotal từ 100000 đến <120000 thì giảm 5% của Subtotal
-- Subtotal từ 120000 đến <150000 thì giảm 10% của Subtotal
-- Subtotal từ 150000 trở lên thì giảm 15% của Subtotal
--(Gợi ý: Dùng cấu trúc Case… When …Then …)

--GIẢM XUỐNG 2 SỐ 0 MỚI CÓ KẾT QUẢ
SELECT SalesOrderID, SUM(LineTotal) AS Subtotal, CASE WHEN SUM(LineTotal)<100000 THEN 0
                                                 WHEN SUM(LineTotal)<120000 THEN 0.05 * SUM(LineTotal)
                                                 WHEN SUM(LineTotal)<150000 THEN SUM(LineTotal)* 0.1 ELSE SUM(LineTotal)* 0.15 END AS Discount
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID

GO
--4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của 
--các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho 
--các biến @mancc, @masp (vd: @mancc=1650, @masp)=4, thì chương trình sẽ 
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, nếu
--@soluongcc trả về giá trị là null thì in ra chuỗi “Nha cung cap 1650 khong cung 
--cap san pham 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nha cung cap 1650 
--cung cap san pham 4 với so luong la 5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])

--ĐÃ NÂNG CẤP
DECLARE @maNCC INT, @maSP INT, @soluongCC INT
SET @maNCC=1556
SET @maSP=319
IF EXISTS (SELECT * FROM Purchasing.ProductVendor WHERE BusinessEntityID=@maNCC)BEGIN
    SELECT @soluongCC=OnOrderQty
    FROM Purchasing.ProductVendor
    WHERE ProductID=@maSP AND BusinessEntityID=@maNCC
    IF @soluongCC IS NULL
        PRINT N'Nhà cung cấp '+CONVERT(CHAR(6), @maNCC)+N' không cung cấp sản phẩm '+CONVERT(CHAR(5), @maSP)
    ELSE
        PRINT N'Nhà cung cấp '+CONVERT(CHAR(6), @maNCC)+N' cung cấp sản phẩm '+CONVERT(CHAR(5), @maSP)+N' với số lượng là '+CONVERT(CHAR(5), @soluongCC)
END
ELSE PRINT N'Không có nhà cung cấp nào có mã là '+CONVERT(CHAR(6), @maNCC)

SELECT * FROM Purchasing.ProductVendor
GO

--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong 
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.

WHILE((SELECT SUM(Rate)FROM HumanResources.EmployeePayHistory)<6000)
BEGIN
    UPDATE HumanResources.EmployeePayHistory SET Rate=Rate * 1.1
    IF((SELECT MAX(Rate)FROM HumanResources.EmployeePayHistory)>150)
		BREAK 
	ELSE 
		CONTINUE
END

