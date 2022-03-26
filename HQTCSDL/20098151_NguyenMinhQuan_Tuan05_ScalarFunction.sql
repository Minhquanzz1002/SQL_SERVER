--II) Function
-- Scalar Function
--1) Viết hàm tên countofEmplyees (dạng scalar function) với tham số @mapb, giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong phòng 
--ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID], Name, 
--countOfEmp với countOfEmp= countofEmplyees([DepartmentID]).
--(Dữ liệu lấy từ bảng [HumanResources].[EmployeeDepartmentHistory] và [HumanResources].[Department])

CREATE FUNCTION countofEmplyees(@mapb INT)
RETURNS INT
AS BEGIN
    DECLARE @countOfEmp INT
    SELECT @countOfEmp=COUNT(EDH.DepartmentID)
    FROM HumanResources.EmployeeDepartmentHistory AS EDH
         INNER JOIN HumanResources.Department AS D ON EDH.DepartmentID=D.DepartmentID
    WHERE D.DepartmentID=@mapb
    GROUP BY D.DepartmentID, D.Name
    RETURN @countOfEmp
END
GO

SELECT dbo.countofEmplyees(1) AS N'SỐ NHÂN VIÊN'

DECLARE @mapb INT
SET @mapb = 1
PRINT N'SỐ NHÂN VIÊN TRONG PHÒNG ' + CONVERT(CHAR(5), @mapb) + N' LÀ ' + CONVERT(CHAR(5), DBO.countofEmplyees(@mapb)) 

--DỮ LIỆU TEST
SELECT D.DepartmentID, D.Name, COUNT(EDH.DepartmentID) AS countOfEmp
FROM HumanResources.EmployeeDepartmentHistory AS EDH
     INNER JOIN HumanResources.Department AS D ON EDH.DepartmentID=D.DepartmentID
GROUP BY D.DepartmentID, D.Name
GO
--2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @locationID trả về số lượng tồn kho của sản phẩm trong khu 
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])

CREATE FUNCTION InventoryProd(@ProductID INT, @locationID INT)
RETURNS INT
AS BEGIN
    DECLARE @quantity INT
    SELECT @quantity=Quantity
    FROM Production.ProductInventory
    WHERE ProductID=@ProductID AND LocationID=@locationID
    RETURN @quantity
END

SELECT [dbo].[InventoryProd](1, 1)

DECLARE @ProductID INT, @locationID INT
SET @ProductID = 1
SET @locationID = 1
PRINT N'SỐ LƯỢNG TỒN KHO CỦA SẢN PHẨM ' + CONVERT(CHAR(5), @ProductID) + N'TẠI KHU VỰC ' + CONVERT(CHAR(5), @locationID) + N' LÀ ' + CONVERT(CHAR(10), DBO.InventoryProd(@ProductID, @locationID))

--KIỂM TRA DỮ LIỆU
SELECT ProductID, LocationID, Quantity
FROM Production.ProductInventory
ORDER BY ProductID, LocationID

--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của 
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào @EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])

CREATE FUNCTION SubTotalOfEmp(@EmplID INT, @MonthOrder INT, @YearOrder INT)
RETURNS MONEY
AS BEGIN
    DECLARE @tongDanhThu MONEY
    SELECT @tongDanhThu=SUM(SubTotal)
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID=@EmplID AND MONTH(OrderDate)=@MonthOrder AND YEAR(OrderDate)=@YearOrder
    GROUP BY SalesPersonID, OrderDate
    RETURN @tongDanhThu
END

DROP FUNCTION SubTotalOfEmp

DECLARE @EmplID INT, @MonthOrder INT, @YearOrder INT
SET @EmplID=290
SET @MonthOrder=2
SET @YearOrder=2007
PRINT N'TỔNG DOANH THU CỦA NHÂN VIÊN '+CONVERT(CHAR(5), @EmplID)+N' TRONG THÁNG '+CONVERT(CHAR(2), @MonthOrder)+N' NĂM '+CONVERT(CHAR(4), @YearOrder)+N' LÀ '+CONVERT(CHAR(10), DBO.SubTotalOfEmp(@EmplID, @MonthOrder, @YearOrder))

SELECT SalesPersonID, MONTH(OrderDate), YEAR(OrderDate), SUM(SubTotal)
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID, MONTH(OrderDate), YEAR(OrderDate)
ORDER BY SalesPersonID DESC, MONTH(OrderDate), YEAR(OrderDate)

-- Table Valued Functions
--4) Viết hàm sumofOrder với hai tham số @thang và @nam trả về danh sách các 
--hóa đơn (SalesOrderID) lặp trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
CREATE FUNCTION sumofOrder_tblfunction(@thang INT, @nam INT)
RETURNS TABLE
AS
RETURN(
      SELECT SOH.OrderDate, SOH.SalesOrderID, SUM(SOD.OrderQty * SOD.UnitPrice) AS SubTotal
      FROM Sales.SalesOrderDetail AS SOD
           INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
      WHERE MONTH(SOH.OrderDate)=@thang AND YEAR(SOH.OrderDate)=@nam
      GROUP BY SOH.OrderDate, SOH.SalesOrderID
      HAVING SUM(SOD.OrderQty * SOD.UnitPrice)>70000)

SELECT * FROM sumofOrder_tblfunction(1, 2007)

DECLARE @thang INT, @nam INT
SET @thang = 1
SET @nam = 2007
SELECT * FROM sumofOrder_tblfunction(@thang, @nam)

--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), sumofSubTotal. Trong đó:
-- SumofSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01

CREATE FUNCTION NewBonus_tblfunction()
RETURNS TABLE
AS
RETURN(
      SELECT SP.BusinessEntityID, SP.Bonus, SUM(SOH.SubTotal) AS sumofSubTotal, NewBonus=SP.Bonus+SUM(SOH.SubTotal)* 0.01
      FROM Sales.SalesPerson AS SP
           INNER JOIN Sales.SalesOrderHeader AS SOH ON SP.BusinessEntityID=SOH.SalesPersonID
      GROUP BY SP.BusinessEntityID, SP.Bonus)

SELECT * FROM NewBonus_tblfunction()



--6) Viết hàm tên SumofProduct với tham số đầu vào là @MaNCC (VendorID), 
--hàm dùng để tính tổng số lượng (sumOfQty) và tổng trị giá (SumofSubtotal) 
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm 
--ProductID, SumofProduct, SumofSubtotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] 
--và [Purchasing].[PurchaseOrderDetail])

--CẦN XEM LẠI
CREATE FUNCTION SumofProduct_tblfunction(@MaNCC INT)
RETURNS TABLE
AS
RETURN(
      SELECT POD.ProductID, SUM(POH.SubTotal) AS SumofSubtotal, SUM(POD.OrderQty) sumOfQty
      FROM Purchasing.Vendor AS V
           INNER JOIN Purchasing.PurchaseOrderHeader AS POH ON V.BusinessEntityID=POH.VendorID
           INNER JOIN Purchasing.PurchaseOrderDetail AS POD ON POH.PurchaseOrderID=POD.PurchaseOrderID
      WHERE POH.VendorID=@MaNCC
      GROUP BY POD.ProductID)

SELECT * FROM Purchasing.Vendor AS V ORDER BY V.BusinessEntityID

DECLARE @MaNCC INT
SET @MaNCC = 1514
SELECT * FROM SumofProduct_tblfunction(@MaNCC)

--7) Viết hàm tên Discount_func tính số tiền giảm trên các hóa đơn(SalesOrderID), 
--thông tin gồm SalesOrderID, [SubTotal], Discount, trong đó, Discount được tính như sau:
--Nếu [SubTotal]<1000 thì Discount=0 
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
--Gợi ý: Sử dụng Case when …then …
--(Sử dụng dữ liệu từ bảng [Sales].[SalesOrderHeader])

CREATE FUNCTION Discount_tblfunc()
RETURNS TABLE
AS
RETURN(
      SELECT SalesOrderID, SubTotal, CASE WHEN SubTotal<1000 THEN 0
                                     WHEN SubTotal<5000 THEN SubTotal * 0.05
                                     WHEN SubTotal<10000 THEN SubTotal * 0.1 ELSE SubTotal * 0.15 END AS Discount
      FROM Sales.SalesOrderHeader)

SELECT * FROM Discount_tblfunc()

--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng 
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được 
--truyền và 2 tham số, thông tin gồm [SalesPersonID], Total, với 
--Total=Sum([SubTotal])

CREATE FUNCTION TotalOfEmp_tblfunc(@MonthOrder INT,
@YearOrder INT)
RETURNS TABLE
AS
RETURN(
      SELECT SalesPersonID, SUM(SubTotal) AS Total
      FROM Sales.SalesOrderHeader
      WHERE DATEPART(MM, OrderDate)=@MonthOrder AND DATEPART(YY, OrderDate)=@YearOrder
      GROUP BY SalesPersonID, OrderDate)

DECLARE @MonthOrder INT, @YearOrder INT
SET @MonthOrder = 1
SET @YearOrder = 2007
SELECT * FROM TotalOfEmp_tblfunc(@MonthOrder, @YearOrder)

-- Multi statement Table Valued Functions
--9) Viết lại các câu 5,6,7,8 bằng multi-statement table valued function
--CÂU 5
--5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
--mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), sumofSubTotal. Trong đó:
-- SumofSubTotal =sum(SubTotal),
-- NewBonus = Bonus+ sum(SubTotal)*0.01
CREATE FUNCTION 
--10)Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham 
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm 
--BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
-- Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết 
--quả là bảng lương của nhân viên đó.
--Ví dụ thực thi hàm: select*from SalaryOfEmp(288)
--Kết quả là
-- Nếu giá trị truyền vào là Null thì kết quả là bảng lương của tất cả 
--nhân viên
--Ví dụ: thực thi hàm select*from SalaryOfEmp(Null)
--Kết quả là 316 record
--(Dữ liệu lấy từ 2 bảng [HumanResources].[EmployeePayHistory] và 
--[Person].[Person] )


--III) Stored Procedure
--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một 
--tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, 
--thông tin gồm: CustomerID, SumofTotalDue =Sum(TotalDue)
GO
CREATE PROC TotalDue @thang INT, @nam INT
AS BEGIN
    SELECT C.CustomerID, SUM(SOH.TotalDue) AS SumofTotalDue
    FROM Sales.Customer AS C
         INNER JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID=SOH.CustomerID
    WHERE DATEPART(MM, SOH.OrderDate)=@thang AND DATEPART(YY, SOH.OrderDate)=@nam
    GROUP BY C.CustomerID
END
GO

DECLARE @thang INT, @nam INT
SET @thang=8
SET @nam=2008
IF EXISTS (SELECT *
           FROM Sales.SalesOrderHeader AS SOH
           WHERE DATEPART(MM, SOH.OrderDate)=@thang AND DATEPART(YY, SOH.OrderDate)=@nam)
    EXEC TotalDue @thang, @nam
ELSE PRINT('thang hoac nam khong ton tai')

--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của 
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số 
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số 
-- @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục. 
GO
CREATE PROC tongDanhThu @SalesPerson INT, @SalesYTD MONEY OUTPUT
AS BEGIN
    SELECT @SalesYTD=SUM(SP.SalesYTD)
    FROM Sales.SalesPerson AS SP
         INNER JOIN Sales.SalesOrderHeader AS SOH ON SP.BusinessEntityID=SOH.SalesPersonID AND SP.BusinessEntityID=SOH.SalesPersonID AND SP.BusinessEntityID=SOH.SalesPersonID AND SP.BusinessEntityID=SOH.SalesPersonID AND SP.BusinessEntityID=SOH.SalesPersonID
    WHERE OrderDate<GETDATE()AND SP.BusinessEntityID=@SalesPerson
    GROUP BY SP.BusinessEntityID
END
GO

DECLARE @SalesPerson INT, @SalesYTD MONEY
SET @SalesPerson=274
IF EXISTS (SELECT * FROM Sales.SalesPerson AS SP WHERE BusinessEntityID=@SalesPerson)BEGIN
    EXEC tongDanhThu @SalesPerson, @SalesYTD OUT
    PRINT 'Danh thu cua nhan vien '+CONVERT(CHAR(5), @SalesPerson)+' la'+CONVERT(CHAR(15), @SalesYTD)
END
ELSE PRINT 'Nhan vien khong ton tai'

--3) Viết một thủ tục trả về một danh sách các sản phẩm có giá không vượt quá một 
--giá trị được chỉ định, với tham số input @Product và @MaxPrice, tham số 
--output @ComparePrice và ListPrice 

--CREATE PROC dsSanPham_Cau3 @Product INT,@MaxPrice INT
--AS BEGIN
--	DECLARE @ComparePrice INT,@ListPrice MONEY
--	SELECT @ComparePrice = 
--SELECT        ProductID, ListPrice
--FROM            Production.Product
--END

--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho nhân viên bán 
--hàng (SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng 
--mới bằng mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), sumofSubTotal. Trong đó: 
--SumofSubTotal =sum(SubTotal) 
--NewBonus = Bonus+ sum(SubTotal)*0.01
GO
CREATE PROC sp_NewBonus
AS BEGIN
    SELECT SOH.SalesPersonID, SUM(SOH.SubTotal) AS sumofSubTotal, (SP.Bonus+SUM(SOH.SubTotal)* 0.01) AS NewBonus
    FROM Sales.SalesOrderHeader AS SOH
         INNER JOIN Sales.SalesPerson AS SP ON SOH.SalesPersonID=SP.BusinessEntityID AND SOH.SalesPersonID=SP.BusinessEntityID AND SOH.SalesPersonID=SP.BusinessEntityID
    GROUP BY SOH.SalesPersonID, SP.Bonus
END

EXEC sp_NewBonus

--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số 
--input), thông tin gồm: ProductCategoryID, Name, SumofQty. Dữ liệu từ bảng 
--ProductCategory, ProductSubcategory, Product và SalesOrderDetail (Lưu ý: dùng subquery) 
GO
/*THẦY ĐÃ SỬA*/
CREATE PROC sp_xemNhomSP_Cau5 @nam INT
AS BEGIN
    SELECT PC.ProductCategoryID, PC.Name, SUM(SOD.OrderQty) AS SumofQty
    FROM Production.ProductSubcategory AS PS
         INNER JOIN Production.ProductCategory AS PC ON PS.ProductCategoryID=PC.ProductCategoryID AND PS.ProductCategoryID=PC.ProductCategoryID
         INNER JOIN Production.Product AS P ON PS.ProductSubcategoryID=P.ProductSubcategoryID
         INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
         INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID AND SOD.SalesOrderID=SOH.SalesOrderID AND SOD.SalesOrderID=SOH.SalesOrderID
    WHERE DATEPART(YY, SOH.DueDate)=@nam
    GROUP BY PC.ProductCategoryID, PC.Name
    HAVING SUM(SOD.OrderQty)>=ALL(SELECT SUM(SOD.OrderQty) AS SumofQty
                                  FROM Production.ProductSubcategory AS PS
                                       INNER JOIN Production.ProductCategory AS PC ON PS.ProductCategoryID=PC.ProductCategoryID AND PS.ProductCategoryID=PC.ProductCategoryID
                                       INNER JOIN Production.Product AS P ON PS.ProductSubcategoryID=P.ProductSubcategoryID
                                       INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
                                       INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID AND SOD.SalesOrderID=SOH.SalesOrderID AND SOD.SalesOrderID=SOH.SalesOrderID
                                  WHERE DATEPART(YY, SOH.DueDate)=@nam
                                  GROUP BY PC.ProductCategoryID)
END

GO
DECLARE @nam INT
SET @nam=2008
IF EXISTS (SELECT OrderDate
           FROM Sales.SalesOrderHeader
           WHERE DATEPART(YY, OrderDate)=@nam)
    EXEC sp_xemNhomSP_Cau5 @nam
ELSE PRINT N'NĂM '+CONVERT(CHAR(4), @nam)+N' KHÔNG TỒN TẠI'

--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra 
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả 
--về trạng thái thành công hay thất bại của thủ tục.
CREATE PROC sp_TongThu @manv INT
AS BEGIN
	


END

--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo 
--năm đã cho.
CREATE PROC sp_CuaHangMuaNhieuNhat @nam INT
AS BEGIN
    SELECT S.Name, SUM(SOH.SubTotal) AS tongTien
    FROM Sales.SalesOrderHeader AS SOH
         INNER JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID=SOD.SalesOrderID AND SOH.SalesOrderID=SOD.SalesOrderID AND SOH.SalesOrderID=SOD.SalesOrderID
         CROSS JOIN Sales.Store AS S
    WHERE(DATEPART(YY, SOH.OrderDate)=@nam)
    GROUP BY S.Name
    HAVING SUM(SOH.SubTotal)>=ALL(SELECT SUM(SOH.SubTotal) AS tongTien
                                  FROM Sales.SalesOrderHeader AS SOH
                                       INNER JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID=SOD.SalesOrderID AND SOH.SalesOrderID=SOD.SalesOrderID AND SOH.SalesOrderID=SOD.SalesOrderID
                                       CROSS JOIN Sales.Store AS S
                                  WHERE(DATEPART(YY, SOH.OrderDate)=@nam)
                                  GROUP BY S.Name)
END

EXEC sp_CuaHangMuaNhieuNhat 2007
--8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin 
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not 
--null và các field là khóa ngoại.
GO
CREATE PROC Sp_InsertProduct
    @ProductID             INT,
    @Name                  NVARCHAR(50),
    @ProductNumber         NVARCHAR(25),
    @MakeFlag              FLAG,
    @FinishedGoodsFlag     FLAG,
    @SafetyStockLevel      SMALLINT,
    @ReorderPoint          SMALLINT,
    @StandardCost          MONEY,
    @ListPrice             MONEY,
    @SizeUnitMeasureCode   NCHAR(3),
    @WeightUnitMeasureCode NCHAR(3),
    @DaysToManufacture     INT,
    @ProductSubcategoryID  INT,
    @ProductModelID        INT,
    @SellStartDate         DATETIME,
    @ModifiedDate          DATETIME
AS
    BEGIN
        INSERT INTO [Production].[Product]
            (
                ProductID,
                Name,
                ProductNumber,
                MakeFlag,
                FinishedGoodsFlag,
                SafetyStockLevel,
                ReorderPoint,
                StandardCost,
                ListPrice,
                SizeUnitMeasureCode,
                WeightUnitMeasureCode,
                DaysToManufacture,
                ProductSubcategoryID,
                ProductModelID,
                SellStartDate,
                ModifiedDate
            )
        VALUES
            (
                @ProductID,
                @Name,
                @ProductNumber,
                @MakeFlag,
                @FinishedGoodsFlag,
                @SafetyStockLevel,
                @ReorderPoint,
                @StandardCost,
                @ListPrice,
                @SizeUnitMeasureCode,
                @WeightUnitMeasureCode,
                @DaysToManufacture,
                @ProductSubcategoryID,
                @ProductModelID,
                @SellStartDate,
                @ModifiedDate
            )
    END
GO
SELECT * FROM Production.Product

GO
DECLARE
    @ProductID             INT,
    @Name                  NVARCHAR(50),
    @ProductNumber         NVARCHAR(25),
    @MakeFlag              FLAG,
    @FinishedGoodsFlag     FLAG,
    @SafetyStockLevel      SMALLINT,
    @ReorderPoint          SMALLINT,
    @StandardCost          MONEY,
    @ListPrice             MONEY,
    @SizeUnitMeasureCode   NCHAR(3),
    @WeightUnitMeasureCode NCHAR(3),
    @DaysToManufacture     INT,
    @ProductSubcategoryID  INT,
    @ProductModelID        INT,
    @SellStartDate         DATETIME,
    @ModifiedDate          DATETIME

SET @ProductID = 1000
SET @Name = 'Road-750 Black, 53'
SET @ProductNumber = 'BK-R19B-53'
SET @MakeFlag = 1
SET @FinishedGoodsFlag = 1
SET @SafetyStockLevel = 100
SET @ReorderPoint = 75
SET @StandardCost = 343.6496
SET @ListPrice = 539.99
SET @SizeUnitMeasureCode = 'CM'
SET @WeightUnitMeasureCode = 'LB'
SET @DaysToManufacture = 4
SET @ProductSubcategoryID = 2
SET @ProductModelID = 31
SET @SellStartDate = GETDATE()
SET @ModifiedDate = GETDATE()
IF EXISTS (SELECT * FROM [Production].[Product] AS P WHERE @ProductID = P.ProductID)
    PRINT N'MÃ SẢN PHẨM ' + CONVERT(CHAR(10), @ProductID) + N' ĐÃ TỒN TẠI'
ELSE
    EXEC Sp_InsertProduct
        @ProductID,
        @Name,
        @ProductNumber,
        @MakeFlag,
        @FinishedGoodsFlag,
        @SafetyStockLevel,
        @ReorderPoint,
        @StandardCost,
        @ListPrice,
        @SizeUnitMeasureCode,
        @WeightUnitMeasureCode,
        @DaysToManufacture,
        @ProductSubcategoryID,
        @ProductModelID,
        @SellStartDate,
        @ModifiedDate

SET IDENTITY_INSERT [Production].[Product] ON

--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader 
--khi biết SalesOrderID. Lưu ý trước khi xóa mẫu tin trong 
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong 
--Sales.SalesOrderDetail. Nếu không xoá được hoá đơn thì cũng không được phép 
--xóa Sales.SalesOrderDetail của hóa đơn đó.




--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice lên 
--10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm này.

