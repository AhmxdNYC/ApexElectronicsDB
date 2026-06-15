"""
run.py — Execute and verify electronics_db.sql
================================================
Reads electronics_db.sql, runs it against an in-memory SQLite
database, and prints verification queries to confirm the schema
and data are correct.

Usage:
    python run.py
"""

import sqlite3
import os


SQL_FILE = "electronics_db.sql"


def banner(title: str) -> None:
    print(f"\n{'=' * 60}")
    print(f"  {title}")
    print('=' * 60)


def run_select(cursor, title: str, sql: str, headers: list) -> None:
    """Execute a SELECT statement and print the results as a table."""
    cursor.execute(sql)
    rows = cursor.fetchall()
    print(f"\n  {title}  ({len(rows)} row(s))")
    col_w = [max(len(str(h)), max((len(str(r[i])) for r in rows), default=0))
             for i, h in enumerate(headers)]
    fmt   = "  " + "  ".join(f"{{:<{w}}}" for w in col_w)
    print(fmt.format(*headers))
    print("  " + "  ".join("-" * w for w in col_w))
    for row in rows:
        print(fmt.format(*[str(v) for v in row]))


def main() -> None:
    # ── Load SQL file ──────────────────────────────────────────
    if not os.path.exists(SQL_FILE):
        print(f"[ERROR] '{SQL_FILE}' not found.")
        return

    with open(SQL_FILE, "r") as f:
        sql_script = f.read()

    # ── Run against in-memory SQLite ───────────────────────────
    conn = sqlite3.connect(":memory:")
    conn.execute("PRAGMA foreign_keys = ON")
    cursor = conn.cursor()

    try:
        conn.executescript(sql_script)
        print(f"SQL script executed successfully.")
    except sqlite3.Error as e:
        print(f"[ERROR] SQL execution failed: {e}")
        conn.close()
        return

    # ── Verification queries ───────────────────────────────────
    banner("ROW COUNTS PER TABLE")
    for table in ("Categories", "Suppliers", "Customers", "Products", "Orders"):
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  {table:<12} : {count} row(s)")

    banner("CATEGORIES")
    run_select(cursor, "All categories", "SELECT * FROM Categories ORDER BY CategoryID",
               ["ID", "CategoryName"])

    banner("SUPPLIERS  (QuickShip deleted — expect 5 rows)")
    run_select(cursor, "All suppliers", "SELECT * FROM Suppliers ORDER BY SupplierID",
               ["ID", "SupplierName", "Phone", "Email"])

    banner("CUSTOMERS")
    run_select(cursor, "All customers  (Sarah's email updated)",
               "SELECT CustomerID, CustomerName, Email FROM Customers ORDER BY CustomerID",
               ["ID", "Name", "Email"])

    banner("PRODUCTS  (XPS price updated to 1249.99; Galaxy QOH reduced by 2)")
    run_select(cursor, "All products",
               "SELECT ProductID, ProductName, UnitPrice, QOH FROM Products ORDER BY ProductID",
               ["ID", "ProductName", "UnitPrice", "QOH"])

    banner("ORDERS  (Order 6 deleted — expect 5 rows)")
    run_select(cursor, "All orders",
               "SELECT * FROM Orders ORDER BY OrderID",
               ["OrderID", "CustID", "ProdID", "Qty", "Amount", "Date", "Time"])

    banner("JOIN QUERY — Orders with customer and product names")
    run_select(
        cursor,
        "Order details",
        """
        SELECT o.OrderID,
               c.CustomerName,
               p.ProductName,
               o.Quantity,
               o.OrderAmount,
               o.OrderDate
        FROM   Orders   o
        JOIN   Customers c ON o.CustomerID = c.CustomerID
        JOIN   Products  p ON o.ProductID  = p.ProductID
        ORDER  BY o.OrderID
        """,
        ["OrderID", "Customer", "Product", "Qty", "Amount", "Date"],
    )

    banner("JOIN QUERY — Products with category and supplier")
    run_select(
        cursor,
        "Product catalogue",
        """
        SELECT p.ProductID,
               p.ProductName,
               cat.CategoryName,
               sup.SupplierName,
               p.UnitPrice,
               p.QOH
        FROM   Products   p
        JOIN   Categories cat ON p.CategoryID = cat.CategoryID
        JOIN   Suppliers  sup ON p.SupplierID = sup.SupplierID
        ORDER  BY p.ProductID
        """,
        ["ID", "ProductName", "Category", "Supplier", "Price", "QOH"],
    )

    conn.close()
    banner("ALL CHECKS PASSED")


if __name__ == "__main__":
    main()
