drop database if exists GroceryDB;
create database GroceryDB;
use grocerydb;

################################
## 		  CREATE TABLES		  ##
################################

#### Create Table: Customer ####
drop table if exists Customers;
create table Customers (
	Customer_ID int not null auto_increment,
    Customer_First varchar(50),
    Customer_Last varchar(50),
    Customer_Phone varchar(12),
    Customer_Email varchar(50),
    Birthday date,
    Customer_State varchar(2),
    Customer_City varchar(50),
    Customer_Address varchar(50),
    Zip_Code int,
    Points int,
    primary key (Customer_ID));
    
    ## Load data to Customers table
insert into Customers
values (1,'Juli',	'Swansen','371-876-7592','jbrazil0@gmail.com',date('1993-1-21'),'NY','Rochester','1 Transport Hill','14620','2966'),
(2,'Layla','Wilkes','595-549-2591','lsymondson1@yahoo.com',date('1984-8-22'),'CA','San Francisco','2 Mockingbird Parkway','94128','458'),
(3,'Mable','Lee','485-547-4933','mbanger2@aol.com',date('1998-5-25'),'AZ','Mesa','155 Village Drive','85210','339'),
(4,'Tammy','Hellyer','298-257-8091','thellyer3@webnode.com',date('1982-10-10'),'OH','Austinburg','8 Golf View Point','44010','1672'),
(5,'Dominik','Gorbell','376-366-9363','dgorbell4@chron.com',date('1975-2-21'),'PA','Pittsburgh','992 Annamark Park','15212','796');


#### Create Table: Orders ####
drop table if exists Orders;
create table Orders(
	Order_Number int not null auto_increment,
    primary key(Order_Number),
    Customer_ID int not null,
    foreign key(Customer_ID)references Customers(Customer_ID),
    Order_Date date,
    Shipping_Date date);
    
    ## Load Orders data to Orders table
insert into Orders
values (1,1,date('2020-5-30'),date('2020-06-02')),
(2,1,date('2019-08-02'),date('2019-08-02')),
(3,3,date('2020-01-30'),date('2020-02-01')),
(4,5,date('2019-11-09'),date('2019-11-09')),
(5,2,date('2020-05-29'),date('2020-06-02')),
(6,2,date('2020-06-06'),date('2020-06-08')),
(7,4,date('2019-12-25'),date('2019-12-28')),
(8,5,date('2020-06-06'),date('2020-06-07'));


#### Create Table: Suppliers ####
drop table if exists Suppliers;
create table Suppliers(
Supplier_ID int not null auto_increment, primary key(Supplier_ID),
Company_Name varchar(200),
Supplier_First varchar(50),
Supplier_Last varchar(50),
Supplier_Phone varchar(12),
Supplier_State varchar(2),
Supplier_City varchar(50),
Supplier_Address varchar(200),
Supplier_Zip varchar(5));
	## Load the data
insert into Suppliers
values(1,'Sedi International Packaging Group','Jere','Badman','919-728-4399','NC','Durham','895 Rowland Center','27517'),
(2,'Bolthouse Farms, Inc.','Casey','MacCauley','316-613-4745','KS','Wichita','25 Westridge Junction','67052'),
(3,'Insight Beverages','Tom','Fibbens','757-863-9559','VA','Norfolk','9 Victoria Terrace','23324'),
(4,'Tillamook Country Smoker','Skylar','Dictus','405-480-4029','OK','Oklahoma City','45 Westend Crossing','73008'),
(5,'Kellogg Co.','Gunther','Kyllford','559-134-7656','CA','Fresno','4685 Havey Pass','93650'),
(6,'Nestle USA','Marlie','Joynes','502-218-6241','KY','Frankfort','245 Helena Lane','40601'),
(7,'E.A. Sween Company','Franni','Hansberry','434-959-3522','VA','Manassas','54 Marquette Trail','20110');



#### Create Table: Product ####
drop table if exists Product;
create table Product(
Product_ID int not null auto_increment, primary key(Product_ID),
Product_Name varchar(50),
Stock_Quantity int,
Supplier_ID int not null, foreign key(Supplier_ID)references Suppliers(Supplier_ID),
Unit_Price decimal(10,2),
Selling_Price decimal(10,2));

insert into Product 
values(1,'Foam Dinner Plate',70,1,1.21,2.99),
(2,'Protein Drinks',30,6,0.86,2.99),
(3,'Premium Lemonade',40,3,0.75,1.59),
(4,'All Nature Beef Jerky',50,4,3.25,5.99),
(5,'Kelloggs Pringles with Dip',28,5,3.75,6.49),
(6,'Butterfinger Peanut Butter Cups',40,7,1.56,2.45),
(7,'Strawbrry Pop Tarts',50,5,0.58,1.99);



#### Create Table: Order Details ####
drop table if exists Order_Details;
create table Order_Details(
	Order_Number int not null,foreign key(Order_Number)references Orders(Order_Number),
    Product_ID int not null, foreign key(Product_ID)references Product(Product_ID),
    Order_Quantity int not null);

	## Load Order_Details data
insert into Order_Details
values(1,3,2),(1,4,5),(2,1,20),(2,2,5),(2,6,10),(3,2,12),(3,7,5),(4,3,20),(5,5,6),(5,6,8),(5,7,2),(6,2,3);
