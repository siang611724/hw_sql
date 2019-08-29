-- 0. 庫名: iii
create database iii;
use iii;
-- 1. 客戶資料表：id(int primary,autoincrement),姓名,電話(uni),email,address
create table Customers(id int primary key auto_increment,custName varchar(20),custPhone varchar(20) unique,custEmail varchar(100),custAddress varchar(100));
-- 2. 供應商: id(...),名稱,電話(uni),地址
create table Suppliers(id int primary key auto_increment,suppName varchar(100),suppPhone varchar(20) unique,suppAddress varchar(100));
-- 3. 商品表: id(...),編號(uni),名稱,建議售價,供應商(f)
create table Products(id int primary key auto_increment,productNumber varchar(20) unique,productName varchar(100),recoPrice int,suppPhone varchar(100),foreign key (suppPhone) references Suppliers(suppPhone));
-- 4. 訂單: id(...),編號(uni),客戶(f)
create table Orders(id int primary key auto_increment,orderNumber varchar(20) unique,custPhone varchar(20),foreign key (custPhone) references Customers(custPhone));
-- 5. 訂單細項: id(...),編號(f),商品(f),實際單價,數量
create table orderDetails(id int primary key auto_increment,orderNumber varchar(20),foreign key (orderNumber) references Orders(orderNumber),productNumber varchar(100),foreign key (productNumber) references Products(productNumber),unitPrice int,Quantity int);

------------------------- 客戶 -----------------------------
-- 客戶新增 --
\d #
create procedure addCust(cname varchar(20),cphone varchar(20),cemail varchar(100),caddress varchar(100))
begin
insert into Customers(custName,custPhone,custEmail,custAddress) value (cname,cphone,cemail,caddress);
end #
\d ;
-- 客戶刪除 --
\d #
create procedure deleteCust(cid int)
begin
delete from Customers where id = cid;
end #
\d ;
-- 客戶修改 --
\d #
create procedure updateCust(cid int,cphone varchar(20),cemail varchar(100),caddress varchar(100))
begin
update Customers set custPhone=cphone,custEmail=cemail,custAddress=caddress where id = cid;
end #
\d ;
-- 查詢客戶 => 關鍵字 --
\d #
create procedure searchCust( in keyword varchar(100))
begin
    set @key = concat('%',keyword,'%') COLLATE utf8_unicode_ci;
    select * from Customers where custName like @key or custPhone like @key;
end #
\d ;

------------------------- 供應商 -----------------------------
-- 供應商新增 --
\d #
create procedure addSupp(sname varchar(100),sphone varchar(20),saddress varchar(100))
begin
insert into Suppliers(suppName,suppPhone,suppAddress) value (sname,sphone,saddress);
end #
\d ;
-- 供應商刪除--
\d #
create procedure deleteSupp(sid int)
begin
delete from Suppliers where id = sid;
end #
\d ;
-- 供應商修改 --
\d #
create procedure updateSupp(sid int,sphone varchar(20),saddress varchar(100))
begin
update Customers set suppPhone=sphone,suppAddress=saddress where id = sid;
end #
\d ;
-- 查詢供應商 => 關鍵字 --
\d #
create procedure searchSupp( in keyword varchar(100))
begin
    set @key = concat('%',keyword,'%') COLLATE utf8_unicode_ci;
    select * from Suppliers where supplierName like @key or supplierPhone like @key;
end #
\d ;

------------------------- 商品 -----------------------------
-- 商品新增 --
\d #
create procedure addProd(pNum varchar(20),pname varchar(100),rprice int,sphone varchar(100))
begin
insert into Products(productNumber,productName,recoPrice,suppPhone) value (pNum,pname,rprice,sphone);
end #
\d ;
-- 商品刪除 --
\d #
create procedure deleteProd(pid int)
begin
delete from Products where id = pid;
end #
\d ;
-- 商品修改 --
\d #
create procedure updateProd(pid int,pNum varchar(20),pname varchar(20),rprice int)
begin
update Products set productNumber=pNum,productName=pname,recoPrice=rprice where id = pid;
end #
\d ;
-- 查詢商品 => 關鍵字 --
\d #
create procedure searchProd( in keyword varchar(100))
begin
    set @key = concat('%',keyword,'%') COLLATE utf8_unicode_ci;
    select * from Products where productName like @key;
end #
\d ;

------------------------- 訂單 -----------------------------
-- 訂單新增 --
\d #
create procedure addOrder(oNum varchar(20),cphone varchar(20))
begin
insert into Orders(orderNumber,custPhone) value (oNum,cphone);
end #
\d ;
-- 訂單刪除 --
\d #
create procedure deleteOrder(oid int)
begin
delete from Orders where id = oid;
end #
\d ;

------------------------- 訂單明細 -----------------------------
-- 訂單明細新增 --
\d #
create procedure addOrderDetail(odNum varchar(20),pNum varchar(20),uprice int,quan int)
begin
insert into orderDetails(orderNumber,productNumber,unitPrice,Quantity) value (odNum,pNum,uprice,quan);
end #
\d ;
-- 訂單明細刪除 --
\d #
create procedure deleteOrderDetail(odid int)
begin
delete from orderDetails where id = odid;
end #
\d ;
-- 訂單明細修改(只能修改數量及實際單價) --
\d #
create procedure updateOrderDetail(odid int,uprice int,quan int)
begin
update orderDetails set unitPrice=uprice,Quantity=quan where id = odid;
end #
\d ;


----- 綜合查詢 -----

-- 指定客戶查詢訂單,含訂單明細 --
\d #
create procedure inquireOrders(cphone varchar(20))
begin
    select o.custPhone,od.orderNumber,od.productNumber,od.unitPrice,od.Quantity
    from orderDetails od
    join Orders o on (o.orderNumber = od.orderNumber)
    where o.custPhone = cphone;
end #
\d ;
-- 指定客戶查詢訂單總金額 --
\d #
create procedure inquireOrderTotal(cphone varchar(20))
begin
    select o.custPhone,od.orderNumber,sum(od.unitPrice*od.Quantity) total
    from orderDetails od
    join Orders o on (o.orderNumber = od.orderNumber)
    where o.custPhone = cphone;
end #
\d ;
-- 指定商品查詢訂單中的客戶, 例如: 商品P001的客戶有哪些,買幾個 --
\d #
create procedure inquireCustByProd(pNum varchar(20))
begin
    select od.orderNumber,od.productNumber,c.custName,od.Quantity
    from orderDetails od
    join Orders o on (o.orderNumber = od.orderNumber)
    join Customers c on (c.custPhone = o.custPhone)
    where od.productNumber = pNum;
end #
\d ;
-- 指定供應商查詢訂單中的商品清單 --
\d #
create procedure inquireProdBySupp(sid int)
begin
    select s.suppName,od.orderNumber,od.productNumber,p.productName
    from orderDetails od
    join Orders o on (o.orderNumber = od.orderNumber)
    join Products p on (p.productNumber = od.productNumber)
    join Suppliers s on (s.suppPhone = p.suppPhone)
    where s.id = sid;
end #
\d ;

call addCust('Kevin','0912345678','kevin@email.com','台中市大雅區');
call addCust('Bruce','0987654321','bruce@email.com','高譚市');
call addCust('Anne','0965842331','anne@email.com','台北市天母區');
call addCust('Elsa','0966322455','elsa@email.com','高雄市前鎮區');
call addCust('David','0974585323','david@email.com','台中市西屯區');

call addSupp('水果行','0988253622','台中市清水區');
call addSupp('遊戲機專賣店','0977243992','台中市北區');
call addSupp('電腦用品店','0967592147','台中市烏日區');

call addProd('F001','香蕉',50,'0988253622');
call addProd('F002','蘋果',80,'0988253622');
call addProd('F003','水果禮盒',500,'0988253622');
call addProd('G001','PS4pro',12980,'0977243992');
call addProd('G002','Switch',9780,'0977243992');
call addProd('H001','滑鼠',800,'0967592147');
call addProd('H002','顯示卡',9000,'0967592147');
call addProd('H003','記憶體',2500,'0967592147');

call addOrder('P001','0912345678');
call addOrder('P002','0987654321');
call addOrder('P003','0965842331');
call addOrder('P004','0966322455');


call addOrderDetail('P001','F001',50,10);
call addOrderDetail('P001','G001',12980,1);
call addOrderDetail('P001','H001',800,5);
call addOrderDetail('P002','G002',9780,2);
call addOrderDetail('P002','F003',500,10);
call addOrderDetail('P003','H002',9000,1);
call addOrderDetail('P004','F002',80,20);
call addOrderDetail('P004','H003',2500,2);