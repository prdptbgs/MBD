-- 1.membuat procedure untuk memasukkan data project dalam table project 
	create or replace procedure tambahdataproject (p_name varchar(25),
	p_number varchar(25),
	p_location varchar(25),
	d_num varchar(25))
	language plpgsql
	as $$
	begin
	insert into project values (p_name,cast(p_number as integer),p_location,cast(d_num as integer));
	end;
	$$;

select * from project;

call tambahdataproject('ProductA','4','New York','4');

--  2.membuat procedure untuk menghapus data project dalam table project 
create or replace procedure hapusdataproject(namaproject text)
language plpgsql 
as $$
begin 
delete from project 
where pname = namaproject;
end;
$$;

select * from project;

call hapusdataproject('ProductA');

-- 3.membuat procedure untuk menambahkan gaji pegawai pada table employee 
create or replace procedure tambahgaji(idkaryawan text,tambah float)
language plpgsql
as $$
begin 
update employee 
set salary = salary + tambah
where ssn = idkaryawan;
end;
$$	

select concat(fname,' ',lname) as nama, salary ,ssn from employee;

call tambahgaji('888665555',5000)

-- 4.membuat procedure untuk mengecek gaji terendah dan tertinggi dari pegawai 
create or replace procedure cekgaji()
language plpgsql 
as $$
declare 
maks float;
minim float;
begin 
select max(salary) into maks from employee ;
raise notice 'gaji maksimal adalah : %',maks using hint = 'pengecekan berhasil';
select min(salary) into minim from employee ;
raise notice 'gaji minimal adalah : %',minim using hint = 'pengecekan berhasil';

end;
$$

call cekgaji();

-- 5.membuat trigger function dan trigger untuk mengecek data pegawai di table employee
-- penambahan kolom last_update 
alter table employee 
add column last_update varchar(50);

-- penambahan kolom last_user
alter table employee 
add column last_user varchar(50);

create or replace function tg_emp()
returns trigger 
language plpgsql
as $$
begin
if new.fname is null
then raise exception 'nama tidak boleh kosong';
end if;
if new.salary is null
then raise exception 'gaji tidak boleh kosong';
end if;
if new.salary < 0
then raise exception 'gaji tidak boleh negatif';
end if;

new.last_update = current_timestamp;
new.last_user = current_user;
return new;
end;
$$

create or replace trigger tg_emp
before insert or update
on employee 
for each row execute 
procedure tg_emp();

update employee 
set salary = 25000
where fname = 'Alicia';

select fname,salary from employee;

select fname,ssn,salary,last_update,last_user from employee;

-- 6.Pengembang ingin membuat catatan tentang aktivitas yang terjadi pada table 
-- project untuk memastikan bahwa tiap kali sebuah baris pada table project ditambahkan(insert),
-- dirubah(update atau dihapus(delete),disimpan catatannya pada table audit_project. 
-- Field yang disimpan selain field pada table project adalah waktu dan username, 
-- bersama dengan operasi yang dilakukan pada table project 

-- membuat table audit_project
create table audit_project(
kode int,
pnumber varchar,
pname varchar,
plocation varchar, 
dnumber varchar,
waktu timestamp, 
pengguna varchar, 
operasi varchar);


create or replace function audit_project()
returns trigger 
language plpgsql 
as $$
declare 
urut integer;
begin 
if (select max(kode)from audit_project) is null then 
urut = 0;
else 
select max(kode) into urut from audit_project;
end if;

if(TG_OP = 'INSERT') then 
insert into audit_project
select urut+1,new.*,current_date,current_user,'insert';
return new;
end if;

if(TG_OP = 'UPDATE') then 
insert into audit_project
select urut+1,old.*,current_date,current_user,'update';
return old;
end if;

if(TG_OP = 'DELETE' ) then 
insert into audit_project 
select urut+1,old.*,current_date,current_user,'delete';
end if;
return null;
end;
$$

create or replace trigger audit_project 
after delete or update or insert 
on project 
for each row execute
procedure audit_project();

insert into project (pname,pnumber,plocation,dnum)
values ('ProductA',4,'Surabaya',4);

insert into project(pname,pnumber,plocation,dnum)
values('ProductB',5,'Sidoarjo',1);

delete from project 
where plocation = 'Sidoarjo';

update project 
set pname = 'ProductAB'
where pname = 'ProductA';



select * from project;

select * from audit_project;


--  7.pengembang ingin membuat catatan tentang aktivitas perubahan data salary yang terjadi 
-- pada table employee, untuk merekam data sebelum dan sesudah diubah dibuat table penampungan
-- perubahan dengan nama salary_historis.perubahan salary yang terjadi pada table employee 
-- akan direkam pada table salary_historis 

-- langkah yang dilakukan adalah :
-- a.membuat table salary_historis 
-- b.membuat trigger function untuk eksekusi kedalam table employee
-- c.membuat trigger dengan event before update agar trigger function dapat dieksekusi untuk setiap baris pada table employee

create table salary_historis(
kode int,
ssn varchar,
salary_new float,
salary_old float,
last_update date,
last_user varchar);

create or replace trigger salary_historis 
before update 
on employee 
for each row execute 
procedure salary_historis();

create or replace function salary_historis()
returns trigger 
language plpgsql 
as $$
declare 
urut integer;
begin 
select max(kode) into urut from salary_historis;

if (select max(kode) from salary_historis) is null then 
urut = 0;
end if;

if(TG_OP = 'UPDATE') then 
insert into salary_historis 
select urut+1 , old.ssn , new.salary , old.salary , current_date , current_user ;
end if;

return new;
end;
$$ 

-- memanggil function tambahgaji dari soal no 2
call tambahgaji('999887777',5000);

select * from salary_historis;

-- 8.pengembang ingin membuat summary jam kerja yang sudah dihabiskan oleh pegawai dalam 
-- keterlibatannya dalam project. summary data ini disimpan dalam table summary_hours sehingga 
-- ketika ada penambahan data dalam table works_on, secara otomatis akan ditambah kedalam 
-- table summary_hours 

-- langkah yang dilakukan adalah :
-- a.membuat table summary_hours 
-- a.membuat trigger function untuk eksekusi ke dalam table works_on 
-- c.membuat trigger dengan event after insert agar trigger function dapat dieksekusi untuk setiap baris pada table works_on 

create table summary_hours(
ssn varchar,
total_hours float,
last_update time,
user_update varchar);

create or replace function summary_hours()
returns trigger 
language plpgsql 
as $$
declare 
total float;
begin 

if new.essn not in ( select ssn from summary_hours) then 
	select sum(hours) into total from works_on where essn = new.essn;
	insert into summary_hours
	select new.essn , total , current_timestamp , current_user;
	return new;
else 
	select sum(hours) into total from works_on where essn = new.essn;
	update summary_hours 
	set total_hours = total_hours + new.hours
	where ssn = new.essn; 
	return new;
	end if;
	
end;
$$
-- total jam per karyawan akan otomatis dijumlahkan jika essn karyawan tersebut ditambahkan data lama bekerja project baru 
create or replace trigger summary_hours 
after insert on works_on 
for each row execute 
procedure summary_hours();

insert into works_on (essn ,pno,hours)
values('123456789',3,5);

insert into works_on (essn ,pno,hours)
values('123456789',4,10);

select * from summary_hours;

-- 9.trigger untuk memeriksa total  jam kerja karyawan,jika total jam kerja diatas 40 jam,maka akan mengeluarkan peringatan ‘jam kerja melebihi 40 jam’

create or replace function periksajam()
returns trigger 
language plpgsql 
as $$
declare 
total integer;
begin 

if (select sum(hours) from works_on where old.essn = new.essn) > 40 then 
raise exception 'jam kerja melebihi 40 jam';
end if ;
end;
$$

create or replace trigger periksajam
before insert or update on works_on 
for each row execute 
procedure periksajam();

update works_on 
set hours = 0;
where essn = '123456789' and pno = '3'

--10. trigger untuk menghitung total gaji per department 

-- membuat table totalgajidept untuk merecord totalgaji dari salary tiap department
create table totalgajidep(
    dnumber int,
    total_salary float);
		
		drop table totalgajidep;
	
-- membuat trigger
create or replace function totalsalary_perdepartment()
returns trigger
language plpgsql 
as $$
declare 
totalgaji float;
begin 
	-- jika new.dno(dno pas insert), tidak ada dalam kolom dnumber pada table totalgajidep || if untuk table jika table masih kosong(inisialisasi  data table)
		 if new.dno not in(select dnumber from totalgajidep) then 
	-- membuat sintaks agar total salary disimpan di variabel totalgaji
		 select sum(salary) into totalgaji from employee where dno = new.dno;
	-- lalu memasukkan variabel totalgaji ke dalam table totalgajidep 
		 insert into totalgajidep 
		 select new.dno,totalgaji;
	-- table menyimpan niiai yang baru 
		 return new;
 else 
-- 	menyimpan total gaji dari sum(salary) variabel totalgaji || else untuk menyimpan data jika data di table totalgajidep sudah terisi
		select sum(salary) into totalgaji from employee where dno = new.dno;
-- 	menggunakan update agar jika total salary bertambah maka total salary tetap dalam 1 baris dan tidak bertambah baris
		update totalgajidep
		set total_salary = totalgaji
		where dnumber = new.dno;
-- 	menyimpan nilai yang sudah diperbarui 
		return new;
		end if;
		 
end;
$$


create trigger totalsalary_perdepartment
before insert or update on employee
for each row 
execute procedure totalsalary_perdepartment();

-- menggunakan constrain dno dan ssn agar data salary yang diupdate hanya ssn bersangkutan
update employee 
set salary = 25000
-- dno harus dinputkan di update agar bisa direcord masuk ke dalam table totalgajidep kolom dnumber
-- sementara ssn diinputkan agar salary yang diupdate hanya salary karyawan dengan ssn bersangkutan
-- jika hanya memakai constaint dno,maka yang diupdate banyak salary,karena beberapa karyawan memiliki dno yang sama
where dno = 1 and ssn = '987302198';

select * from totalgajidep;




