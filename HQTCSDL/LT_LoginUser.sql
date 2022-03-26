﻿CREATE LOGIN NgMinhQuan WITH PASSWORD = 'sa'
GO
CREATE USER sa FOR LOGIN NgMinhQuan
GO
-- HOẶC CHO 1 CSDL CỤ THỂ
CREATE LOGIN iuh WITH PASSWORD='sa', DEFAULT_DATABASE= qlbh	--TẠO LOGIN CHO CSDL QLBH
CREATE USER iuh FOR LOGIN iuh	--TẠO USER CHO QLBH
--KHI VỪA TẠO SẼ KHÔNG DÙNG ĐƯỢC BẤT CỨ LỆNH NÀO. MUỐN DÙNG PHẢI CẤP QUYỀN

--CÚ PHÁP XÓA
DROP LOGIN NgMinhQuan
DROP USER sa

--CẤP QUYỀN DÙNG LỆNH SELECT CHO USER iuh TẠI BẢNG CHITIETHOADON
GRANT SELECT ON [dbo].[CHITIETDATHANG] TO iuh


--CẤP QUYỀN DÙNG LỆNH INSERT CHO USER iuh TẠI BẢNG CHITIETHOADON
GRANT INSERT ON [dbo].[LOAIHANG] TO iuh

GRANT SELECT ON [dbo].[LOAIHANG] TO iuh


--THU HỒI QUYỀN
REVOKE SELECT ON [dbo].[LOAIHANG] FROM iuh
