-- ========================================================= 
-- SQL Practice with Chinook Database 
-- Author: Ziad Bassem
-- Date: Week 2 of AI/ML Roadmap
-- Database: Chinook_Sqlite.sqlite
--
-- Organized by sections: SELECT, Filtering, Joins, Aggregations,
-- Subqueries, Advanced topics.
-- =========================================================

/* =========================================================
   1. Basic SELECT and LIMIT
   ========================================================= */
-- Select all customers
SELECT * FROM Customer;

-- Top 10 albums
SELECT * FROM Album LIMIT 10;

-- Show first name, last name and email of customers
SELECT FirstName, LastName, Email FROM Customer;

/* =========================================================
   2. Filtering (WHERE, LIKE, BETWEEN)
   ========================================================= */
-- Customers from Brazil
SELECT FirstName, LastName, Country 
FROM Customer
WHERE Country = 'Brazil';

-- Tracks longer than 5 minutes
SELECT Name, Milliseconds 
FROM Track
WHERE Milliseconds > 300000;

-- Employees hired between 2002 and 2004
SELECT FirstName, LastName, HireDate 
FROM Employee
WHERE HireDate BETWEEN '2002-01-01' AND '2004-12-31';

-- Customers whose name starts with 'A'
SELECT FirstName, LastName 
FROM Customer
WHERE FirstName LIKE 'A%';

/* =========================================================
   3. Sorting & Distinct Values
   ========================================================= */
-- Order customers by country
SELECT FirstName, LastName, Country 
FROM Customer
ORDER BY Country ASC;

-- Distinct countries with customers
SELECT DISTINCT Country 
FROM Customer
ORDER BY Country;

/* =========================================================
   4. JOINS (INNER, LEFT)
   ========================================================= */
-- Tracks and their album titles
SELECT t.Name AS Track, a.Title AS Album
FROM Track t
JOIN Album a ON t.AlbumId = a.AlbumId;

-- Tracks with album and artist
SELECT t.Name AS Track, a.Title AS Album, ar.Name AS Artist
FROM Track t
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
LIMIT 20;

-- All customers and their invoice totals
SELECT c.FirstName, c.LastName, i.InvoiceId, i.Total
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId;

/* =========================================================
   5. Aggregations (SUM, COUNT, AVG, GROUP BY, HAVING)
   ========================================================= */
-- Total revenue per customer
SELECT c.FirstName, c.LastName, SUM(i.Total) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY TotalSpent DESC;

-- Top 5 countries by revenue
SELECT BillingCountry, SUM(Total) AS Revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY Revenue DESC
LIMIT 5;

-- Average track length per genre
SELECT g.Name AS Genre, AVG(Milliseconds) AS AvgLength
FROM Track t
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY AvgLength DESC;

-- Countries with more than 10 invoices
SELECT BillingCountry, COUNT(*) AS NumInvoices
FROM Invoice
GROUP BY BillingCountry
HAVING COUNT(*) > 10;

/* =========================================================
   6. Subqueries
   ========================================================= */
-- Customers who spent above average
SELECT FirstName, LastName, CustomerId
FROM Customer
WHERE CustomerId IN (
  SELECT CustomerId 
  FROM Invoice
  GROUP BY CustomerId
  HAVING SUM(Total) > (SELECT AVG(Total) FROM Invoice)
);

-- Tracks longer than the average track length
SELECT Name, Milliseconds
FROM Track
WHERE Milliseconds > (SELECT AVG(Milliseconds) FROM Track);

-- Employees with salary >= max salary of 'Sales Support Agent'
-- (salary column doesn’t exist in Chinook, but as example):
-- SELECT * FROM Employee WHERE Salary >= (SELECT MAX(Salary) FROM Employee WHERE Title='Sales Support Agent');

/* =========================================================
   7. Advanced Joins
   ========================================================= */
-- Invoice details: customer + invoice + invoice lines
SELECT c.FirstName, c.LastName, i.InvoiceId, i.InvoiceDate, il.UnitPrice, il.Quantity, t.Name AS Track
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
LIMIT 20;

/* =========================================================
   8. Nested Aggregations & Complex Queries
   ========================================================= */
-- Top 5 best-selling tracks by quantity
SELECT t.Name, SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.Name
ORDER BY UnitsSold DESC
LIMIT 5;

-- Best customer by revenue in each country
SELECT BillingCountry, FirstName, LastName, MAX(TotalSpent) as MaxSpent
FROM (
  SELECT c.CustomerId, c.FirstName, c.LastName, i.BillingCountry, SUM(i.Total) AS TotalSpent
  FROM Customer c
  JOIN Invoice i ON c.CustomerId = i.CustomerId
  GROUP BY c.CustomerId
)
GROUP BY BillingCountry
ORDER BY BillingCountry;

/* =========================================================
   9. Views (if SQLite supported CREATE VIEW)
   ========================================================= */
-- Example (won’t persist unless you use CREATE VIEW):
-- CREATE VIEW CustomerSales AS
-- SELECT c.CustomerId, c.FirstName, c.LastName, SUM(i.Total) AS TotalSpent
-- FROM Customer c
-- JOIN Invoice i ON c.CustomerId = i.CustomerId
-- GROUP BY c.CustomerId;