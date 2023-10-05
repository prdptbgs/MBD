drop database "8.18";

create database soal818;

create table book (
bookid varchar(15),
title varchar,
publishername varchar,
primary key(bookid));

create table book_authors(
bookid varchar(15),
authorname varchar,
primary key(bookid));

create table publisher (
name varchar,
address varchar,
phone varchar,
primary key (name));

create table book_copies(
bookid varchar(15),
branchid varchar,
noofcopies varchar,
primary key (bookid,branchid));

create table book_loans(
bookid varchar(15),
branchid varchar,
cardno varchar,
dateout date,
duedate date,
primary key(bookid,branchid,cardno));

create table library_branch(
branchid varchar,
branchname varchar,
address varchar,
primary key (branchid));

create table borrower (
cardno varchar,
name varchar,
address varchar,
phone varchar,
primary key(cardno));

alter table book
add constraint fk_publishername foreign key(publishername) 
references publisher(name);

alter table book_authors
add constraint fk_bookid foreign key (bookid) 
references book(bookid);

alter table book_copies 
add constraint fk_bookid foreign key (bookid)
references book(bookid);

alter table book_copies 
add constraint fk_branchid foreign key (branchid)
references library_branch (branchid);

alter table book_loans
add constraint fk_bookid foreign key (bookid)
references book(bookid);

alter table book_loans
add constraint fk_branchid foreign key(branchid)
references library_branch (branchid);

alter table book_loans 
add constraint fk_cardno foreign key (cardno)
references borrower (cardno);

-- a. How many copies of the book titled The Lost Tribe are 
-- owned by the library branch whose name is ‘Sharpstown’?
insert into library_branch (branchid,branchname,address)
values ('1','sharpstown','gedung a10 unesa');

insert into publisher(name,address,phone)
values('seggy','surabaya','7897');

insert into book (bookid,title,publishername)
values('1','the lost tribe','seggy');

insert into book_copies (bookid,branchid,noofcopies)
values ('1','1','50');

select bc.noofcopies as "banyak cetakan",b.title as "judul buku",lb.branchname as "nama cabang"
from book b 
join book_copies bc on bc.bookid = b.bookid 
join library_branch lb on lb.branchid = bc.branchid 
where b.title = 'the lost tribe' and lb.branchname = 'sharpstown';

-- b.How many copies of the book titled The Lost Tribe are 
-- owned by each library branch?
insert into library_branch(branchid,branchname,address)
values ('2','east','fc ketintang'),
('3','west','fish unesa');

insert into book_copies(bookid,branchid,noofcopies)
values('1','2','34'),
('1','3','29');

select b.title as "judul buku", lb.branchname as "cabang perpus", bc.noofcopies as "banyak cetakan"
from book b 
join book_copies bc on bc.bookid = b.bookid
join library_branch lb on lb.branchid = bc.branchid 
where b.title = 'the lost tribe';

-- c.Retrieve the names of all borrowers who do not have any 
-- books checked out.
insert into borrower (cardno,name,address,phone)
values('1','dipta','ketintang','8688'),
('2','ego','jetis','5453'),
('3','darren','nginden','5980'),
('4','wahhab','ketintang','3018'),
('5','reza','gresik','4391');

insert into book(bookid,title,publishername)
values (

insert into book_loans(bookid,branchid,cardno,dateout,duedate)
values(

-- d.For each book that is loaned out from the Sharpstown branch 
-- and whose Due_date is today, retrieve the book title, 
-- the borrower’s name, and the borrower’s address.

-- e.For each library branch, retrieve the branch name and 
-- the total number of books loaned out from that branch.

-- f.Retrieve the names, addresses, and number of books checked out 
-- for all borrowers who have more than five books checked out.

-- g.For each book authored (or coauthored) by Stephen King, retrieve the
-- title and the number of copies owned by the library branch 
-- whose name is Central.









