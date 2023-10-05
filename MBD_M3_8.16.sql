-- membuat table 
create table employee
(fname varchar(15),
minit char,
ssn char(9),
bdate date,
address varchar(30),
sex char,
salary decimal(10,2),
superssn char(9),
dno int,
primary key(ssn));

-- menambahkan kolom dalam table yang kurang 
alter table employee 
add column lname varchar(15);

create table department(
dname varchar(15),
dnumber int,
mgrssn char(9),
mgrstartdate date,
primary key(dnumber));

create table dept_locations(
dnumber int,
dlocation varchar(15),
primary key(dnumber,dlocation));

create table project(
pname varchar(15),
pnumber int,
plocation varchar(15),
dnum int,
primary key(pnumber));

create table works_on(
essn char(9),
pno int,
hours decimal(3,1),
primary key(essn,pno));

create table dependent (
essn varchar(9),
dependentname varchar(15),
sex char,
bdate date,
relationship varchar(9),
primary key(essn,dependentname));

-- menambahkan relasi antar table 
alter table employee
add constraint fk_superssn foreign key(superssn) 
references employee(ssn);

alter table employee 
add constraint fk_dno foreign key(dno)
references department(dnumber);

alter table dept_locations 
add constraint fk_dnumber foreign key(dnumber) 
references department(dnumber);

alter table project 
add constraint fk_dnum foreign key (dnum)
references department(dnumber);

alter table works_on 
add constraint fk_essn foreign key(essn)
references employee(ssn);

alter table dependent 
add constraint fk_essn foreign key (essn)
references employee(ssn);

-- memasukkan data ke dalam table 
insert into employee(fname,minit,lname,ssn,bdate,address,sex,salary,superssn,dno)
values ('John','B','Smith','123456789','1965-01-09','731 Fondren, Houston, TX','M',30000,'333445555',5),
('Franklin','T','Wong','333445555','1955-12-08','638 Voss, Houston, TX','M',40000,'888665555',5),
('Alicia','J','Zelaya','999887777','1968-01-19','3321 Castle, Spring, TX','F',25000,'987654321',4),
('Jennifer','S','Wallace','987654321','1941-06-20','291 Berry, Bellaire, TX','F',43000,'888665555',4),
('Ramesh','K','Narayan','666884444','1962-09-15','975 Fire Oak, Humble, TX','M',38000,'333445555',5),
('Joyce','A','English','453453453','1972-07-31','5631 Rice, Houston, TX','F',25000,'333445555',5),
('Ahmad','V','Jabbar','987987987','1969-03-29','980 Dallas, Houston, TX','M',25000,'987654321',4),
('James','E','Borg','888665555','1937-11-10','450 Stone, Houston, TX','M',55000,NULL,1);


insert into department (dname,dnumber,mgrssn,mgrstartdate)
values 
('Research',5,'333445555','1988-05-22'),
('Administration',4,'987654321','1995-01-01'),
('Headquarters',1,'888665555','1981-06-19');

insert into dept_locations (dnumber,dlocation)
values (1,'Houston'),
(4,'Stafford'),
(5,'Bellaire'),
(5,'Sugarland'),
(5,'Houston');

insert into works_on (essn,pno,hours)
values ('123456789',1,32.5),
('123456789',2,7.5),
('666884444',3,40.0),
('453453453',1,20.0),
('453453453',2,20.0),
('333445555',2,10.0),
('333445555',3,10.0),
('333445555',10,10.0),
('333445555',20,10.0),
('999887777',30,30.0),
('999887777',10,10.0),
('987987987',10,35.0),
('987987987',30,5.0),
('987654321',30,20.0),
('987654321',20,15.0),
('888665555',20,NULL);

insert into project (pname,pnumber,plocation,dnum)
values('ProductX',1,'Bellaire',5),
('ProductY',2,'Sugarland',5),
('ProductZ',3,'Houston',5),
('Computerization',10,'Stafford',4),
('Reorganization',20,'Houston',1),
('Newbenefits',30,'Stafford',4);
 
insert into dependent (essn,dependentname,sex,bdate,relationship)
values('333445555','Alice','F','1986-04-05','Daughter'),
('333445555','Theodore','M','1983-10-25','Son'),
('333445555','Joy','F','1958-05-03','Spouse'),
('987654321','Abner','M','1942-02-28','Spouse'),
('123456789','Michael','M','1988-01-04','Son'),
('123456789','Alice','F','1988-12-30','Daughter'),
('123456789','Elizabeth','F','1967-05-05','Spouse');


-- 8.16 
-- a.Retrieve the names of all employees in department 5 who work more
-- than 10 hours per week on the ProductX project.
select concat (fname,' ',lname) as pegawai 
from employee e
join department d on d.dnumber = e.dno 
join project p on p.dnum = d.dnumber
join works_on wo on wo.pno = p.pnumber 
where d.dnumber = 5 and wo.hours > 10 and p.pname = 'ProductX';

-- b.List the names of all employees who have a dependent with 
-- the same first name as themselves.
select fname from employee e 
join dependent d on d.essn = e.ssn 
where d.dependentname = e.fname;

-- c.Find the names of all employees who are directly
-- supervised by ‘Franklin Wong’.
select concat (fname,' ',lname) as nama 
from employee e 
where e.superssn = (select ssn from employee where fname = 'Franklin' 
and lname = 'Wong');

-- d.For each project, list the project name and the total 
-- hours per week (by all employees) spent on that project
select p.pname, sum(wo.hours) as totalhourperweek
from project p 
join works_on wo on wo.pno = p.pnumber
group by p.pname;

-- e.Retrieve the names of all employees who work on every project.
-- jawaban masih blm pasti 
select concat (fname,' ',lname) as pegawai 
from employee e 
join works_on wo on wo.essn = e.ssn 
join project p on p.pnumber = wo.pno
where p.pnumber is not null
group by pegawai;

-- f.Retrieve the names of all employees who do not work on any project.
select concat (fname,' ',lname) as pegawai
from employee e 
left join works_on wo on wo.essn = e.ssn
where wo.pno is null;

-- g. For each department, retrieve the department name and the average 
-- salary of all employees working in that department.
select d.dname as "nama department", round(avg(e.salary),0) as "rata rata gaji"
from employee e 
join department d on d.dnumber = e.dno 
group by d.dname;

-- Retrieve the average salary of all female employees.
select round(avg(e.salary),0) as "average salary female employees"
from employee e 
where e.sex = 'F';



