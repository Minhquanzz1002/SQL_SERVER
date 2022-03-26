--Viết hàm sumofOrder với hai tham số @thang và @nam trả về danh sách các 
--hóa đơn (SalesOrderID) lặp trong tháng và năm được truyền vào từ 2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).

CREATE FUNCTION sumOfOrder(@thang int, @nam int)
RETURNS TABLE
AS RETURN
SELECT Sales.SalesOrderHeader.SalesOrderID, Sales.SalesOrderHeader.OrderDate, Subtotal=SUM(Sales.SalesOrderDetail.OrderQty * Sales.SalesOrderDetail.UnitPrice)
FROM Sales.SalesOrderDetail
     INNER JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID
WHERE MONTH(OrderDate)=@thang and YEAR(OrderDate)=@nam
GROUP BY Sales.SalesOrderHeader.SalesOrderID, Sales.SalesOrderHeader.OrderDate
HAVING SUM(Sales.SalesOrderDetail.OrderQty * Sales.SalesOrderDetail.UnitPrice)>70000
GO


CREATE FUNCTION sumOfOrder1(@thang int, @nam int)
RETURNS @sumOfOrder1 TABLE(mahd int, ngayhd datetime, total money)
AS 
begin
insert into @sumOfOrder1
SELECT Sales.SalesOrderHeader.SalesOrderID, Sales.SalesOrderHeader.OrderDate, Subtotal=SUM(Sales.SalesOrderDetail.OrderQty * Sales.SalesOrderDetail.UnitPrice)
FROM Sales.SalesOrderDetail
     INNER JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID
WHERE MONTH(OrderDate)=@thang and YEAR(OrderDate)=@nam
GROUP BY Sales.SalesOrderHeader.SalesOrderID, Sales.SalesOrderHeader.OrderDate
HAVING SUM(Sales.SalesOrderDetail.OrderQty * Sales.SalesOrderDetail.UnitPrice)>70000
return
end
GO
--- CHẠY
--CÁCH 1: 
SELECT * FROM DBO.sumOfOrder(8,2005)
--CÁCH 2: BATCH
DECLARE @thang int, @nam int
SET @thang=8
SET @nam=2005
SELECT * FROM dbo.sumOfOrder(@thang, @nam)



--CÁCH 1: 
SELECT * FROM DBO.sumOfOrder1(8,2005)
--CÁCH 2: BATCH
DECLARE @thang int, @nam int
SET @thang=8
SET @nam=2005
SELECT * FROM dbo.sumOfOrder1(@thang, @nam)



-- Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng 
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và 
--SubTotal
SELECT Production.Product.ProductID, Production.Product.Name, SUM(Sales.SalesOrderDetail.OrderQty * Sales.SalesOrderDetail.UnitPrice) AS SUBTOTAL, COUNT(Sales.SalesOrderDetail.SalesOrderID) AS CountOfOrderID
FROM Production.Product
     INNER JOIN Sales.SalesOrderDetail ON Production.Product.ProductID=Sales.SalesOrderDetail.ProductID
     INNER JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID=Sales.SalesOrderHeader.SalesOrderID
WHERE(DATEPART(Q, Sales.SalesOrderHeader.OrderDate)=1)AND(DATEPART(YY, Sales.SalesOrderHeader.OrderDate)=2008)
GROUP BY Production.Product.ProductID, Production.Product.Name


--1) Viết hàm tên countofEmplyees (dạng scalar function) với tham số @mapb, giá 
--trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong phòng 
--ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các phòng 
--ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID], Name, 
--countOfEmp với countOfEmp= countofEmplyees([DepartmentID]).
--(Dữ liệu lấy từ bảng 
--[HumanResources].[EmployeeDepartmentHistory] và 
--[HumanResources].[Department])
DROP FUNCTION countofEmplyees		-- XÓA FUNCTION

CREATE FUNCTION countofEmplyees(@mapb INT)
RETURNS TABLE
AS RETURN
SELECT HumanResources.Department.DepartmentID, HumanResources.Department.Name, countOfEmp=COUNT(HumanResources.EmployeeDepartmentHistory.DepartmentID)
FROM HumanResources.EmployeeDepartmentHistory
     INNER JOIN HumanResources.Department ON HumanResources.EmployeeDepartmentHistory.DepartmentID=HumanResources.Department.DepartmentID
WHERE HumanResources.Department.DepartmentID=@mapb
GROUP BY HumanResources.Department.DepartmentID, HumanResources.Department.Name
GO


CREATE FUNCTION countofEmplyees(@mapb INT)
RETURNS INT
AS BEGIN
    DECLARE @tong int
    SELECT @tong=COUNT(HumanResources.EmployeeDepartmentHistory.DepartmentID)
    FROM HumanResources.EmployeeDepartmentHistory
         INNER JOIN HumanResources.Department ON HumanResources.EmployeeDepartmentHistory.DepartmentID=HumanResources.Department.DepartmentID
    WHERE HumanResources.Department.DepartmentID=@mapb
    GROUP BY HumanResources.Department.DepartmentID, HumanResources.Department.Name
    RETURN @tong
END

GO

DECLARE @mapb INT
SET @mapb = 1
SELECT dbo.countofEmplyees(@mapb)
--2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @locationID trả về số lượng tồn kho của sản phẩm trong khu 
--vực tương ứng với giá trị của tham số
--(Dữ liệu lấy từ bảng[Production].[ProductInventory])
CREATE FUNCTION InventoryProd(@ProductID INT, @locationID INT)
RETURNS TABLE
AS RETURN
	SELECT        Quantity
FROM            Production.ProductInventory
WHERE ProductID = @ProductID AND LocationID = @locationID

GO
SELECT * FROM Production.ProductInventory

DECLARE  @ProductID INT, @locationID INT
SET @ProductID = 350
SET @locationID = 5
SELECT * FROM dbo.InventoryProd(@ProductID, @locationID)



--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của 
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
--@EmplID, @MonthOrder, @YearOrder
--(Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
SELECT * FROM [Sales].[SalesOrderHeader] WHERE SalesPersonID = 279 AND MONTH(OrderDate) = 7 AND YEAR(OrderDate) = 2005

CREATE FUNCTION SubTotalOfEmp(@EmplID INT, @MonthOrder INT, @YearOrder INT)
RETURNS MONEY
AS BEGIN
    DECLARE @tong MONEY
    SELECT @tong=SUM(SubTotal)
    FROM Sales.SalesOrderHeader
    WHERE @EmplID=SalesPersonID AND MONTH(OrderDate)=@MonthOrder AND YEAR(OrderDate)=@YearOrder
    GROUP BY OrderDate, SalesPersonID
    RETURN @tong
END
GO

DECLARE @EmplID INT, @MonthOrder INT, @YearOrder INT
SET @EmplID=279
SET @MonthOrder=7
SET @YearOrder=2005
SELECT dbo.SubTotalOfEmp(@EmplID, @MonthOrder, @YearOrder)



--6) Viết hàm tên SumofProduct với tham số đầu vào là @MaNCC (VendorID), 
--hàm dùng để tính tổng số lượng (sumOfQty) và tổng trị giá (SumofSubtotal) 
--của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm 
--ProductID, SumofProduct, SumofSubtotal
--(sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] 
--và [Purchasing].[PurchaseOrderDetail])
SELECT * FROM Purchasing.Vendor

CREATE FUNCTION SumofProduct(@MaNCC INT)
RETURNS TABLE
AS RETURN
SELECT Purchasing.PurchaseOrderDetail.ProductID, sumOfQty=SUM(Purchasing.PurchaseOrderDetail.OrderQty), SumofSubtotal=SUM(Purchasing.PurchaseOrderHeader.SubTotal)
FROM Purchasing.Vendor
     INNER JOIN Purchasing.PurchaseOrderHeader ON Purchasing.Vendor.BusinessEntityID=Purchasing.PurchaseOrderHeader.VendorID
     INNER JOIN Purchasing.PurchaseOrderDetail ON Purchasing.PurchaseOrderHeader.PurchaseOrderID=Purchasing.PurchaseOrderDetail.PurchaseOrderID
WHERE VendorID=@MaNCC
GROUP BY Purchasing.PurchaseOrderDetail.ProductID

GO

DECLARE @MaNCC INT
SET @MaNCC = 1516
SELECT * FROM dbo.SumofProduct(@MaNCC)