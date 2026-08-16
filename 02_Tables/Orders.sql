USE EnterpriseDQFramework;

CREATE TABLE Orders
(
    OrderID INT PRIMARY KEY IDENTITY(1,1),

    CustomerID INT,

    ProductID INT,

    OrderDate DATE,

    Quantity INT,

    OrderAmount DECIMAL(10,2),

    OrderStatus VARCHAR(50)
);
