USE EnterpriseDQFramework;

-- ============================================================
-- EMPLOYEES TEST DATA
-- ============================================================
-- DQ scenarios:
--   NULL FirstName
--   Negative Salary
--   Salary > 100000
--   Future JoiningDate
--   Normal valid records
-- ============================================================

INSERT INTO Employees
(
    FirstName,
    LastName,
    Email,
    Department,
    Salary,
    JoiningDate,
    ManagerID
)
VALUES
('John',      'Doe',       'john@company.com',       'IT',        60000.00, '2023-05-10', 101),
('Sarah',     'Lee',       'sarah@company.com',      'HR',        55000.00, '2022-08-15', 102),
('Mike',      'Brown',     'mike@company.com',       'Finance',   70000.00, '2021-06-20', 103),
(NULL,        'White',     'anna@company.com',       'IT',        65000.00, '2023-01-01', 101),
('Tom',       'Clark',     'tom@company.com',        'Sales',    -50000.00, '2024-02-10', 104),
('Lucy',      'Scott',     'lucy@company.com',       'HR',        65000.00, '2028-01-01', 102),
('Peter',     'Hall',      'john@company.com',       'IT',        72000.00, '2020-03-12', 101),
('Nancy',     'Allen',     'nancy@company.com',      'Finance',   68000.00, '2021-09-09', 103),
('Kevin',     'Young',     'kevin@company.com',      'Finance',   75000.00, NULL,         103),
('Olivia',    'King',      'olivia@company.com',     'Marketing', 62000.00, '2022-11-18', NULL),
('Daniel',    'Wright',    'daniel@company.com',     'IT',        81000.00, '2020-01-15', 101),
('Emma',      'Green',     'emma@company.com',       'HR',        58000.00, '2023-04-12', 102),
('Robert',    'Adams',     'robert@company.com',     'Finance',   91000.00, '2019-07-20', 103),
('Sophia',    'Baker',     'sophia@company.com',     'Sales',     67000.00, '2022-05-11', 104),
('James',     'Nelson',    'james@company.com',      'IT',       105000.00, '2021-08-22', 101),
('Ava',       'Carter',    'ava@company.com',        'HR',        59000.00, '2023-09-01', 102),
('William',   'Mitchell',  'william@company.com',    'Finance',   73000.00, '2020-12-10', 103),
(NULL,        'Perez',     'liam@company.com',       'Sales',     64000.00, '2022-03-17', 104),
('Benjamin',  'Roberts',   'benjamin@company.com',   'IT',        88000.00, '2021-04-05', 101),
('Charlotte', 'Turner',    'charlotte@company.com',  'Marketing', 71000.00, '2022-10-30', 105),
('Alexander', 'Phillips',  'alexander@company.com',  'IT',       120000.00, '2020-06-18', 101),
('Amelia',    'Campbell',  'amelia@company.com',     'HR',        61000.00, '2023-02-25', 102),
('Henry',     'Parker',    'henry@company.com',      'Finance',  -10000.00, '2021-11-11', 103),
('Mia',       'Evans',     'mia@company.com',        'Sales',     69000.00, '2024-01-20', 104),
('Sebastian', 'Edwards',   'sebastian@company.com',  'IT',        95000.00, '2022-07-14', 101),
('Harper',    'Collins',   'harper@company.com',     'HR',        57000.00, '2023-06-06', 102),
('Jack',      'Stewart',   'jack@company.com',       'Finance',   83000.00, '2020-09-09', 103),
(NULL,        'Sanchez',   'ella@company.com',       'Sales',     66000.00, '2022-12-12', 104),
('Theodore',  'Morris',    'theodore@company.com',   'IT',        79000.00, '2021-02-02', 101),
('Ella',      'Rogers',    'ella.rogers@company.com','Marketing', 63000.00, '2023-10-10', 105);
GO