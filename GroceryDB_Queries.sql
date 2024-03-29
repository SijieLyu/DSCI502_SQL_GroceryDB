/*
-----------------------------------------------------------------
|| 				FEATURE 1: Information About Orders		  		||
-----------------------------------------------------------------
*/

################################
## 		 	 QUERIES		  ##
################################

## Query 1 get customers order detail: orderCounts, Earliest Order Date;

select c.customer_id, Customer_Last, Customer_Phone, Birthday,
 count(Order_Number) as OrderCounts, min(Order_Date) as EarliestOrder
from Customers c, Orders o where c.Customer_id = o.customer_id group by c.customer_id;

## Query 2 which customer has more than one order

select c.customer_id, customer_First, customer_Last, customer_phone, t1.counts
from Customers c,
(select c.Customer_id, count(order_number) as counts
from Customers c, Orders o 
where order_number is not null and c.customer_id = o.customer_id group by c.customer_id) as t1
where c.customer_id = t1.customer_id and t1.counts > 1;


## Query 3. Sale Revenue per Order

select order_number, sum(order1.totalP) as RevenuePerOrder from 
(select order_number, o.product_id, Order_Quantity * Selling_Price as totalP from 
Order_details o, Product p where o.product_id = p.product_id order by order_number) as order1
group by order_number order by order_number;

## Query 4 get customer's birthday

select customer_id, customer_Last, customer_Email, Date_format(Birthday, '%W, %M %D, %Y') as Birth_Date
from Customers;

## Query 5 get customer's age, and select the customers younger than 30

select concat(customer_last,' ', customer_first ,' is ', year(now())-year(birthday), ' years old.')as customerAge 
from customers;

select c.customer_id, customer_last, customer_first, cus1.currentage from 
customers c,
(select customer_id, year(now())-year(birthday) as currentage from customers) as cus1
where c.customer_id = cus1.customer_id and cus1.currentage < 30;


## Query 6 get the customer's information for unshipped orders(shipping date is null)

select * from Orders;
insert into Orders values
(null, 4, '2020-11-20', null),
(null, 1, '2020-11-20', null),
(null, 3, '2020-11-22', null);

select Customer_id, Customer_first, customer_last from customers
where customer_id in (select customer_id from Orders where shipping_Date is null);


## Update : which product has the least orders, then do a promotion, descrease the price by 10%;

# select * from Product;

select count(Order_Number) as OrderCounts, Product_ID from order_details group by Product_ID;

select Product_Id 
from (select count(Order_Number) as OrderCounts, Product_ID from order_details group by Product_ID) as o1
where OrderCounts = 
(select min(counts) from (select count(Order_Number) as counts from order_details group by Product_Id) as o2);


# update Product set Selling_Price = selling_Price/0.9 where Product_ID in (1,4,5);
Update Product set Selling_Price = Selling_Price * 0.9 where Product_ID in
(
select Product_Id 
from (select count(Order_Number) as OrderCounts, Product_ID from order_details group by Product_ID) as o1
where OrderCounts = 
(select min(counts) from (select count(Order_Number) as counts from order_details group by Product_Id) as o2)
);

################################
## 		     VIEWS		      ##
################################
drop view if exists viewR1;
create view viewR1 as 
select order_number, sum(order1.totalRev) as RevenuePerOrder from 
(select order_number, o.product_id, Order_Quantity * Selling_Price as totalRev from 
Order_details o, Product p where o.product_id = p.product_id order by order_number) as order1
group by order_number order by order_number;

select * from viewR1;

drop view if exists viewR2;
create view viewR2 as 
select order_number, sum(order1.totalPro) as ProfitPerOrder from 
(select order_number, o.product_id, Order_Quantity * (Selling_Price - Unit_Price) as totalPro from 
Order_details o, Product p where o.product_id = p.product_id order by order_number) as order1
group by order_number order by order_number;

select * from viewR2;

##Get Total Sales Revenue for specific Month(For example: May 2020)

select sum(RevenuePerOrder) as TotalRevenue from viewR1 
where order_number in (select order_number from orders where month(order_date)=5 and year(order_date) = 2020);

##Get Total Profit for specific Month(For example: May 2020)

select sum(ProfitPerOrder) as TotalProfit from viewR2
where order_number in (select order_number from orders where month(order_date)=5 and year(order_date) = 2020);

################################
## 		  PROCEDURES		  ##
################################

### Procudure 1 - Update if Quantity_in_Stock < 30, Quantity + 50

drop procedure if exists Updates;
delimiter //
create procedure Updates(buymore int) 
Begin 
update Product set Stock_Quantity = Stock_Quantity + buymore 
where Stock_Quantity < 30;
end//
delimiter ;
select * from Product;
call Updates(50);

update Product set Stock_quantity = 28 where Product_ID = 5;

## Procedure 2 - update the shipping_Date to current date when one order has been shipped.

select * from orders;

drop procedure if exists UpdateShDate;
delimiter //
create procedure UpdateShDate(OrderNum int)
Begin 
Update orders set Shipping_Date = current_date where Order_Number = OrderNum;
end//
delimiter ;

call UpdateShDate(9);


################################
## 		   FUNCTIONS		  ##
################################
SET GLOBAL log_bin_trust_function_creators = 1;

### Function 1 ###
drop function if exists FTotalProducts;
delimiter //
create function FTotalProducts( ) returns int
Begin 
	Declare totalP int; set totalP = 0; 
	select count(Product_ID) into totalP from Product; 
	Return(totalP); 
end//
delimiter ;

select FTotalProducts() as TotalProducts;

### Function 2. get customer's points ###

drop function if exists FPoints;
delimiter //
create function FPoints(cusName varchar(20)) returns varchar(50)
Begin 
	Declare p int; 
	Declare Result varchar(50);
	set p=0; 
	if cusName in (select Customer_Last from Customers) then 
		select points into p from Customers where Customer_Last = cusName;  
		set result = Concat('Points of ', cusName, ' is ', p );  
	else set result = Concat(cusName, ' is not a customer');
	end if;
Return(result);
end//
delimiter ;

select FPoints('William') as customerPoints;

select FPoints('Lee') as customerPoints;


################################
##		 	TRIGGERS		  ##
################################
show triggers;

# keep all the insert actions such as at what time what new product was inserted into Product table. 

drop table if exists ProductUpdate;
create table ProductUpdate(
Product_ID int, Product_Name varchar(50), Stock_Quantity int,
Supplier_ID int, Unit_Price decimal(10,2), Selling_Price decimal(10,2),
InsertTime datetime
);
select * from ProductUpdate;

DROP TRIGGER IF EXISTS ProductAfterInsert;
delimiter //
create trigger ProductAfterInsert after insert on Product for each row 
Begin 
insert into ProductUpdate
values (new.Product_ID, new.Product_Name, new.Stock_Quantity, 
new.Supplier_ID, new.Unit_Price, new.Selling_Price, now());
end//
delimiter ;

select * from Suppliers;
insert into Suppliers
values(null,'Seventh Generation Inc.','Mosh','William','800-211-4279','VT','Burlington','60 Lake Street','05401');

#Insert new rows into Product Table:
select * from Product;
insert into Product values (null,'Disinfecting Wipes', 80,8,2.21,4.99),(null,'Liquid Hand Dish', 90,8,2.06,3.39);



/*
-----------------------------------------------------------------
|| 				FEATURE 2: Information about Suppliers	  		||
-----------------------------------------------------------------
*/

################################
## 		 	 QUERIES		  ##
################################

## Find out the product ID and supplier of "All Nature Beef Jerky".
select s.company_name, p.product_id, p.product_name
from suppliers s, product p
where s.supplier_id = p.supplier_id and p.product_name = 'All Nature Beef Jerky';

## Find out the supplier's company, contact representative's name, and phone number of "All Nature Beef Jerky"
select p.product_id,p.product_name, s.company_name, concat(s.supplier_first, ' ',s.supplier_last) as rep_name, s.supplier_phone
from suppliers s, product p
where s.supplier_id = p.supplier_id and p.product_name = 'All Nature Beef Jerky';

############################
## 		  PROCEDURE		  ##
############################

## Find out the supplier's company, contact representative's name, and phone number from a product ID
drop procedure if exists supplier_contact_info;
    
delimiter $$
create procedure supplier_contact_info(in Product_ID int)
begin
	select p.product_id, p.product_name, s.company_name, 
		   concat(s.supplier_first, ' ',s.supplier_last) as rep_name, 
           s.supplier_phone
	from suppliers s
    inner join product p
	on s.supplier_id = p.supplier_id 
    where p.product_id = Product_ID;
end $$
DELIMITER ;

	# Let's try to find Product ID 5's product and supplier information:
call GroceryDB.supplier_contact_info(5);


################################
## 		   FUNCTIONS		  ##
################################

## Write a function "supplier_no(product_id)" to find supplier's phone number given a product ID.

SET GLOBAL log_bin_trust_function_creators = 1; -- relaxes the checking for non-deterministic functions.
SET SESSION sql_mode = ''; -- remove the strict sql mode for this session.

drop function if exists supplier_no;

DELIMITER $$
create function supplier_no(pr_id int) returns varchar(100)
begin
declare output varchar(100);
declare ph varchar(100);
	if pr_id in (select product_id from product) then
		select s.supplier_phone into ph
        from suppliers s, product p
        where s.supplier_id = p.supplier_id and p.product_id = pr_id;
        set output = concat('Supplier phone of Product ID ',pr_id, ' is ', ph,'.');
	else set output = 'There is no product record.';
    end if;
	    
return(output); 
end $$
DELIMITER ;
select supplier_no(4); -- if the product ID exists;
select supplier_no(20); -- if the product ID doesn't exist;



################################
##		 	TRIGGERS		  ##
################################

SET FOREIGN_KEY_CHECKS=0; -- to disable foreign key constraint

## Trigger 1: to keep all the insert actions such as at what time what row was inserted into Suppliers table.

	# Step 1: build a table that audits actions like insert and delete suppliers 
drop table if exists SuppliersAudit;
create table SuppliersAudit(UserID varchar(80),
Supplier_First varchar(20), Supplier_Last varchar(20), Supplier_ID int, UpdateTime datetime, Action_Type varchar(10));
select * from SuppliersAudit;

	# Step 2: create an after insert trigger to keep track on the insert actions.
DROP TRIGGER IF EXISTS SuppliersAfterInsert;

delimiter //
create trigger SuppliersAfterInsert 
after insert on Suppliers 
for each row 
Begin 
insert into SuppliersAudit 
values (User(), new.Supplier_First, new.Supplier_Last, new.Supplier_ID, now(),'Insert');
end//
delimiter ;

		# Insert a new row into Suppliers:
-- delete from suppliers where supplier_id = 8; -- use this statement if supplier_id 8 already exists.
insert into Suppliers values ('8', 'Smuckers', 'John', 'Doe', '330-256-1234', 'OH', 'Akron', '789 S. 12th Ave', '44240');


		# Check if the trigger and audit table works.
select * from Suppliers;
select * from SuppliersAudit;

## Trigger 2: to keep all the delete actions such as at what time what row was deleted from the Suppliers table.
DROP TRIGGER IF EXISTS SuppliersAfterDelete;

delimiter //
create trigger SuppliersAfterDelete 
after delete on Suppliers 
for each row 
Begin 
insert into SuppliersAudit 
values (User(), old.Supplier_First, old.Supplier_Last, old.Supplier_ID, now(),'Delete');
end//
delimiter ;

		# Test to delete Supplier_ID 8
delete from suppliers where supplier_id = 8;
select * from suppliers;
select * from suppliersaudit;

SET FOREIGN_KEY_CHECKS=1; -- to re-enable the foreign key constraint



/*
-----------------------------------------------------------------
|| 				FEATURE 3: Customer Point System	  			||
-----------------------------------------------------------------
*/


################################
## 		 	 QUERIES		  ##
################################

# get information of all orders for a single customer

select O.Customer_id, OD.Product_ID, OD.Order_quantity, P.Selling_Price, (OD.Order_quantity * P.Selling_Price) as Order_Amount
from Orders O, Order_Details OD, Product P
where O.Order_Number = OD.Order_number and OD.Product_ID = P.Product_ID and O.Customer_id = 1
group by P.Product_id, OD.Order_Quantity;


################################
## 		  PROCEDURES		  ##
################################

# calculate the total amount of all orders of a single customer

drop procedure if exists calcAmount;
delimiter //
create procedure calcAmount(x int)

Begin
Declare Total decimal(20, 2);
	select SUM(q1.Item_Amount) as Total_Amount into Total from (
		select OD.Order_quantity * P.Selling_Price as Item_Amount
		from Orders O, Order_Details OD, Product P
		where O.Order_Number = OD.Order_number and OD.Product_ID = P.Product_ID and O.Customer_id = x
		group by P.Product_id, OD.Order_Quantity
	) as q1;

  Select Total as amountSpent;

end//
delimiter ;

call calcAmount(1);


################################
## 		   FUNCTIONS		  ##
################################

# calculate the points earned by a single customer

SET GLOBAL log_bin_trust_function_creators=1;

drop function if exists calcPoints;
delimiter //
create function calcPoints(x int) returns int
Begin
	Declare pt int;
    Declare total decimal(20, 2);

	select SUM(q1.Item_Amount) as Total_Amount into total from (
		select OD.Order_quantity * P.Selling_Price as Item_Amount
		from Orders O, Order_Details OD, Product P
		where O.Order_Number = OD.Order_number and OD.Product_ID = P.Product_ID and O.Customer_id = x
		group by P.Product_id, OD.Order_Quantity
	) as q1;

    set pt = total;

Return(pt);
end//
delimiter ;

select calcPoints(1) as pointsEarned;

################################
##		 	TRIGGERS		  ##
################################

# Clear the points of a customer before the next order

drop trigger if exists clearPointsBeforeOrder;
delimiter //

create trigger clearPointsBeforeOrder 
	before insert 
	on Orders for each row
Begin
	If exists(select customer_ID from customers where customer_ID = new.Customer_ID)
		then update customers set points = 0 where customers.customer_id = new.customer_id;
    end if;
    
end//

delimiter ;


# TEST

insert into Orders values (9,1,date('2020-5-30'),date('2020-06-02'));

select * from customers;


/*
-----------------------------------------------------------------
|| 			FEATURE 4: Special Offer for Customers	  			||
-----------------------------------------------------------------
*/

################################
##  Additional Tables for     ##
## Procedure Function Trigger ##
################################
drop table if exists discountmodifier;
Create table discountmodifier(discount_modifier decimal(10,2),reminder char(50)); 
insert into discountmodifier values(1,''), (1,''), (1,''), (1,''), (1,'');
select * from discountmodifier;

drop table if exists AmountPayment;
Create table AmountPayment
select distinct Customer_ID,month(Birthday) as Month_Birthday,discount_modifier, reminder from customers, discountmodifier;
select * from AmountPayment;


################################
## 		 	 QUERIES		  ##
################################
# Get total quantities of certain product id
select sum(Order_Quantity) as Total_Quantity, Product_ID from Order_details
group by Product_ID;

################################
## 		  PROCEDURES		  ##
################################
#apply discount of 5%off if discount occurs
drop procedure if exists birthdaydiscountapply;
delimiter //
create procedure birthdaydiscountapply() 
Begin 
update AmountPayment set discount_modifier= discount_modifier *0.95 where Month_Birthday = month(now()); 
end//
delimiter ;
call birthdaydiscountapply();
select * from AmountPayment;


################################
## 		   FUNCTIONS		  ##
################################
# reminder of who has discount
SET GLOBAL log_bin_trust_function_creators = 1;
drop function if exists birthdaydiscountreminder;
delimiter //
create function birthdaydiscountreminder() returns varchar(30)
Begin 
update AmountPayment set reminder = 'your discount is available' where month_birthday = month(now());
update AmountPayment set reminder = 'your discount is not available' where month_birthday > month(now()); 
update AmountPayment set reminder = 'your discount is not available' where month_birthday < month(now());
Return('updated');
end//
delimiter ;
select birthdaydiscountreminder();
select * from AmountPayment;

################################
##		 	TRIGGERS		  ##
################################
# Show which person has a discount
drop table if exists UpdateRecords;
create table UpdateRecords(
Customer_ID int, Month_BirthDay int, discount_modifier decimal(10,2), reminder char(50),UpdateTime datetime);

select * from UpdateRecords;
drop trigger if exists ShowUpdated;
delimiter //
create trigger ShowUpdated before update on AmountPayment for each row 
Begin 
insert into UpdateRecords
values (old.Customer_ID, old.Month_BirthDay, old.discount_modifier, old.reminder,now() );  
end//
delimiter ; 
select * from UpdateRecords;
