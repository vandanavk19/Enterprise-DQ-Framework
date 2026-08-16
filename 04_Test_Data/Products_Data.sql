USE EnterpriseDQFramework;

-- ============================================================
-- PRODUCTS TEST DATA
-- ============================================================
-- DQ scenarios:
--   NULL ProductName
--   Negative Price
--   Excessive Price
--   Normal valid records
-- ============================================================

INSERT INTO Products
(
    ProductName,
    Category,
    Price,
    StockQuantity,
    SupplierName,
    CreatedDate
)
VALUES
('Laptop',        'Electronics', 65000.00, 20,  'Dell',       '2026-01-01'),
('Mouse',         'Electronics',   800.00, 100, 'Logitech',   '2026-01-02'),
(NULL,            'Electronics',  1500.00, 60,  'HP',         '2026-01-03'),
('Monitor',       'Electronics', -12000.00,15,  'Samsung',    '2026-01-04'),
('Headphones',    'Electronics',  2500.00, 40,  'Sony',       '2026-01-05'),
('Desk',          'Furniture',    7000.00, 25,  'IKEA',       '2026-01-06'),
('Chair',         'Furniture',    3500.00, 40,  'IKEA',       '2026-01-07'),
('Laptop Stand',  'Accessories',  2200.00, 30,  'Amazon',     '2026-01-08'),
('USB Cable',     'Accessories',   300.00, 200, 'Boat',       '2026-01-09'),
('Webcam',        'Electronics',  2200.00, 30,  'Logitech',   '2026-01-10'),
('Keyboard',      'Electronics',  1500.00, 60,  'HP',         '2026-02-01'),
('Tablet',        'Electronics', 45000.00, 15,  'Samsung',    '2026-02-02'),
('Smartphone',    'Electronics', 55000.00, 25,  'Apple',      '2026-02-03'),
('Printer',       'Electronics', 12000.00, 10,  'Canon',      '2026-02-04'),
('Office Chair',  'Furniture',    9500.00, 18,  'IKEA',       '2026-02-05'),
('Bookshelf',     'Furniture',    6200.00, 12,  'IKEA',       '2026-02-06'),
('Desk Lamp',     'Electronics',  1800.00, 45,  'Philips',    '2026-02-07'),
('Power Bank',    'Accessories',  3200.00, 50,  'Boat',       '2026-02-08'),
('SSD 1TB',       'Electronics',  8500.00, 35,  'Samsung',    '2026-02-09'),
('Router',        'Electronics',  4200.00, 28,  'TP-Link',    '2026-02-10'),
('External HDD',  'Electronics',  6800.00, 22,  'Seagate',    '2026-03-01'),
('Microphone',    'Electronics',  5500.00, 18,  'Sony',       '2026-03-02'),
('Gaming Chair',  'Furniture',   18000.00, 10,  'IKEA',       '2026-03-03'),
('Office Desk',   'Furniture',   15000.00, 8,   'IKEA',       '2026-03-04'),
('Smart Watch',   'Electronics', 22000.00, 20,  'Samsung',    '2026-03-05'),
('Air Purifier',  'Electronics', 28000.00, 12,  'Philips',    '2026-03-06'),
('Projector',     'Electronics', 45000.00, 7,   'Epson',      '2026-03-07'),
('Camera',        'Electronics', 75000.00, 9,   'Canon',      '2026-03-08'),
('Server',        'Electronics', 150000.00, 3,  'Dell',       '2026-03-09'),
('Network Switch','Electronics',  9500.00, 14,  'Cisco',      '2026-03-10');
GO
