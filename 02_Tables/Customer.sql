USE EnterpriseDQFramework;

CREATE TABLE Customer
(
    CustomerID INT PRIMARY KEY IDENTITY(1,1),

    FirstName VARCHAR(100),

    LastName VARCHAR(100),

    Email VARCHAR(255),

    Age INT,

    PhoneNumber VARCHAR(20),

    City VARCHAR(100),

    CreatedDate DATE DEFAULT GETDATE()
);