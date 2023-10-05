
-- 1.Membuat fungsi untuk menghitung total pegawai yang memiliki gaji dalam rentang tertentu 
CREATE OR REPLACE FUNCTION count_employees_in_salary_range(salary_from numeric, salary_to numeric)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    employee_count integer;
BEGIN
    SELECT COUNT(*) INTO employee_count
    FROM employee
    WHERE salary >= salary_from AND salary <= salary_to;
    
    RETURN employee_count;
END;
$$;

SELECT count_employees_in_salary_range(30000, 40000);

-- 2.Membuat fungsi untuk menghitung total jam pegawai dalam project tertentu 
CREATE OR REPLACE FUNCTION total_hours_in_project( project_name text)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
    total_hours numeric;
BEGIN
    SELECT SUM(wo.hours) INTO total_hours
    FROM works_on wo join project p on p.pnumber = wo.pno
    WHERE p.pname = project_name;
    
    RETURN total_hours;
END;
$$;

SELECT total_hours_in_project('ProductZ');

-- 3.Membuat fungsi untuk menghitung jumlah anggota keluarga dari pegawai tertentu 
create or replace function total_anggota_keluarga(idpegawai text)
returns numeric 
language plpgsql
as $$
declare 
 anggotakeluarga numeric;
 begin 
 select count(d.dependentname) into anggotakeluarga
 from dependent d join employee e on e.ssn = d.essn
 where e.ssn = idpegawai;
 
 return anggotakeluarga;
 end;
 $$;

select total_anggota_keluarga('333445555');

-- 4.Membuat fungsi untuk menghitung berapa jumlah proyek yang dihandle oleh department tertentu 
create or replace function jumlah_proyek_department(department_name text)
returns numeric 
language plpgsql
as $$
declare 
jumlahproject numeric;
begin 
select count(p.pname) into jumlahproject
from project p join department d on d.dnumber = p.dnum
where d.dname = department_name;

return jumlahproject;
end;
$$;

select jumlah_proyek_department('Administration');

-- 5.membuat fungsi untuk menghitung berapa jumlah pegawai yang berada pada rentang usia tertentu 

create or replace function jumlah_pegawai_usia(usia_awal int, usia_akhir int)
returns int 
language plpgsql
as $$
declare 
jumlah_usia INTEGER;
begin 
select count(e.ssn) into jumlah_usia
from employee e 
where extract(year from age(e.bdate)) >= usia_awal and extract(year from age(e.bdate)) <= usia_akhir;

return jumlah_usia;
end;
$$;

select jumlah_pegawai_usia(40,100);


-- 6.Membuat fungsi untuk menghitung berapa jumlah pegawai yang berada pada department tertentu 
create or replace function jumlah_pegawai_department(departmentname text)
returns numeric 
language plpgsql 
as $$
declare 
totalpegawai numeric; 
begin 
select count(e.fname) into totalpegawai 
from employee e join department d on e.dno = d.dnumber
where d.dname = departmentname;

return totalpegawai;
end;
$$;

select jumlah_pegawai_department('Research');

-- 7.Membuat fungsi untuk menghitung rata - rata gaji pegawai pada department tertentu 
create or replace function rata_rata_gaji_karyawan(department_name text)
returns numeric
language plpgsql 
as $$
declare 
rataratagaji numeric;
begin 
select avg(e.salary) into rataratagaji 
from employee e join department d on d.dnumber = e.dno
where d.dname = department_name ;

return rataratagaji;
end;
$$;

select rata_rata_gaji_karyawan('Administration');


-- 8.Membuat fungsi untuk menghitung jumlah proyek yang dihandle oleh manager tertentu 

create or replace function proyek_handle_manager(manager_name text)
returns numeric 
language plpgsql 
as $$
declare 
handle numeric;
begin 
select count(p.pname) into handle 
from project p 
join department d on d.dnumber = p.dnum 
join employee e on d.dnumber = e.dno
where e.fname = manager_name
and e.ssn = d.mgrssn;

return handle;
end;
$$

select proyek_handle_manager('Franklin');

employee ssn relasi ke project pnumber, project dnum relasi department dnumber,department ada mgr_ssn

-- 9.Membuat fungsi untuk memasukkan data pegawai baru 
create or replace function add_new_employee(
					inputfname varchar(15), 
					inputminit char,
					inputlname varchar(15),
					inputssn char(9),
					inputbdate date,
					inputaddress varchar(30),
					inputsex char,
					inputsalary decimal(10,2),
					inputsuper_ssn char(9),
					inputdno int)
returns void 
language plpgsql
as $$
begin 
insert into employee(fname,minit,lname,ssn,bdate,address,sex,salary,superssn,dno)
values (inputfname, inputminit, inputlname, inputssn, inputbdate, inputaddress, inputsex, inputsalary, inputsuper_ssn, inputdno);
end;
$$

select * from employee;

select add_new_employee('dipta','B','bagas','987302198','2004-01-15','Mojokerto','M',350000,'333445555',1);

-- 10.membuat fungsi untuk update data dependent dari pegawai tertentu 
-- mengubah lewat fname
create or replace function update_data_dependent(
		namapegawai text,
		ubahnamadependent text,
		namadependent varchar(15),
		jk char, 
		ultah date, 
		hub varchar(9))
returns void
language plpgsql 
as $$
begin 
update dependent 
set dependentname = namadependent , sex = jk, bdate = ultah, relationship = hub
from employee 
where employee.fname = namapegawai
and dependent.dependentname = ubahnamadependent
and dependent.essn = employee.ssn;
 
end;
$$

select update_data_dependent('Franklin','Alice','Darren','M','2003-04-01','Son');

select * from dependent;

-- mengubah lewat ssn
create or replace function perbarui_dependent(
		idpegawai text,
		ubahnama text,
		namadependent varchar(15),
		jk char,
		ultah date,
		hub varchar(15))
returns void
language plpgsql 
as $$ 
begin 
update dependent 
set dependentname = namadependent, sex = jk, bdate = ultah, relationship = hub 
where essn = idpegawai and dependentname = ubahnama;
end;
$$

select * from  dependent;

select perbarui_dependent('333445555','Joy','Egy','F','1958-05-03','Spouse');


-- 11.Membuat fungsi untuk delete lokasi department dengan kriteria tertentu 
create or replace function delete_location(nomor numeric,lokasi text)
returns void 
language plpgsql 
as $$
begin 

delete from dept_locations
where dnumber = nomor and dlocation = lokasi;

end;
$$

select * from dept_locations ;

select delete_location(1,'Houston');





-- 12.Membuat fungsi untuk menampilkan data pegawai yang telah terlibat project dalam jumlah tertentu 
create or replace function proyek_jml_tertentu(jumlah_proyek numeric)
returns table(namakaryawan text)
language plpgsql
as $$
declare namakaryawan text;
begin 
return query
select concat(e.fname,' ',e.lname) as namakaryawan 
from employee e
join works_on wo on wo.essn = e.ssn 
group by e.fname,e.lname
having count(wo.pno) >= jumlah_proyek;

end ;
$$


select * from proyek_jml_tertentu(2);

-- query sql 
SELECT concat(e.fname,' ',e.lname) as namakaryawan,
       count(wo.pno)::numeric as jumlahproject
FROM employee e
JOIN works_on wo ON wo.essn = e.ssn 
GROUP BY e.fname, e.lname
HAVING count(wo.pno) >= 1;


-- 13.Membuat fungsi untuk menghitung rata - rata jam kerja terlibat di proyek dari pegawai tertentu 
-- search pakai fname 
create or replace function average_jam(input_fname text)
returns numeric
language plpgsql 
as $$
declare 
rata_rata_jam numeric;
begin 
select avg(wo.hours) into rata_rata_jam 
from works_on wo join employee e on e.ssn = wo.essn 
join project p on p.pnumber = wo.pno
where e.fname = input_fname;

return rata_rata_jam ;
end;
$$

select average_jam('Franklin');

-- search pakai ssn
create or replace function average_time(karyawan_id text)
returns numeric
language plpgsql 
as $$
declare 
rata_rata_jam numeric;
begin 
select avg(hours) into rata_rata_jam 
from works_on 
where essn = karyawan_id;

return rata_rata_jam ;
end;
$$

select average_time('123456789');

-- 14.Membuat fungsi untuk mengupdate salary dari pegawai jika male maka salary naik 20% sedangkan jika female maka salary naik 15%

create or replace function update_gaji(namakaryawan text)
returns void 
language plpgsql 
as $$
declare 
gender text;
kenaikan_gaji float;
begin 
select sex into gender 
from employee;

if gender = 'M' then 
kenaikan_gaji = 0.20;
elseif gender = 'F' then
kenaikan_gaji = 0.15;
end if;

update employee 
set salary =salary + (salary* kenaikan_gaji) 
where fname = namakaryawan;

end;
$$

select concat (fname,' ',lname) as karyawan, salary from employee;

select update_gaji ('John');


-- 15.Membuat fungsi untuk update data salary manager,jika lama menjadi manager sudah lebih dari 10 tahun maka salary naik 30%, jika kurang  dari 10 tahun hanya naik 10%

create or replace function update_gaji_manager(namamanager text)
returns void 
language plpgsql 
as $$
declare 
kenaikan_gaji float;
lama_bekerja float;
begin 
select date_part('year',age(now(), mgrstartdate)) into lama_bekerja 
from department;

if lama_bekerja > 10 then 
kenaikan_gaji = 0.30; 
elseif lama_bekerja <= 10 then 
kenaikan_gaji = 0.10;
end if;

update employee 
set salary = salary + ( salary * kenaikan_gaji)
from department
where department.dnumber = employee.dno
and fname = namamanager;

end;
$$

select concat(fname ,' ',lname) as karyawan ,salary 
from employee e 
join department d on e.dno = d.dnumber
where d.mgrssn = ssn;

select update_gaji_manager('Franklin');

update employee 
set salary = 40000
where fname = 'Franklin';


