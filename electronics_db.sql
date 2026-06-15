-- ============================================================
-- Electronics Retail Database
-- ============================================================
-- Company   : Apex Electronics (fictional)
-- Platform  : SQLite 3.x  (standard SQL; compatible with MySQL / PostgreSQL
--             with minor type adjustments)
-- File      : electronics_db.sql
-- Contents  : DDL (CREATE TABLE) + DML (INSERT / UPDATE / DELETE)
-- ============================================================


-- ============================================================
-- PART 2 – SECTION 1: DDL  (Data Definition Language)
-- ============================================================

-- Drop tables in reverse FK order so the script is re-runnable.
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Categories;


-- ── Categories ────────────────────────────────────────────────
-- Lookup table for product categories.
-- Referenced by Products (CategoryID FK).
CREATE TABLE Categories (
    CategoryID   INTEGER      PRIMARY KEY AUTOINCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);


-- ── Suppliers ─────────────────────────────────────────────────
-- Companies that supply products to Apex Electronics.
-- Referenced by Products (SupplierID FK).
CREATE TABLE Suppliers (
    SupplierID   INTEGER      PRIMARY KEY AUTOINCREMENT,
    SupplierName VARCHAR(150) NOT NULL,
    Phone        VARCHAR(20),
    Email        VARCHAR(100) UNIQUE
);


-- ── Customers ─────────────────────────────────────────────────
-- End consumers who place orders.
-- Referenced by Orders (CustomerID FK).
CREATE TABLE Customers (
    CustomerID   INTEGER      PRIMARY KEY AUTOINCREMENT,
    CustomerName VARCHAR(150) NOT NULL,
    Phone        VARCHAR(20),
    Email        VARCHAR(100) UNIQUE,
    Address      VARCHAR(255)
);


-- ── Products ──────────────────────────────────────────────────
-- Master product catalogue with pricing and stock levels.
-- FK to Categories and Suppliers.
CREATE TABLE Products (
    ProductID    INTEGER        PRIMARY KEY AUTOINCREMENT,
    ProductName  VARCHAR(200)   NOT NULL,
    CategoryID   INTEGER        NOT NULL,
    SupplierID   INTEGER        NOT NULL,
    UnitPrice    DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    QOH          INTEGER        NOT NULL DEFAULT 0 CHECK (QOH >= 0),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);


-- ── Orders ────────────────────────────────────────────────────
-- Individual line items (one product per order row).
-- FK to Customers and Products.
-- OrderAmount is stored explicitly to preserve the price paid at
-- the time of purchase (UnitPrice may change later).
CREATE TABLE Orders (
    OrderID      INTEGER        PRIMARY KEY AUTOINCREMENT,
    CustomerID   INTEGER        NOT NULL,
    ProductID    INTEGER        NOT NULL,
    Quantity     INTEGER        NOT NULL CHECK (Quantity > 0),
    OrderAmount  DECIMAL(10, 2) NOT NULL CHECK (OrderAmount >= 0),
    OrderDate    DATE           NOT NULL,
    OrderTime    TIME           NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID)  REFERENCES Products(ProductID)
);


-- ============================================================
-- PART 2 – SECTION 2: DML  (Data Manipulation Language)
-- ============================================================


-- ── INSERT: Categories ────────────────────────────────────────
INSERT INTO Categories (CategoryName) VALUES ('Laptops & Computers');
INSERT INTO Categories (CategoryName) VALUES ('Smartphones');
INSERT INTO Categories (CategoryName) VALUES ('Audio & Headphones');
INSERT INTO Categories (CategoryName) VALUES ('Televisions & Displays');
INSERT INTO Categories (CategoryName) VALUES ('Accessories');
INSERT INTO Categories (CategoryName) VALUES ('Tablets');


-- ── INSERT: Suppliers ─────────────────────────────────────────
INSERT INTO Suppliers (SupplierName, Phone, Email)
    VALUES ('TechSource Inc.',          '(555) 100-1001', 'info@techsource.com');
INSERT INTO Suppliers (SupplierName, Phone, Email)
    VALUES ('Global Electronics Ltd.',  '(555) 100-1002', 'orders@globalelec.com');
INSERT INTO Suppliers (SupplierName, Phone, Email)
    VALUES ('ProTech Supplies',         '(555) 100-1003', 'supply@protech.com');
INSERT INTO Suppliers (SupplierName, Phone, Email)
    VALUES ('ElectroParts Co.',         '(555) 100-1004', 'sales@electroparts.com');
INSERT INTO Suppliers (SupplierName, Phone, Email)
    VALUES ('DigiWorld Distributors',   '(555) 100-1005', 'contact@digiworld.com');
-- Supplier 6 will be deleted below to demonstrate DELETE.
INSERT INTO Suppliers (SupplierName, Phone, Email)
    VALUES ('QuickShip Electronics',    '(555) 100-1006', 'qs@quickship.com');


-- ── INSERT: Customers ─────────────────────────────────────────
INSERT INTO Customers (CustomerName, Phone, Email, Address)
    VALUES ('John Smith',       '(555) 200-1001', 'john.smith@email.com',
            '123 Main St, Boston, MA 02101');
INSERT INTO Customers (CustomerName, Phone, Email, Address)
    VALUES ('Sarah Johnson',    '(555) 200-1002', 'sarah.j@email.com',
            '456 Oak Ave, Chicago, IL 60601');
INSERT INTO Customers (CustomerName, Phone, Email, Address)
    VALUES ('Michael Brown',    '(555) 200-1003', 'm.brown@email.com',
            '789 Pine Rd, Houston, TX 77001');
INSERT INTO Customers (CustomerName, Phone, Email, Address)
    VALUES ('Emily Davis',      '(555) 200-1004', 'emily.d@email.com',
            '321 Elm St, Phoenix, AZ 85001');
INSERT INTO Customers (CustomerName, Phone, Email, Address)
    VALUES ('Robert Wilson',    '(555) 200-1005', 'r.wilson@email.com',
            '654 Maple Dr, Seattle, WA 98101');
INSERT INTO Customers (CustomerName, Phone, Email, Address)
    VALUES ('Jennifer Martinez','(555) 200-1006', 'j.martinez@email.com',
            '987 Cedar Ln, Miami, FL 33101');


-- ── INSERT: Products ──────────────────────────────────────────
-- CategoryID: 1=Laptops, 2=Smartphones, 3=Audio, 4=TV, 5=Accessories, 6=Tablets
-- SupplierID: 1=TechSource, 2=GlobalElec, 3=ProTech, 4=ElectroParts, 5=DigiWorld
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, QOH)
    VALUES ('Dell XPS 15 Laptop',             1, 1, 1299.99,  45);
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, QOH)
    VALUES ('Samsung Galaxy S24 Ultra',        2, 2, 1199.99, 120);
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, QOH)
    VALUES ('Sony WH-1000XM5 Headphones',      3, 3,  349.99,  88);
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, QOH)
    VALUES ('LG C3 55" OLED TV',              4, 1, 1499.99,  22);
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, QOH)
    VALUES ('Anker USB-C 7-in-1 Hub',          5, 4,   49.99, 250);
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, QOH)
    VALUES ('Apple iPad Pro 12.9"',            6, 5, 1099.99,  67);
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, QOH)
    VALUES ('Apple MacBook Air M3',            1, 1, 1099.99,  55);


-- ── INSERT: Orders ────────────────────────────────────────────
INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderAmount, OrderDate, OrderTime)
    VALUES (1, 1, 1, 1299.99, '2024-01-15', '10:30:00');
INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderAmount, OrderDate, OrderTime)
    VALUES (2, 2, 2, 2399.98, '2024-01-16', '14:15:00');
INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderAmount, OrderDate, OrderTime)
    VALUES (3, 3, 1,  349.99, '2024-01-17', '09:45:00');
INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderAmount, OrderDate, OrderTime)
    VALUES (4, 5, 3,  149.97, '2024-01-18', '16:00:00');
INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderAmount, OrderDate, OrderTime)
    VALUES (5, 4, 1, 1499.99, '2024-01-19', '11:30:00');
-- Order 6 will be deleted below to demonstrate DELETE.
INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderAmount, OrderDate, OrderTime)
    VALUES (6, 6, 1, 1099.99, '2024-01-20', '13:00:00');


-- ── UPDATE statements ─────────────────────────────────────────

-- Update 1: Apply a price reduction to the Dell XPS 15 (market adjustment).
UPDATE Products
SET    UnitPrice = 1249.99
WHERE  ProductID = 1;

-- Update 2: Correct Sarah Johnson's email address after she reported a typo.
UPDATE Customers
SET    Email = 'sarah.johnson@email.com'
WHERE  CustomerID = 2;

-- Update 3: Reduce stock-on-hand for Galaxy S24 after fulfilling Order 2 (qty 2).
UPDATE Products
SET    QOH = QOH - 2
WHERE  ProductID = 2;


-- ── DELETE statements ─────────────────────────────────────────

-- Delete 1: Remove Order 6 — customer Jennifer Martinez cancelled her order.
DELETE FROM Orders
WHERE  OrderID = 6;

-- Delete 2: Remove QuickShip Electronics — partnership agreement was not finalised.
--           Safe to delete because no products reference SupplierID = 6.
DELETE FROM Suppliers
WHERE  SupplierID = 6;
