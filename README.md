# Auditorium Database Management System (`Auditorium_sari`)

A robust relational database project built with T-SQL (SQL Server), designed to manage auditorium operations including artists, shows, ticket pricing, customer records, and order tracking. This project highlights advanced server-side database programming, complex querying, and schema optimization.

---

## Database Schema & Architecture

The database consists of 5 core relational tables with defined primary/foreign key constraints and performance-optimized indexes:

* **`artist`**: Stores artist profile information (ID, name, city, phone). Indexed on `city`.
* **`shows`**: Manages event details (show ID, type, artist reference, start time, duration, and date). Foreign key linked to `artist`. Indexed on `IdArtist` and `dateShow`.
* **`cards`** (Tickets): Defines ticket categories, pricing, quantities, and associated shows. Foreign key linked to `shows`. Indexed on `IdShow`.
* **`customers`**: Stores customer information (ID, name, phone, city). Indexed on `city`.
* **`orders`**: Handles ticket bookings and transaction history, linking customers, shows, and specific ticket codes. Foreign keys linked to `customers`, `shows`, and `cards`. Indexed on all foreign key columns.

---

## Advanced T-SQL Features & Programming

The repository implements advanced server-side programming concepts:

### Stored Procedures
1. **`AmountShows`**: 
   * Utilizes Common Table Expressions (CTEs), `INNER JOIN`, and `GROUP BY` to aggregate bookings per show.
   * Returns the total count of attendees for the year 2025 via an `OUTPUT` parameter.
2. **`InvitedShow`**: 
   * Employs a Self-Join and `STRING_AGG` to generate a comma-separated list of distinct shows booked by each customer.
3. **`pivotProc`**: 
   * Implements Dynamic SQL (`sp_executesql`) combined with `PIVOT`, `QUOTENAME`, and `STRING_AGG` to dynamically display artists per city ordered by chronological appearance rank.

### User-Defined Functions (UDFs)
1. **`GetCityMostArtists` (Multi-Statement Table-Valued Function)**: 
   * Uses Window Functions (`ROW_NUMBER() OVER (PARTITION BY ...)` ordered by `MIN(dateShow)`) to rank artists within each city based on their earliest show date.
2. **`GetFirstArtistCustomer` (Scalar Function)**: 
   * Leverages Set Operations (`INTERSECT`) to identify and return an individual who is registered as both an artist and a customer.

---

## Technologies & Concepts
* **DBMS:** Microsoft SQL Server (T-SQL)
* **Core Concepts:** Relational Schema Design, Index Optimization, Stored Procedures, Scalar & Table-Valued Functions, CTEs, Window Functions, Dynamic SQL (`sp_executesql`), PIVOT Tables, and Set Operations (`INTERSECT`).
