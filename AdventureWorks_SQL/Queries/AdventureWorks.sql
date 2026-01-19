
--QUESTION 1:Provide the top 10 customers (full name) by revenue
--List the country they shipped to, the cities, and their revenue (calculated as OrderQty * UnitPrice).

SELECT TOP 10  
    CONCAT(C.FirstName, ' ', C.LastName) AS "FULL NAME",  
    A.CountryRegion AS "COUNTRY SHIPPED TO",  
    A.City AS "CITY SHIPPED TO",  
    SUM(O.OrderQty * O.UnitPrice) AS REVENUE  
FROM SalesLT.SalesOrderHeader AS H  
JOIN SalesLT.Customer AS C  
    ON H.CustomerID = C.CustomerID  
JOIN SalesLT.SalesOrderDetail AS O  
    ON H.SalesOrderID = O.SalesOrderID  
JOIN SalesLT.Address AS A  
    ON H.ShipToAddressID = A.AddressID  
GROUP BY CONCAT(C.FirstName, ' ', C.LastName), A.CountryRegion, A.City  
ORDER BY REVENUE DESC;


--QUESTION 2:Create four distinct Customer segments using the total revenue (OrderQty * UnitPrice) by customer.
--List the customer details (ID, Company Name), revenue, and the segment the customer belongs to.

--Four customer segments by revenue are created below as follows:
--When customer total revenue is less than 5000, it is classified as 'low revenue'
--When customer total revenue is between 5,001 and 10,000 it is classified as 'Medium revenue'
--When customer total revenue is between 10,001 and 15,000 it is classified as 'High revenue'
--When customer total revenue is greater than 15,000 it is classified as'Top revenue'

SELECT 
    C.CustomerID AS "CUSTOMER ID",
    C.CompanyName AS "COMPANY NAME",
  SUM(O.OrderQty * O.UnitPrice) AS "TOTAL REVENUE",
    CASE
        WHEN SUM(O.OrderQty * O.UnitPrice) <= 5000 THEN 'Low Revenue'  
        WHEN SUM(O.OrderQty * O.UnitPrice) BETWEEN 5001 AND 10000 THEN 'Medium Revenue'  
        WHEN SUM(O.OrderQty * O.UnitPrice) BETWEEN 10001 AND 15000 THEN 'High Revenue'  
        WHEN SUM(O.OrderQty * O.UnitPrice) > 15000 THEN 'Top Revenue'  
    END AS "CUSTOMER SEGMENT"
FROM
SalesLT.SalesOrderHeader as H
JOIN SalesLT.SalesOrderDetail as O
    ON H.SalesOrderID = O.SalesOrderID
JOIN SalesLT.Customer as C
    ON H.CustomerID = C.CustomerID
	GROUP BY C.CustomerID, C.CompanyName
	ORDER BY 
	[CUSTOMER SEGMENT] DESC;



	--QUESTION 3:What products, along with their respective categories, did our customers buy on our last day of business?
	-- List the CustomerID, Product ID, Product Name, Category Name and the Order Date

SELECT
C.CustomerID AS "CUSTOMER ID",
O.ProductID AS "PRODUCT ID",
P.Name AS "PRODUCT NAME",
PC.Name AS "CATEGORY NAME",
H.OrderDate AS "ORDER DATE"
FROM
SalesLT.SalesOrderHeader AS H
JOIN SalesLT.Customer AS C
  ON H.CustomerID = C.CustomerID
JOIN SalesLT.SalesOrderDetail AS O
  ON H.SalesOrderID = O.SalesOrderID
JOIN SalesLT.Product AS P
  ON O.ProductID = P.ProductID
JOIN SalesLT.ProductCategory AS PC 
  ON P.ProductCategoryID = PC.ProductCategoryID
  WHERE H.OrderDate =(SELECT MAX(OrderDate) FROM SalesLT.SalesOrderHeader); 

  --QUESTION 4:Create a View called customersegment that stores the details (Customer ID, Name, Revenue) for customers and their segment.
  --- The view should be based on Question 2 (Customer segmentation).

  CREATE VIEW Customer_segment AS 
  SELECT 
   C.CustomerID AS "CUSTOMER ID",
    C.CompanyName AS "COMPANY NAME",
  SUM(O.OrderQty * O.UnitPrice) AS "TOTAL REVENUE",
    CASE
        WHEN SUM(O.OrderQty * O.UnitPrice) <= 5000 THEN 'Low Revenue'  
        WHEN SUM(O.OrderQty * O.UnitPrice) BETWEEN 5001 AND 10000 THEN 'Medium Revenue'  
        WHEN SUM(O.OrderQty * O.UnitPrice) BETWEEN 10001 AND 15000 THEN 'High Revenue'  
        WHEN SUM(O.OrderQty * O.UnitPrice) > 15000 THEN 'Top Revenue'  
    END AS "CUSTOMER SEGMENT"
FROM
SalesLT.SalesOrderHeader as H
JOIN SalesLT.SalesOrderDetail as O
    ON H.SalesOrderID = O.SalesOrderID
JOIN SalesLT.Customer as C
    ON H.CustomerID = C.CustomerID
	GROUP BY C.CustomerID, C.CompanyName
	ORDER BY 
	[CUSTOMER SEGMENT] DESC;

SELECT *
FROM Customer_segment;


---QUESTION 5:What are the top 3 selling products (include ProductName) in each category (include CategoryName)—by revenue?
--Use RANK() or ROW_NUMBER() functions to rank products within each category by revenue.

WITH RevenueData AS (
    SELECT 
        P.Name AS "PRODUCT NAME",
        PC.Name AS "PRODUCT CATEGORY",
        SUM(O.OrderQty * O.UnitPrice) AS REVENUE
    FROM SalesLT.Product AS P
    JOIN SalesLT.ProductCategory AS PC 
        ON P.ProductCategoryID = PC.ProductCategoryID
    JOIN SalesLT.SalesOrderDetail AS O
        ON O.ProductID = P.ProductID
    GROUP BY P.ProductID, PC.Name, P.Name
)
SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY "PRODUCT CATEGORY" ORDER BY REVENUE DESC) AS Ranknum
    FROM RevenueData
) RankedRevenue
WHERE Ranknum <= 3;


