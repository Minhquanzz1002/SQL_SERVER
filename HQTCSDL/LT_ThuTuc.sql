--III) Stored Procedure
--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một				/*THẦY ĐÃ SỬA*/
--tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, 
--thông tin gồm: CustomerID, SumofTotalDue =Sum(TotalDue)
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
--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của				/*THẦY ĐÃ SỬA*/
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số 
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số 
-- @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục. 
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
SET @SalesPerson=279
IF EXISTS (SELECT * FROM Sales.SalesPerson AS SP WHERE BusinessEntityID=@SalesPerson)BEGIN
    EXEC tongDanhThu @SalesPerson, @SalesYTD OUT
    PRINT 'Danh thu cua nhan vien '+CONVERT(CHAR(5), @SalesPerson)+' la'+CONVERT(CHAR(15), @SalesYTD)
END
ELSE PRINT 'Nhan vien khong ton tai'

--3) Viết một thủ tục trả về một danh sách các sản phẩm có giá không vượt quá một 
--giá trị được chỉ định, với tham số input @Product và @MaxPrice, tham số 
--output @ComparePrice và ListPrice 
CREATE PROC dsspGiaVuotChiDinh @Product INT, @MaxPrice MONEY, @ComparePrice MONEY OUTPUT, @ListPrice MONEY OUTPUT
AS BEGIN
	

END
GO

--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho nhân viên bán 
--hàng (SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng 
--mới bằng mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), sumofSubTotal. Trong đó: 
--SumofSubTotal =sum(SubTotal) 
--NewBonus = Bonus+ sum(SubTotal)*0.01 

--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số 
--input), thông tin gồm: ProductCategoryID, Name, SumofQty. Dữ liệu từ bảng 
--ProductCategory, ProductSubcategory, Product và SalesOrderDetail (Lưu ý: 
--dùng subquery) 

--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra 
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả 
--về trạng thái thành công hay thất bại của thủ tục.

--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo 
--năm đã cho.

--8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin 
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not 
--null và các field là khóa ngoại.

--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader 
--khi biết SalesOrderID. Lưu ý trước khi xóa mẫu tin trong 
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong 
--Sales.SalesOrderDetail. Nếu không xoá được hoá đơn thì cũng không được phép 
--xóa Sales.SalesOrderDetail của hóa đơn đó.

--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice lên 
--10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm này.
