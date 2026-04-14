CREATE DATABASE global_fashion;
USE global_fashion;
CREATE TABLE sales(
Invoice_ID VARCHAR(50) ,
Line INT,
Customer_ID INT,
Product_ID INT,
Size VARCHAR(20),
Color VARCHAR(20),
Unit_Price DECIMAL(10,2),
Quantity INT,
Date DATETIME,
Discount DECIMAL(10,2),
Line_total DECIMAL(10,2),
Store_ID INT,
Employee_ID INT,
Currency VARCHAR(20),
Currency_Symbol VARCHAR(5),
SKU VARCHAR(50),
Transaction_Type VARCHAR(50),
Payment_Method VARCHAR(50),
Invoice_Total DECIMAL(10,2));


CREATE TABLE stores(
Store_ID INT PRIMARY KEY,
Country VARCHAR(80),
City VARCHAR(80),
Store_Name VARCHAR(80),
Number_of_Employees INT,
ZIP_Code VARCHAR(20),
Latitude DECIMAL(10,4),
Longitude DECIMAL(10,4));

CREATE TABLE customers (
Customer_ID INT,
Name VARCHAR(50),
Email VARCHAR(80),
Telephone VARCHAR(80),
City VARCHAR(40),
Country VARCHAR(40),
Gender VARCHAR(40),
Date_of_Birtg DATE,
Job_title VARCHAR(80));

CREATE TABLE products (
Product_ID int,
Category VARCHAR(30),
Sub_Category VARCHAR(50), 
Description_PT VARCHAR(150), 
Description_DE VARCHAR(150), 
Description_FR VARCHAR(150), 
Description_ES VARCHAR(150), 
Description_EN VARCHAR(150),
Description_ZH VARCHAR(150), 
Color VARCHAR(80), 
Sizes VARCHAR(80), 
Production_Cost decimal(10,2));

CREATE TABLE stores (
Store_ID INT, 
Country VARCHAR(30), 
City VARCHAR(30),
Store_Name VARCHAR(30), 
Number_of_Employees INT, 
ZIP_Code VARCHAR(30), 
Latitude DECIMAL(10,4), 
Longitude DECIMAL(10,4));

CREATE TABLE employees(
Employee_ID INT, 
Store_ID INT, 
Name varchar(40), 
Position varchar(40));

CREATE TABLE discounts (
Start_date DATE,
End_date DATE,
Discont DECIMAL(10,2), 
Description VARCHAR(150), 
Category VARCHAR(100), 
Sub_Category VARCHAR(100));

SET GLOBAL local_infile = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/transactions_1.csv'
INTO TABLE sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

CREATE TABLE exchange_rates_avg(
currency VARCHAR(20),
rate_to_usd DECIMAL(10,4));

INSERT INTO exchange_rates_avg VALUES
('USD', 1),
('GBP', 1.26),
('EUR', 1.08),
('CNY', 0.14);

CREATE TABLE sales_usd AS 
SELECT
s.*,
r.rate_to_usd
FROM sales s
JOIN exchange_rates_avg r 
ON s.currency = r.currency;

ALTER TABLE sales_usd
ADD COLUMN amount_usd DECIMAL(10,4);

UPDATE sales_usd
SET amount_usd = line_total * rate_to_usd;

-- verificacion
SELECT line_total,
		amount_usd,
		currency
        FROM sales_usd
        WHERE currency = 'CNY';
        
CREATE INDEX idx_date
ON sales_usd(date);

CREATE INDEX idx_invoice
ON sales_usd(invoice);

CREATE INDEX idx_product
ON sales_usd(product_id);

ALTER TABLE sales_usd
ADD PRIMARY KEY (invoice_id, product_id);

ALTER TABLE sales_usd
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE sales_usd
ADD CONSTRAINT fk_product
FOREIGN KEY (products_id)
REFERENCES products(product_id);

ALTER TABLE sales_usd
ADD CONSTRAINT fk_store
FOREIGN KEY (store_id)
REFERENCES stores(store_id);

ALTER TABLE sales_usd
ADD CONSTRAINT fk_employees
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id);

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

ALTER TABLE products
ADD PRIMARY KEY (product_id);

ALTER TABLE stores
ADD PRIMARY KEY (stores_id);

ALTER TABLE employees
ADD PRIMARY KEY (customer_id);
