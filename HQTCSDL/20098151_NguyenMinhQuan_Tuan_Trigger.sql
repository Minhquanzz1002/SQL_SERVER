--TRIGGER
--1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
-- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau: 

CREATE TABLE M_Department (DepartmentID INT NOT NULL PRIMARY KEY,
Name NVARCHAR(50),
GroupName NVARCHAR(50))

CREATE TABLE M_Employees (EmployeeID INT NOT NULL PRIMARY KEY,
Firstname NVARCHAR(50),
MiddleName NVARCHAR(50),
LastName NVARCHAR(50),
DepartmentID INT FOREIGN KEY REFERENCES M_Department(DepartmentID))

-- Tạo một view tên EmpDepart_view bao gồm các field: EmployeeID,
--FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa 
--trên 2 bảng M_Employees và M_Department.
CREATE VIEW EmpDepart_view
AS
SELECT E.EmployeeID, E.Firstname, E.MiddleName, E.LastName, D.DepartmentID, D.Name, D.GroupName
FROM M_Department AS D
     INNER JOIN M_Employees AS E ON D.DepartmentID=E.DepartmentID

DROP VIEW EmpDepart_view

SELECT * FROM EmpDepart_view
-- Tạo một trigger tên InsteadOf_Trigger thực hiện trên view EmpDepart_view, 
--dùng để chèn dữ liệu vào các bảng M_Employees và M_Department khi chèn 
--một record mới thông qua view EmpDepart_view.
CREATE TRIGGER InsteadOf_Trigger
ON EmpDepart_view
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @EmployeeID INT, @DepartmentID INT
    SET @EmployeeID=(SELECT EmployeeID FROM INSERTED)
    SET @DepartmentID=(SELECT DepartmentID FROM INSERTED)
    IF EXISTS (SELECT * FROM EmpDepart_view WHERE @DepartmentID=DepartmentID AND @EmployeeID=EmployeeID)
        PRINT N'ĐÃ TỒN TẠI'
    ELSE BEGIN
        INSERT INTO M_Department SELECT DepartmentID, Name, GroupName FROM INSERTED 
		INSERT INTO M_Employees SELECT EmployeeID, Firstname, MiddleName, LastName, DepartmentID FROM INSERTED
    END
END

DROP TRIGGER InsteadOf_Trigger

--Dữ liệu test:
INSERT INTO EmpDepart_view(EmployeeID, Firstname, MiddleName, LastName, DepartmentID, Name, GroupName) VALUES(1, 'Nguyen','Hoang','Huy', 12,'Marketing','Sales')

SELECT * FROM EmpDepart_view

DROP TABLE [dbo].[M_Department]
DROP TABLE [dbo].[M_Employees]

CREATE TRIGGER InsteadOf_Trigger2
ON EmpDepart_view
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @EmployeeID INT, @DepartmentID INT
    SET @EmployeeID=(SELECT EmployeeID FROM INSERTED)
    SET @DepartmentID=(SELECT DepartmentID FROM INSERTED)
    IF EXISTS (SELECT * FROM EmpDepart_view WHERE @DepartmentID=DepartmentID AND @EmployeeID=EmployeeID)
		BEGIN
		BEGIN
        IF EXISTS (SELECT * FROM EmpDepart_view WHERE @DepartmentID=DepartmentID)
			PRINT N'MÃ PHÒNG BAN ' +CONVERT(CHAR(10), @DepartmentID) + N' ĐÃ TỒN TẠI'END
        IF EXISTS (SELECT * FROM EmpDepart_view WHERE @EmployeeID=EmployeeID)
			PRINT N'MÃ NHÂN VIÊN ' +CONVERT(CHAR(10), @EmployeeID) + N' ĐÃ TỒN TẠI'
		END
    ELSE BEGIN
        INSERT INTO M_Department
        SELECT DepartmentID, Name, GroupName FROM INSERTED
        INSERT INTO M_Employees
        SELECT EmployeeID, Firstname, MiddleName, LastName, DepartmentID
        FROM INSERTED
    END
END

DROP TRIGGER InsteadOf_Trigger2
