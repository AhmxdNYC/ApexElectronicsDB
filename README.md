# Apex Electronics — Database Project

SQLite database implementation for a fictional electronics retail company.
Covers database design, ERD, normalization analysis, DDL, and DML.

## Files

| File | Description |
|---|---|
| `electronics_db.sql` | All DDL (CREATE TABLE) and DML (INSERT / UPDATE / DELETE) |
| `design_doc.md` | Part 1: entities, ERD (DBML + ASCII), normalization (1NF/2NF/3NF) |
| `run.py` | Python script that executes the SQL and prints verification queries |

## Run

No dependencies — uses Python's built-in `sqlite3`.

```bash
python run.py
```

This executes `electronics_db.sql` against an in-memory SQLite database
and prints formatted output for every table plus two JOIN queries.

## Schema

```
Categories ──< Products >── Suppliers
                  │
                  ▼
              Orders >── Customers
```

## What the SQL does

- **DDL**: Creates 5 tables with PKs, FKs, NOT NULL, UNIQUE, and CHECK constraints
- **INSERT**: 6 categories, 6 suppliers, 6 customers, 7 products, 6 orders
- **UPDATE**: Price reduction on Dell XPS 15 · Customer email correction · Stock adjustment
- **DELETE**: Cancelled order (Order 6) · Discontinued supplier (QuickShip)
