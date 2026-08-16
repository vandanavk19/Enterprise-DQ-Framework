USE EnterpriseDQFramework;

CREATE TABLE Products
(
    ProductID INT PRIMARY KEY IDENTITY(1,1),

    ProductName VARCHAR(100),

    Category VARCHAR(100),

    Price DECIMAL(10,2),

    StockQuantity INT,

    SupplierName VARCHAR(100),

    CreatedDate DATE DEFAULT GETDATE()
);
