# Apex Electronics — Database Design Document

**Developer:** Ahmad  
**Company:** Apex Electronics (fictional)  
**Date:** June 2026

---

## Part 1 — Database Design

### 1. Entity Identification

The following five entities form the core database schema.

| Entity | Primary Key | Description |
|---|---|---|
| **Categories** | CategoryID | Lookup table grouping products into named categories |
| **Suppliers** | SupplierID | Companies that supply inventory to Apex Electronics |
| **Customers** | CustomerID | End consumers who place orders |
| **Products** | ProductID | Master product catalogue with pricing and stock levels |
| **Orders** | OrderID | Individual purchase transactions (one product per row) |

#### Attribute Detail

**Categories**
| Column | Data Type | Constraints | Description |
|---|---|---|---|
| CategoryID | INTEGER | PK, AUTOINCREMENT | Unique category identifier |
| CategoryName | VARCHAR(100) | NOT NULL, UNIQUE | Human-readable category label |

**Suppliers**
| Column | Data Type | Constraints | Description |
|---|---|---|---|
| SupplierID | INTEGER | PK, AUTOINCREMENT | Unique supplier identifier |
| SupplierName | VARCHAR(150) | NOT NULL | Legal business name |
| Phone | VARCHAR(20) | — | Contact phone number |
| Email | VARCHAR(100) | UNIQUE | Contact email address |

**Customers**
| Column | Data Type | Constraints | Description |
|---|---|---|---|
| CustomerID | INTEGER | PK, AUTOINCREMENT | Unique customer identifier |
| CustomerName | VARCHAR(150) | NOT NULL | Full name |
| Phone | VARCHAR(20) | — | Contact phone number |
| Email | VARCHAR(100) | UNIQUE | Contact email address |
| Address | VARCHAR(255) | — | Shipping / billing address |

**Products**
| Column | Data Type | Constraints | Description |
|---|---|---|---|
| ProductID | INTEGER | PK, AUTOINCREMENT | Unique product identifier |
| ProductName | VARCHAR(200) | NOT NULL | Full product description |
| CategoryID | INTEGER | FK → Categories | Product classification |
| SupplierID | INTEGER | FK → Suppliers | Sourcing supplier |
| UnitPrice | DECIMAL(10,2) | NOT NULL, ≥ 0 | Current selling price |
| QOH | INTEGER | NOT NULL, DEFAULT 0, ≥ 0 | Quantity on hand |

**Orders**
| Column | Data Type | Constraints | Description |
|---|---|---|---|
| OrderID | INTEGER | PK, AUTOINCREMENT | Unique order identifier |
| CustomerID | INTEGER | FK → Customers | Purchasing customer |
| ProductID | INTEGER | FK → Products | Item purchased |
| Quantity | INTEGER | NOT NULL, > 0 | Units purchased |
| OrderAmount | DECIMAL(10,2) | NOT NULL, ≥ 0 | Total charged at time of sale |
| OrderDate | DATE | NOT NULL | Calendar date of order |
| OrderTime | TIME | NOT NULL | Clock time of order |

---

### 2. Entity Relationship Diagram (ERD)

#### DBML Notation (paste into dbdiagram.io to render)

```dbml
Table Categories {
  CategoryID   integer [pk, increment]
  CategoryName varchar(100) [not null, unique]
}

Table Suppliers {
  SupplierID   integer [pk, increment]
  SupplierName varchar(150) [not null]
  Phone        varchar(20)
  Email        varchar(100) [unique]
}

Table Customers {
  CustomerID   integer [pk, increment]
  CustomerName varchar(150) [not null]
  Phone        varchar(20)
  Email        varchar(100) [unique]
  Address      varchar(255)
}

Table Products {
  ProductID   integer [pk, increment]
  ProductName varchar(200) [not null]
  CategoryID  integer [ref: > Categories.CategoryID]
  SupplierID  integer [ref: > Suppliers.SupplierID]
  UnitPrice   decimal(10,2) [not null]
  QOH         integer [not null, default: 0]
}

Table Orders {
  OrderID     integer [pk, increment]
  CustomerID  integer [ref: > Customers.CustomerID]
  ProductID   integer [ref: > Products.ProductID]
  Quantity    integer [not null]
  OrderAmount decimal(10,2) [not null]
  OrderDate   date [not null]
  OrderTime   time [not null]
}
```

#### Cardinality Summary

| Relationship | Type | Description |
|---|---|---|
| Categories → Products | One-to-Many | One category classifies many products |
| Suppliers → Products | One-to-Many | One supplier provides many products |
| Customers → Orders | One-to-Many | One customer places many orders |
| Products → Orders | One-to-Many | One product can appear in many orders |

#### ASCII ERD

```
Categories          Suppliers           Customers
┌────────────┐      ┌─────────────┐     ┌─────────────┐
│ CategoryID │PK    │ SupplierID  │PK   │ CustomerID  │PK
│ CategoryName│     │ SupplierName│     │ CustomerName│
└─────┬──────┘      │ Phone       │     │ Phone       │
      │ 1           │ Email       │     │ Email       │
      │             └──────┬──────┘     │ Address     │
      │ M                  │ 1          └──────┬──────┘
      ▼                    │ M                 │ 1
┌─────────────────────┐    │                   │ M
│ Products            │◄───┘                   ▼
│ ProductID      PK   │              ┌──────────────────┐
│ ProductName         │              │ Orders           │
│ CategoryID  FK──────┘              │ OrderID     PK   │
│ SupplierID  FK                     │ CustomerID  FK───┘
│ UnitPrice                          │ ProductID   FK───┐
│ QOH                │               │ Quantity         │
└────────────────┬───┘               │ OrderAmount      │
                 │ 1                 │ OrderDate        │
                 └───────────────────│ OrderTime        │
                       M             └──────────────────┘
```

---

### 3. Normalization and Denormalization

#### First Normal Form (1NF)

The schema satisfies 1NF because every attribute across all five tables contains only **atomic** (indivisible) values — there are no multi-valued attributes or repeating groups embedded in a single cell. For example, a customer's phone number occupies exactly one column in the Customers table rather than being stored as a comma-separated list inside a single field. Every table has a clearly defined **primary key** — CategoryID, SupplierID, CustomerID, ProductID, and OrderID respectively — which uniquely identifies each row and prevents duplicate records. The use of `AUTOINCREMENT` ensures each key is unique and system-generated, eliminating the possibility of accidental duplicate primary key values. The OrderDate and OrderTime are stored as separate columns with distinct data types (DATE and TIME), rather than as a single ambiguous text string, reinforcing atomicity. No table contains a column that is itself a list or an array; instead, relationships between records are expressed through foreign keys and separate rows, which is the correct relational approach.

#### Second Normal Form (2NF)

The schema satisfies 2NF because all five tables use **single-column primary keys**. A violation of 2NF requires a composite primary key where a non-key attribute depends on only part of that key (a partial dependency). Because none of the tables use composite keys, partial dependencies are structurally impossible, and 2NF is trivially satisfied. For instance, Products could theoretically have used a composite key of (ProductName, SupplierID), which would have risked partial dependencies — but the design instead uses a surrogate key (ProductID), making the table fully 2NF-compliant. Similarly, Orders uses a surrogate OrderID rather than a composite key of (CustomerID, ProductID, OrderDate), which further prevents partial dependencies and simplifies future queries.

#### Third Normal Form (3NF)

The schema satisfies 3NF because there are **no transitive dependencies** — that is, no non-key attribute depends on another non-key attribute rather than directly on the primary key. The key design decisions that enforce 3NF are: (1) CategoryName is stored in the Categories table and referenced from Products by CategoryID FK — if CategoryName were stored directly in Products, then CategoryName would transitively depend on CategoryID (non-key) rather than directly on ProductID (the key); (2) SupplierName, Phone, and Email are stored in Suppliers and referenced from Products by SupplierID FK — storing supplier details inside the Products table would create a transitive dependency through SupplierID; (3) CustomerName and Address are stored in Customers and referenced from Orders by CustomerID FK — duplicating those attributes in Orders would violate 3NF. By separating each entity into its own table, every non-key attribute depends directly and only on its table's primary key.

#### Denormalization Discussion

While normalization reduces redundancy and improves data integrity, **denormalization** can be strategically applied to improve query performance. The most deliberate denormalization in this schema is the **OrderAmount** column in the Orders table. Mathematically, OrderAmount could be computed on demand as `Quantity × Products.UnitPrice`, which would eliminate the column entirely. However, storing it explicitly is intentional: product prices change over time, and recalculating order totals using the current UnitPrice would produce historically incorrect results. Storing OrderAmount at the time of purchase preserves an accurate record of what the customer actually paid. This trade-off accepts a small degree of redundancy in exchange for historical accuracy and simpler reporting queries. In a large-scale production system, additional denormalization might include caching CategoryName directly in a flattened product view, or pre-aggregating total sales per customer — both of which trade some consistency risk for faster read performance.

---

## References

Codd, E. F. (1970). A relational model of data for large shared data banks. *Communications of the ACM, 13*(6), 377–387. https://doi.org/10.1145/362384.362685

SQLite Consortium. (2024). *SQLite documentation: Data types*. https://www.sqlite.org/datatype3.html

Ramakrishnan, R., & Gehrke, J. (2003). *Database management systems* (3rd ed.). McGraw-Hill.

Date, C. J. (2004). *An introduction to database systems* (8th ed.). Addison-Wesley.

dbdiagram.io. (2024). *Database diagram tool*. Holistics Software. https://dbdiagram.io
