CREATE DATABASE QuanLyQuanCafe
GO

USE QuanLyQuanCafe
GO

--Food
--Table
--FoodCategory
--Account
--Bill
--BillInfo

CREATE TABLE TableFood
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Bàn chưa có tên',
	status NVARCHAR(100) NOT NULL DEFAULT N'Trống'	--Trống || Có người
)
GO

CREATE TABLE Account
(
	UserName NVARCHAR(100) PRIMARY KEY,
	DisplayName NVARCHAR(100) NOT NULL DEFAULT N'Anh',
	PassWord NVARCHAR(1000) NOT NULL,
	Type INT NOT NULL DEFAULT 0 -- 1: admin && 0 staff
)
GO

CREATE TABLE FoodCategory
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chưa đặt tên'
)
GO

CREATE TABLE Food
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chưa đặt tên',
	idCategory INT NOT NULL,
	price FLOAT NOT NULL

	FOREIGN KEY (idCategory) REFERENCES dbo.FoodCategory(id)
)
GO

CREATE TABLE Bill
(
	id INT IDENTITY PRIMARY KEY,
	DateCheckIn DATE NOT NULL DEFAULT GETDATE(),
	DateCheckOut DATE,
	idTable INT NOT NULL,
	status INT NOT NULL DEFAULT 0-- 1: đã thanh toán && 0: chưa thanh toán

	FOREIGN KEY (idTable) REFERENCES dbo.TableFood(id)
)
GO

CREATE TABLE BillInfo
(
	id INT IDENTITY PRIMARY KEY,
	idBill INT NOT NULL,
	idFood INT NOT NULL,
	count INT NOT NULL DEFAULT 0

	FOREIGN KEY (idBill) REFERENCES dbo.Bill(id),
	FOREIGN KEY (idFood) REFERENCES dbo.Food(id)
)
GO

INSERT INTO dbo.Account
(
	UserName,
	DisplayName,
	PassWord,
	Type
)
VALUES
(
	N'haianh',
	N'NguyenHaiAnh',
	N'1',
	1
)

INSERT INTO dbo.Account
(
	UserName,
	DisplayName,
	PassWord,
	Type
)
VALUES
(
	N'thanhdong',
	N'NguyenThanhDong',
	N'1',
	0
)
GO

CREATE PROC USP_GetAccountByUserName
@userName nvarchar(100)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @userName
END
GO

EXEC dbo.USP_GetAccountByUserName @userName = N'haianh'
GO

CREATE PROC USP_Login
@userName nvarchar(100), @passWord nvarchar(100)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @userName AND PassWord = @passWord
END
GO

--Thêm bàn
DECLARE @I INT = 0

WHILE @I <= 10
BEGIN
	INSERT dbo.TableFood (name) VALUES (N'Bàn ' + CAST(@i AS nvarchar(100)))
	SET @i = @i + 1
END
GO

CREATE PROC USP_GetTableList
AS SELECT * FROM dbo.TableFood
GO

UPDATE dbo.TableFood SET status = N'Có khách' WHERE id = 5

EXEC dbo.USP_GetTableList

--Thêm category
INSERT dbo.FoodCategory
(name)
VALUES
(N'Hải sản')

INSERT dbo.FoodCategory
(name)
VALUES
(N'Nông sản')

INSERT dbo.FoodCategory
(name)
VALUES
(N'Lâm sản')

INSERT dbo.FoodCategory
(name)
VALUES
(N'Nước')

--Thêm món ăn
INSERT dbo.Food
(name, idCategory, price)
VALUES
(N'Mực một nắng nước sa tế', 1, 120000)

INSERT dbo.Food
(name, idCategory, price)
VALUES
(N'Ngêu hấp xả', 1, 320000)

INSERT dbo.Food
(name, idCategory, price)
VALUES
(N'Dê nướng bóng đêm', 2, 99999999)

INSERT dbo.Food
(name, idCategory, price)
VALUES
(N'Heo rừng nước muối tiêu', 3, 500000)

INSERT dbo.Food
(name, idCategory, price)
VALUES
(N'Coca', 4, 10000)

INSERT dbo.Food
(name, idCategory, price)
VALUES
(N'7 up', 4, 10000)

--Thêm bill
INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), NULL, 1, 0)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), NULL, 2, 0)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), GETDATE(), 2, 1)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), GETDATE(), 3, 1)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), GETDATE(), 6, 1)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), GETDATE(), 4, 1)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), GETDATE(), 5, 1)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), NULL, 1, 0)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), GETDATE(), 6, 0)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), GETDATE(), 4, 0)

INSERT dbo.Bill
(DateCheckIn, DateCheckOut, idTable, status)
VALUES
(GETDATE(), GETDATE(), 5, 0)
GO

--Bill Info
INSERT dbo.BillInfo
(idBill, idFood, count)
VALUES
(3, 1, 2)

INSERT dbo.BillInfo
(idBill, idFood, count)
VALUES
(6, 3, 4)

INSERT dbo.BillInfo
(idBill, idFood, count)
VALUES
(4, 4, 2)

INSERT dbo.BillInfo
(idBill, idFood, count)
VALUES
(5, 2, 3)

INSERT dbo.BillInfo
(idBill, idFood, count)
VALUES
(2, 2, 3)
GO

CREATE PROC USP_InsertBill
@idTable INT
AS
BEGIN
	INSERT dbo.Bill
	(DateCheckIn, DateCheckOut, idTable, status)
	VALUES
	(
	GETDATE(),
	NULL,
	@idTable,
	0
	)
END
GO

CREATE PROC USP_InsertBillInfo
@idBill INT, @idFood INT, @count INT
AS
BEGIN
	DECLARE @isExitsBill INT
	DECLARE @foodCount INT = 1
	
	SELECT @isExitsBill = id, @foodCount = b.count
	FROM dbo.BillInfo AS b
	WHERE idBill = @idBill AND idFood = @idFood

	IF(@isExitsBill > 0)
	BEGIN
		DECLARE @newCount INT = @foodCount + @count
		IF(@newCount > 0)
			UPDATE dbo.BillInfo SET count = @foodCount + @count WHERE idFood = @idFood
		ELSE
			DELETE dbo.BillInfo WHERE idBill = @idBill AND idFood = @idFood
	END
	ELSE
	BEGIN
		INSERT dbo.BillInfo
		(idBill, idFood, count)
		VALUES
		(
			@idBill,
			@idFood,
			@count
		)
	END	
END
GO

DELETE dbo.BillInfo
DELETE dbo.Bill

CREATE TRIGGER UTG_UpdateBillInfo
ON dbo.BillInfo FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @idBill INT
	SELECT @idBill = idBill FROM Inserted
	DECLARE @idTable INT
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill AND status = 0
	UPDATE dbo.TableFood SET status = N'Có người' WHERE id = @idTable
END
GO

CREATE TRIGGER UTG_UpdateBill
ON dbo.Bill FOR UPDATE
AS
BEGIN
	DECLARE @idBill INT
	SELECT @idBill = ID from Inserted
	DECLARE @idTable INT
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill
	DECLARE @count int = 0
	SELECT @count = COUNT(*) FROM dbo.Bill WHERE idTable = @idTable AND status = 0
	IF(@count = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
END
GO

SELECT MAX(id) FROM dbo.Bill


SELECT * FROM dbo.BillInfo 
SELECT f.name, bi.count, f.price, f.price*bi.count AS totalprice FROM dbo.BillInfo AS bi, dbo.Bill AS b, dbo.Food AS f
WHERE bi.idBill = b.id AND bi.idFood = f.id AND b.status = 0 AND b.idTable = 3

SELECT * FROM dbo.Bill WHERE idTable = 6 AND status = 0

SELECT * FROM dbo.TableFood

SELECT * FROM dbo.Bill
SELECT * FROM dbo.BillInfo
SELECT * FROM dbo.Food
SELECT * FROM dbo.FoodCategory

SELECT * FROM dbo.Bill WHERE idTable = 2 AND status = 1