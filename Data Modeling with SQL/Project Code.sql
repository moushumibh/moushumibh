/*Create schema for Project*/
create schema `Project`;
use `Project`;

/*Create entity tables Product, Customer Transaction and Customer Order*/
CREATE TABLE product
(
Prod_ID VARCHAR(50) NOT NULL,
Prod_Desc char(100) NOT NULL ,
Prod_Price float(5,2) NOT NULL,
CONSTRAINT ProdID PRIMARY KEY (Prod_ID)
);

CREATE TABLE cust_tran
(
Tran_ID VARCHAR(50) NOT NULL,
Cust_Name VARCHAR(20) NOT NULL,
Payment_Meth CHAR(20) NOT NULL,
Payment_ID integer(10),
Amount numeric(8,2) NOT NULL,
CONSTRAINT TranID PRIMARY KEY (Tran_ID)
);

CREATE TABLE cust_order
(
Order_No VARCHAR(50) NOT NULL,
Order_Dt date NOT NULL,
Order_Tm time NOT NULL,
Tran_ID VARCHAR(50) NOT NULL,
CONSTRAINT FK1 foreign key (Tran_ID) references cust_tran(Tran_ID),
constraint PKOrderNo primary key (Order_No)
);

/*Create Order Lines table*/
CREATE TABLE order_lines
(
Order_No VARCHAR(50) NOT NULL,
Prod_ID VARCHAR(50) NOT NULL,
Prod_Qty int4 not null,
CONSTRAINT FK2 foreign key (Order_No) references cust_order(Order_No),
CONSTRAINT FK3 foreign key (Prod_ID) references product(Prod_ID),
constraint PKLines primary key (Order_No, Prod_ID)
);

/* Create denormalized table*/
create table denorm_order
(
Order_No VARCHAR(50) NOT NULL unique,
Order_Dt date NOT NULL,
Order_Tm time NOT NULL,
Cust_Name VARCHAR(20) NOT NULL,
Prod_ID VARCHAR(50) NOT NULL,
Prod_Desc char(100) NOT NULL ,
Prod_Qty VARCHAR(20) not null,
Prod_Price VARCHAR(20) NOT NULL,
Payment_Meth CHAR(20) NOT NULL,
Tran_ID VARCHAR(50) NOT NULL,
Constraint PKOrderNo primary key (Order_No)
);

/*Find the maximum priced product*/
select Prod_Desc, max(product.Prod_Price) from product;

/* Maximum amount a customer paid for an order*/
select Cust_Name, sum(Amount) as 'Total Amount' from cust_tran
group by Cust_Name order by Amount desc;

/*Customers who ordered Coffee*/
select Cust_Name, Prod_Desc
from denorm_order where Prod_Desc like '%Coffee%';

/*Customers who didn’t order coffee*/
select Cust_Name, Prod_Desc
from denorm_order where Prod_Desc not like '%Coffee%';

/*Total revenue collected from various modes of payment*/
select Payment_Meth, sum(Amount) as 'Total Collection' from cust_tran
group by Payment_Meth order by sum(Amount) desc;

/*Preferred mode of Transaction*/
select Payment_Meth as 'Mostly Used for Payment'
from denorm_order group by 1 order by count(*) desc;

/*Average Bill Value*/
select avg(Amount) as 'Average Bill Value' from cust_tran;

/*Customer who paid more than avg bill value*/
select * from cust_tran where amount > 12.457778;

/*Total units ordered in every order*/
select Order_No, sum(Prod_Qty) AS 'Total Units Ordered' from order_lines group by 1;

/*Total amount paid by customer for every order*/
select Order_No, Cust_Name, Amount
from cust_order o left join cust_tran t
on o.Tran_ID = t.Tran_ID;

/*Most ordered items in the store*/
select p.Prod_ID, p.Prod_Desc, count(o.Order_No) as 'No of Orders'
from cust_order o 
left join order_lines l on o.Order_No = l.Order_No
left join product p on l.Prod_ID = p.Prod_ID
group by p.Prod_Desc order by count(o.Order_No) desc;

/*Least ordered item in the store*/
select p.Prod_ID, p.Prod_Desc, count(o.Order_No) as 'No of Orders'
from cust_order o 
left join order_lines l on o.Order_No = l.Order_No
left join product p on l.Prod_ID = p.Prod_ID
group by p.Prod_Desc having count(o.Order_No) = 1;

/*Time when the most ordered item was ordered by customers*/
select Order_No, Order_Tm from cust_order
where exists( select * from order_lines where Order_No = cust_order.Order_No and Prod_ID = 2);

/*Time when the least ordered item was ordered by customers*/
select Order_No, Order_Tm from cust_order
where exists( select * from order_lines where Order_No = cust_order.Order_No and Prod_ID = 8);

/*Orders having bill balue higher than avg bill value and type of method used for payment*/
select o.Order_No, t.Amount, t.Payment_Meth 
from cust_order o inner join cust_tran t on
o.Tran_ID = t.Tran_ID and t.Amount > 12.457778 order by 2;

/*No of Orders and Total collection made during the busiest time frame*/
select count(o.Order_No) as 'No of Orders', sum(t.Amount) as 'Total Amount'
from cust_order o inner join cust_tran t on (t.Tran_ID = o.Tran_ID)
where o.Order_Tm between '15:00' and '19:00';

/*Products ordered by all customers*/
select o.Order_No, p.Prod_Desc, l.Prod_Qty 
from cust_order o
inner join order_lines l on (o.order_no = l.order_no)
inner join product p on (l.prod_id = p.prod_id) order by 1;

/*Total revenue made in the two months January and February*/
select monthname(o.Order_Dt) as 'Month', sum(t.amount) as 'Total Amount'
from cust_order o inner join cust_tran t on (t.Tran_ID = o.Tran_ID)
group by 1;

/*Total revenue made weekly*/
select monthname(o.Order_Dt) as 'Month', week(o.Order_Dt) as 'Week No', 
sum(t.amount) as 'Total Amount' from cust_order o 
inner join cust_tran t on (t.Tran_ID = o.Tran_ID) 
group by 2 order by 1 desc,2;

/* View*/

/*Top 5 ordered products*/
create view top_prod_ordered as
select p.Prod_ID, p.Prod_Desc, count(o.Order_No) as 'Ordered By' from cust_order o 
left join order_lines l on o.Order_No = l.Order_No
left join product p on l.Prod_ID = p.Prod_ID
group by p.Prod_Desc 
order by 1
limit 5;

SELECT * FROM top_prod_ordered;

/*Top 5 transactions made by customers and their payment mode*/
create view top_cust_transactions as
select o.order_no as 'Order Number', t.cust_name as 'Customer Name',
t.amount as 'Amount Paid', t.payment_meth as 'Paid Using' from cust_order o
left join cust_tran t on (t.tran_id = o.tran_id)
left join order_lines l on (o.Order_No = l.Order_No)
left join product p on (l.Prod_ID = p.Prod_ID)
group by 1
order by 3 desc
limit 5;

SELECT * FROM top_cust_transactions;

----#Advanced SQL Queries

---#Query using case clause
select case
		when Prod_Desc like '%Coffee%' then cust_name
        else 'Did not order Coffee'
end as Customer_Name 
from denorm_order;

---#Using Union

(select o.order_no, t.cust_name, t.amount, 'Highest Paid' as Quantity
from cust_order o, cust_tran t
where o.tran_id = t.tran_id
and t.amount > 17)
union
(select o.order_no, t.cust_name, t.amount, 'Lowest Paid' as Quantity
from cust_order o, cust_tran t
where o.tran_id = t.tran_id
and t.amount < 6)
order by 3 desc;

---#Using rank
select o.order_no, t.cust_name, t.amount, sum(l.prod_qty) as 'Total Qty Ordered',
rank() over(order by sum(l.prod_qty) desc) qty_rank 
from cust_order o, cust_tran t, order_lines l
where o.tran_id = t.tran_id
and o.order_no = l.order_no
group by l.order_no;

---#Creating trigger for insert in cust_tran
CREATE TABLE Customer (
cust_name varchar(20) not null,
payment_meth char(20));

create trigger CustomerInsertTrigger after insert on cust_tran
for each row insert into customer SELECT cust_name, payment_meth FROM cust_tran;

INSERT INTO cust_tran VALUES (340819821,'Sam', 'Visa Credit', '4152', 12.70);

select * from customer;

---#Stored Procedure

SET SQL_SAFE_UPDATES = 0;

DELIMITER //
CREATE PROCEDURE DeleteCust(IN cust_name varchar(20))
BEGIN
delete from customer c
WHERE c.cust_name = cust_name;
delete from cust_tran t
WHERE t.cust_name = cust_name;
END //

call DeleteCust('Sam');

select * from customer;


drop procedure amount_name;
delimiter $$
create procedure amount_name (alpha char(1))
begin
if (alpha = 'A') 
Then select t.payment_meth, t.amount, sum(l.prod_qty)
from cust_tran t, order_lines l, cust_order o
where t.cust_name like 'A%'
and t.tran_id = o.tran_id
and o.order_no = l.order_no
group by o.order_no order by 3 desc;
elseif  (alpha = 'M') 
Then select t.payment_meth, t.amount, sum(l.prod_qty)
from cust_tran t, order_lines l, cust_order o
where t.cust_name like 'M%'
and t.tran_id = o.tran_id
and o.order_no = l.order_no
group by o.order_no order by 3 desc;
end if;
end $$ 

call amount_name('A');

call amount_name('M');
