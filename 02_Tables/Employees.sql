USE EnterpriseDQFramework;

CREATE TABLE Employees
(
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),

    FirstName VARCHAR(100),

    LastName VARCHAR(100),

    Email VARCHAR(255),

    Department VARCHAR(100),

    Salary DECIMAL(10,2),

    JoiningDate DATE,

    ManagerID INT
);