--1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 7 năm 2008 có 
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó 
--SubTotal =SUM(OrderQty*UnitPrice).
SELECT SOD.SalesOrderID, SOH.OrderDate, SUM(SOD.OrderQty * SOD.UnitPrice) AS SubTotal
FROM Sales.SalesOrderDetail AS SOD
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE(MONTH(SOH.OrderDate)=7)AND(YEAR(SOH.OrderDate)=2007)
GROUP BY SOD.SalesOrderID, SOH.OrderDate
HAVING(SUM(SOD.OrderQty * SOD.UnitPrice)>70000)

--2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia 
--có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory, 
--Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin 
--bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền 
--(SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
SELECT ST.TerritoryID, SUM(SOD.OrderQty * SOD.UnitPrice) AS SubTotal, COUNT(C.CustomerID) AS CountOfCust
FROM Sales.SalesOrderDetail AS SOD
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
     INNER JOIN Sales.SalesTerritory AS ST ON SOH.TerritoryID=ST.TerritoryID
     INNER JOIN Sales.Customer AS C ON SOH.CustomerID=C.CustomerID AND ST.TerritoryID=C.TerritoryID
WHERE(ST.CountryRegionCode LIKE 'US')
GROUP BY ST.TerritoryID

--3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
--(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm 
--SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
SELECT SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(UnitPrice * OrderQty)
FROM Sales.SalesOrderDetail
WHERE CarrierTrackingNumber LIKE '4BD%'
GROUP BY SalesOrderID, CarrierTrackingNumber

--4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán trung bình >5, thông tin gồm ProductID, Name, AverageOfQty
SELECT P.ProductID, P.Name, AVG(SOD.OrderQty) AS AverageOfQty
FROM Production.Product AS P
     INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
WHERE(SOD.UnitPrice<25)
GROUP BY P.ProductID, P.Name
HAVING(AVG(SOD.OrderQty)>5)

--5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm JobTitle,CountOfPerson=Count(*)
SELECT jobtitle, CountOfPerson=COUNT(*)
FROM humanresources.employee
GROUP BY jobtitle
HAVING COUNT(*)>20

--6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên 
--kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm 
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
--(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và [Purchasing].[PurchaseOrderDetail])
SELECT V.BusinessEntityID, V.Name, POD.ProductID, SUM(POD.OrderQty) AS SumOfQty, SUM(POH.SubTotal) AS SubTotal
FROM Purchasing.PurchaseOrderDetail AS POD
     INNER JOIN Purchasing.PurchaseOrderHeader AS POH ON POD.PurchaseOrderID=POH.PurchaseOrderID
     INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID
WHERE(V.Name LIKE '%Bicycles')
GROUP BY V.BusinessEntityID, V.Name, POD.ProductID, POH.SubTotal
HAVING(SUM(POH.SubTotal)>800000)

SELECT V.BusinessEntityID, V.Name, POD.ProductID, SUM(POD.OrderQty) AS SumOfQty, SUM(POD.OrderQty*POD.UnitPrice) AS SubTotal			/** Thầy sửa **/
FROM Purchasing.PurchaseOrderDetail AS POD
     INNER JOIN Purchasing.PurchaseOrderHeader AS POH ON POD.PurchaseOrderID=POH.PurchaseOrderID
     INNER JOIN Purchasing.Vendor AS V ON POH.VendorID=V.BusinessEntityID
WHERE(V.Name LIKE '%Bicycles')
GROUP BY V.BusinessEntityID, V.Name, POD.ProductID
HAVING(SUM(POD.OrderQty*POD.UnitPrice)>800000)

--7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng 
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và SubTotal
SELECT P.ProductID, P.Name, COUNT(SOD.SalesOrderID) AS CountOfOrderID
FROM Production.Product AS P
     INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID AND SOD.SalesOrderID=SOH.SalesOrderID
WHERE(DATEPART(qq, SOH.OrderDate)=1)AND(YEAR(SOH.OrderDate)=2008)
GROUP BY P.ProductID, P.Name, SOD.UnitPrice, SOD.OrderQty
HAVING(COUNT(SOD.SalesOrderID)>500)AND(SUM(SOD.UnitPrice * SOD.OrderQty)>10000)

--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến 
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
SELECT Sales.Customer.PersonID, Person.Person.FirstName+' '+Person.Person.LastName AS FullName, COUNT(Sales.SalesOrderHeader.SalesOrderID) AS CountOfOrders
FROM Sales.Customer
     INNER JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID=Sales.SalesOrderHeader.CustomerID
     INNER JOIN Person.Person ON Sales.Customer.PersonID=Person.Person.BusinessEntityID
WHERE(YEAR(Sales.SalesOrderHeader.OrderDate) IN (2007, 2008))
GROUP BY Sales.Customer.PersonID, Person.Person.FirstName+' '+Person.Person.LastName
HAVING COUNT(Sales.SalesOrderHeader.SalesOrderID) > 25
ORDER BY Sales.Customer.PersonID

--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng 
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name, 
--CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader, 
--Sales.SalesOrderDetail và Production.Product)
SELECT P.ProductID, P.Name, COUNT(SOD.OrderQty) AS CountOfOrderQty, YEAR(SOH.OrderDate) AS YEAR
FROM Sales.SalesOrderHeader AS SOH
     INNER JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID=SOD.SalesOrderID AND SOH.SalesOrderID=SOD.SalesOrderID AND SOH.SalesOrderID=SOD.SalesOrderID AND SOH.SalesOrderID=SOD.SalesOrderID AND SOH.SalesOrderID=SOD.SalesOrderID
     INNER JOIN Production.Product AS P ON SOD.ProductID=P.ProductID
WHERE(P.Name LIKE 'Bike%')OR(P.Name LIKE 'Sport%')
GROUP BY P.ProductID, P.Name, YEAR(SOH.OrderDate)
HAVING(COUNT(SOD.OrderQty)>500)

--10) Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông 
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
--bình (AvgofRate). Dữ liệu từ các bảng
--[HumanResources].[Department], 
--[HumanResources].[EmployeeDepartmentHistory], 
--[HumanResources].[EmployeePayHistory].
SELECT D.DepartmentID, D.Name, AVG(EPH.Rate) AS AvgofRate
FROM HumanResources.Department AS D
     INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH ON D.DepartmentID=EDH.DepartmentID
     INNER JOIN HumanResources.EmployeePayHistory AS EPH ON EDH.BusinessEntityID=EPH.BusinessEntityID
GROUP BY D.DepartmentID, D.Name
HAVING(AVG(EPH.Rate)>30)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--II) Subquery
--1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có 
--trên 100 đơn đặt hàng trong tháng 7 năm 2008
SELECT PRODUCTION.PRODUCT.PRODUCTID, PRODUCTION.PRODUCT.NAME
FROM PRODUCTION.PRODUCT
     INNER JOIN SALES.SALESORDERDETAIL ON PRODUCTION.PRODUCT.PRODUCTID=SALES.SALESORDERDETAIL.PRODUCTID
     INNER JOIN SALES.SALESORDERHEADER ON SALES.SALESORDERDETAIL.SALESORDERID=SALES.SALESORDERHEADER.SALESORDERID
WHERE MONTH(SALES.SALESORDERHEADER.ORDERDATE)=7 AND YEAR(SALES.SALESORDERHEADER.ORDERDATE)=2008
GROUP BY PRODUCTION.PRODUCT.PRODUCTID, PRODUCTION.PRODUCT.NAME
HAVING(COUNT(SALES.SALESORDERDETAIL.SALESORDERID)>100)

--2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất trong tháng 7/2008
SELECT P.ProductID, P.Name
FROM Production.Product AS P
     INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
     INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE(MONTH(SOH.OrderDate)=7)AND(YEAR(SOH.OrderDate)=2008)
GROUP BY P.ProductID, P.Name
HAVING(COUNT(SOD.SalesOrderID)>=ALL(SELECT COUNT(SOD.SalesOrderID)
                                    FROM Production.Product AS P
                                         INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
                                         INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
                                    WHERE(MONTH(SOH.OrderDate)=7)AND(YEAR(SOH.OrderDate)=2008)
                                    GROUP BY P.ProductID, P.Name))

--3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm: CustomerID, Name, CountOfOrder
SELECT Sales.Customer.CustomerID, Person.Person.FirstName+' '+Person.Person.LastName AS FullName, COUNT(Sales.SalesOrderHeader.SalesOrderID) AS CountOfOrder
FROM Sales.Customer
     INNER JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID=Sales.SalesOrderHeader.CustomerID
     INNER JOIN Person.Person ON Sales.Customer.PersonID=Person.Person.BusinessEntityID
GROUP BY Sales.Customer.CustomerID, Person.Person.FirstName+' '+Person.Person.LastName
HAVING COUNT(Sales.SalesOrderHeader.SalesOrderID)>=ALL(SELECT DISTINCT COUNT(Sales.SalesOrderHeader.SalesOrderID)
                                                       FROM Sales.Customer
                                                            INNER JOIN Sales.SalesOrderHeader ON Sales.Customer.CustomerID=Sales.SalesOrderHeader.CustomerID
                                                            INNER JOIN Person.Person ON Sales.Customer.PersonID=Person.Person.BusinessEntityID
                                                       GROUP BY Sales.Customer.CustomerID)

--4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với		/** Thầy đã sửa**/
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng 
--bảng Production.Product và Production.ProductModel)
/* DÙNG IN */
SELECT ProductID, Name
FROM Production.Product
WHERE ProductModelID IN(SELECT ProductModelID
                        FROM Production.ProductModel
                        WHERE Name LIKE 'Long-Sleeve Logo Jersey%')
/* DÙNG EXIST */
SELECT ProductID, Name
FROM Production.Product
WHERE EXISTS (SELECT ProductModelID
              FROM Production.ProductModel
              WHERE Production.ProductModel.ProductModelID=Production.Product.ProductModelID AND Name LIKE 'Long-Sleeve Logo Jersey%')
--5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối đa			/* Kiểm tra lại*/
--cao hơn giá trung bình của tất cả các mô hình.
SELECT ProductModelID, MAX(ListPrice) AS MaxOfListPrice
FROM Production.Product
GROUP BY ProductModelID
HAVING(MAX(ListPrice)>(SELECT AVG(ListPrice)FROM Production.Product))

--6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng đặt	/** Thầy đã sửa **/
--hàng > 5000 (dùng IN, EXISTS)
/* DÙNG CÁCH TRUY VẤN THƯỜNG*/
SELECT Production.Product.ProductID, Production.Product.Name
FROM Production.Product
     INNER JOIN Sales.SalesOrderDetail ON Production.Product.ProductID=Sales.SalesOrderDetail.ProductID
GROUP BY Production.Product.ProductID, Production.Product.Name
HAVING(SUM(Sales.SalesOrderDetail.OrderQty)>5000)
ORDER BY Production.Product.ProductID
/* DÙNG EXISTS*/
SELECT ProductID, Name
FROM Production.Product
WHERE EXISTS (SELECT ProductID
              FROM Sales.SalesOrderDetail
              WHERE Production.Product.ProductID=Sales.SalesOrderDetail.ProductID
              GROUP BY ProductID
              HAVING SUM(OrderQty)>5000)
ORDER BY ProductID
/* DÙNG IN*/
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN(SELECT ProductID
                   FROM Sales.SalesOrderDetail
                   GROUP BY ProductID
                   HAVING SUM(OrderQty)>5000)
ORDER BY ProductID

--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao nhất 
--trong bảng Sales.SalesOrderDetail
SELECT Production.Product.ProductID, Sales.SalesOrderDetail.UnitPrice
FROM Production.Product
     INNER JOIN Sales.SalesOrderDetail ON Production.Product.ProductID=Sales.SalesOrderDetail.ProductID
WHERE Sales.SalesOrderDetail.UnitPrice>=ALL(SELECT UnitPrice FROM Sales.SalesOrderDetail GROUP BY UnitPrice)
GROUP BY Production.Product.ProductID, Sales.SalesOrderDetail.UnitPrice

--8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID, Name, dùng 3 cách Not in, Not exists và Left join.
/* DÙNG NOT IN*/
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID NOT IN(SELECT ProductID FROM Sales.SalesOrderDetail GROUP BY ProductID)
ORDER BY ProductID ASC
/* DÙNG NOT EXISTS */
SELECT ProductID, Name
FROM Production.Product
WHERE NOT EXISTS(SELECT ProductID FROM Sales.SalesOrderDetail WHERE Production.Product.ProductID = Sales.SalesOrderDetail.ProductID)
ORDER BY ProductID ASC
/* DÙNG LEFT JOIN */
SELECT Production.Product.ProductID, Name
FROM Production.Product
     LEFT JOIN Sales.SalesOrderDetail ON Production.Product.ProductID=Sales.SalesOrderDetail.ProductID
WHERE Sales.SalesOrderDetail.ProductID IS NULL

--9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm 
--EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng HR.Employees và Sales.Orders)
SELECT E.BusinessEntityID, P.FirstName, P.LastName
FROM HumanResources.Employee AS E
     INNER JOIN Person.Person AS P ON E.BusinessEntityID=P.BusinessEntityID
WHERE E.BusinessEntityID NOT IN(SELECT DISTINCT E.BusinessEntityID
                                FROM HumanResources.Employee AS E
                                     INNER JOIN Sales.SalesPerson AS SP ON E.BusinessEntityID=SP.BusinessEntityID
                                     INNER JOIN Sales.SalesOrderHeader AS SOH ON SP.BusinessEntityID=SOH.SalesPersonID
                                WHERE SOH.OrderDate BETWEEN CAST('1/5/2008' AS DATETIME)AND CAST(GETDATE() AS DATETIME))
ORDER BY E.BusinessEntityID

--10) Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.
SELECT DISTINCT C.CustomerID, P.FirstName+N' '+P.LastName AS FullName
FROM Sales.Customer AS C
     INNER JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID=SOH.CustomerID
     INNER JOIN Person.Person AS P ON C.PersonID=P.BusinessEntityID
WHERE(YEAR(SOH.DueDate)=2007)AND NOT EXISTS (SELECT C.CustomerID
                                             FROM Sales.SalesOrderHeader AS SOH
                                             WHERE(YEAR(SOH.DueDate)=2008)AND C.CustomerID=SOH.CustomerID)
ORDER BY C.CustomerID