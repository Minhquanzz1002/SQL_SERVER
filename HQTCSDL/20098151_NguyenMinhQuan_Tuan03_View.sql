--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
CREATE VIEW dbo.vw_Products
AS
SELECT P.ProductID, P.Name, P.Color, P.Size, P.Style, P.StandardCost, PCH.EndDate, PCH.StartDate
FROM Production.Product AS P
     INNER JOIN Production.ProductCostHistory AS PCH ON P.ProductID=PCH.ProductID

--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
--Product_Name, CountOfOrderID và SubTotal.
CREATE VIEW List_Product_View
AS
SELECT P.ProductID, P.Name, COUNT(SOD.SalesOrderID) AS CountOfOrderID, SUM(SOH.SubTotal) AS SubTotal
FROM Production.Product AS P
     INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE DATEPART(QQ, SOH.OrderDate)=1 AND DATEPART(YY, SOH.OrderDate)=2008
GROUP BY P.ProductID, P.Name
HAVING SUM(SOH.SubTotal)>10000 AND COUNT(SOD.SalesOrderID)>500

SELECT * FROM List_Product_View

--3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
--OrderMonth, SUM(TotalDue).
CREATE VIEW vw_CustomerTotals
AS
SELECT C.CustomerID, YEAR(SOH.OrderDate) AS OrderYear, MONTH(SOH.OrderDate) AS OrderMonth, SUM(SOH.TotalDue) AS sumTotalDue
FROM Sales.Customer AS C
     INNER JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID=SOH.CustomerID
     INNER JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID=SOD.SalesOrderID
GROUP BY C.CustomerID, YEAR(SOH.OrderDate), MONTH(SOH.OrderDate)

SELECT * FROM vw_CustomerTotals
--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
CREATE VIEW totalQuantity
AS
SELECT SOH.SalesPersonID, OrderYear=YEAR(SOH.OrderDate), sumOfOrderQty=SUM(SOD.OrderQty)
FROM Sales.SalesPerson AS SP
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SP.BusinessEntityID=SOH.SalesPersonID
     INNER JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID=SOD.SalesOrderID
GROUP BY SOH.SalesPersonID, YEAR(SOH.OrderDate)

SELECT * FROM totalQuantity

--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
CREATE VIEW ListCustomer_view 
AS
SELECT SOH.SalesPersonID, FullName=(P.FirstName+' '+P.LastName), COUNT(SOH.SalesOrderID) AS CountOfOrders
FROM Sales.SalesOrderHeader AS SOH
     INNER JOIN Sales.SalesPerson AS SP ON SOH.SalesPersonID=SP.BusinessEntityID
     INNER JOIN Person.Person AS P ON SP.BusinessEntityID=P.BusinessEntityID
WHERE YEAR(SOH.OrderDate) BETWEEN 2007 AND 2008
GROUP BY SOH.SalesPersonID, P.FirstName+' '+P.LastName
HAVING COUNT(SOH.SalesOrderID)>25

SELECT * FROM ListCustomer_view
--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
--tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
--Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
--Production.Product)
CREATE VIEW ListProduct_view
AS
SELECT P.ProductID, P.Name, SumOfOrderQty=SUM(SOD.OrderQty), YEAR(SOH.OrderDate) AS Year
FROM Production.Product AS P
     INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE P.Name LIKE 'Bike%' OR P.Name LIKE 'Sport%'
GROUP BY P.ProductID, P.Name, YEAR(SOH.OrderDate)
HAVING SUM(SOD.OrderQty)>50

SELECT * FROM ListProduct_view
--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].
CREATE VIEW List_department_View
AS
SELECT D.DepartmentID, D.Name, AVG(EPH.Rate) AS AvgOfRate
FROM HumanResources.Department AS D
     INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH ON D.DepartmentID=EDH.DepartmentID
     INNER JOIN HumanResources.EmployeePayHistory AS EPH ON EDH.BusinessEntityID=EPH.BusinessEntityID
GROUP BY D.DepartmentID, D.Name
HAVING AVG(EPH.Rate)>30

SELECT * FROM List_department_View
--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
CREATE VIEW vw_OrderSummary
WITH ENCRYPTION
AS
SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(SubTotal) AS OrderTotal
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)

SELECT * FROM vw_OrderSummary

SP_HEPTTEXT vw_OrderSummary

--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
--Product. Có xóa được không? Vì sao?
CREATE VIEW vwProducts WITH SCHEMABINDING
AS
SELECT P.ProductID, P.Name, P.ListPrice, PCH.StartDate, PCH.EndDate
FROM Production.Product AS P
     INNER JOIN Production.ProductCostHistory AS PCH ON P.ProductID=PCH.ProductID

SELECT * FROM vwProducts

SP_HELPTEXT vwProducts

ALTER TABLE Production.Product DROP COLUMN ListPrice

--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
CREATE VIEW view_Department
AS
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
WHERE GroupName LIKE 'Manufacturing' OR GroupName LIKE 'Quality Assurance'
WITH CHECK OPTION

--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
--chèn được không? Giải thích.
INSERT INTO view_Department (DepartmentID, Name, GroupName) VALUES (17, 'ABC4', 'ABCXYZ1')
INSERT INTO view_Department (DepartmentID, Name, GroupName) VALUES (18, 'ABC3', 'ABCXYZ2')

--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
--phòng thuộc nhóm “Quality Assurance”.
SET IDENTITY_INSERT HumanResources.Department ON
INSERT INTO view_Department (DepartmentID, Name, GroupName) VALUES (19, 'ABC1', N'Manufacturing')
INSERT INTO view_Department (DepartmentID, Name, GroupName) VALUES (20, 'ABC2', N'Quality Assurance')

--c. Dùng câu lệnh Select xem kết quả trong bảng Department.
SELECT * FROM HumanResources.Department