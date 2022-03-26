--1. Viết một thủ tục tính tổng số hàng tồn kho (UnitsInStock) của từng nhà cung cấp trong một quốc gia nào đó, thông tin gồm: SupplierID, SumOfUnitsInStock
CREATE PROC tinhTonKho @tp NVARCHAR(15)
AS BEGIN
    SELECT S.SupplierID, SUM(P.UnitsInStock) AS SumOfUnitsInStock
    FROM Suppliers AS S
         INNER JOIN Products AS P ON S.SupplierID=P.SupplierID
    WHERE S.Country=@tp
    group by S.SupplierID
END

DECLARE @tp NVARCHAR(15)
SET @tp='USA'
IF EXISTS (SELECT * FROM Suppliers WHERE Country=@tp)EXEC tinhTonKho @tp ELSE PRINT('khong ton tai TP NAY')

--2. Viết hàm trên CountOfProducts (dạng scalar function) với tham số @MaNhom, giá trị truyền vào lấy từ field CategoryID, hàm trả về số sản phẩm tương ứng với mã nhóm hàng. 
--Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các nhóm hàng cùng với số sản phẩm thuốc mỗi nhóm, thông tin gồm: CategoryID, CategoryName, CountOfProduct.

CREATE FUNCTION CountOfProducts(@MaNhom INT)
RETURNS INT
AS BEGIN
    DECLARE @CountOfProduct INT
    SELECT @CountOfProduct=COUNT(P.ProductID)
    FROM Categories AS C
         INNER JOIN Products AS P ON C.CategoryID=P.CategoryID
    WHERE C.CategoryID=@MaNhom
    RETURN @CountOfProduct
END

--DROP FUNCTION CountOfProducts

DECLARE @MaNhom INT
SET @MaNhom = 1
PRINT N'SỐ LƯỢNG SẢN PHẨM THUỘC MÃ NHÓM ' + CONVERT(CHAR(5), @MaNhom) + N' LÀ ' + CONVERT(CHAR(5), DBO.CountOfProducts(@MaNhom))

SELECT C.CategoryID, C.CategoryName, COUNT(P.ProductID) AS CountOfProduct
FROM Categories AS C
     INNER JOIN Products AS P ON C.CategoryID=P.CategoryID
GROUP BY C.CategoryID, C.CategoryName