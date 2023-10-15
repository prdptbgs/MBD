-- 01.Trigger Function untuk Menghitung Total Harga Penjualan 
-- pada Transaksi Penjualan

-- membuat tipe data baru rupiah
create domain rupiah as numeric(18,2) default 0 check (value >= 0);

-- menambahkan kolom baru pada table transaksi_penjualan dengan tipe data rupiah yang sudah dibuat tadi
ALTER TABLE transaksi_penjualan
ADD COLUMN total_harga rupiah;

CREATE OR REPLACE FUNCTION calculate_total_price()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE transaksi_penjualan
  SET total_harga = (SELECT SUM(jumlah_obat_dijual * harga_jual) 
                    FROM rincian_penjualan rp JOIN obat ob ON ob.kode_obat = rp.kode_obat
                    WHERE no_nota = NEW.no_nota)
  WHERE no_nota = NEW.no_nota;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_total_price_trigger
AFTER INSERT OR UPDATE ON rincian_penjualan
FOR EACH ROW
EXECUTE FUNCTION calculate_total_price();

-- coba trigger 
UPDATE rincian_penjualan 
SET jumlah_obat_dijual = 1
WHERE no_nota = '000121' AND kode_obat = '00101';

-- reset kolom total_harga no_nota '000121'
update transaksi_penjualan
set total_harga = null
where no_nota = '00121';

-- menampilkan 
select * from transaksi_penjualan where no_nota = '000121';




















-- 02.Trigger Function untuk Menghitung Total Harga Pembelian 
-- pada Transaksi Pembelian

-- menambahkan kolom baru total_harga pada table transaksi_pembelian
alter table transaksi_pembelian 
add column total_harga numeric(18,2);

CREATE OR REPLACE FUNCTION calculate_total_purchase_price()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE transaksi_pembelian
  SET total_harga = (SELECT SUM(jumlah_obat_dibeli * harga_beli) 
                    FROM rincian_pembelian 
                    WHERE no_faktur = NEW.no_faktur)
  WHERE no_faktur = NEW.no_faktur;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_total_purchase_price_trigger
AFTER INSERT OR UPDATE ON rincian_pembelian
FOR EACH ROW
EXECUTE FUNCTION calculate_total_purchase_price();

-- demo
-- reset value
update transaksi_pembelian 
set total_harga = null 
where no_faktur = 081203;

-- insert value
insert into rincian_pembelian(no_faktur, kode_obat, jumlah_obat_dibeli, harga_beli)
values('081203','00102',50,30000);

-- retrieve data 
select * from transaksi_pembelian ;




















-- 03.trigger function untuk menghitung sisa stok obat 
-- dalam table obat jika ada perubahan pembelian atau pembelian baru
CREATE OR REPLACE FUNCTION update_stock_after_purchase()
RETURNS TRIGGER AS $$
DECLARE  
    sisa_obat_lama int;
    obat_baru_beli int;
BEGIN
    -- Menghitung total jumlah obat yang telah dibeli untuk kode_obat tertentu
    SELECT jumlah_obat_dibeli INTO obat_baru_beli
    FROM rincian_pembelian
    WHERE kode_obat = NEW.kode_obat AND no_faktur = NEW.no_faktur;
  
    -- Mengambil nilai sisa_obat dari tabel obat
    SELECT sisa_obat INTO sisa_obat_lama
    FROM obat WHERE kode_obat = NEW.kode_obat;
  
    -- Jika tidak ada catatan yang cocok, maka sisa_obat_lama akan menjadi NULL
    -- Jika sisa_obat_lama adalah NULL, maka inisialisasi dengan 0
    IF sisa_obat_lama IS NULL THEN
        sisa_obat_lama := 0;
    END IF;

    -- Memperbarui stok obat di tabel obat
    UPDATE obat
    SET sisa_obat = sisa_obat_lama + obat_baru_beli
    WHERE kode_obat = NEW.kode_obat;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER update_stock_after_purchase_trigger
AFTER INSERT OR UPDATE ON rincian_pembelian
FOR EACH ROW
EXECUTE FUNCTION update_stock_after_purchase();

-- demo 
-- reset column sisa_obat
update obat 
set sisa_obat = null
where sisa_obat < 500 and sisa_obat > 50;

-- set value sisa_obat 
update rincian_pembelian 
set jumlah_obat_dibeli = 100
where no_faktur = '005102' and kode_obat = '00102';

update rincian_pembelian 
set jumlah_obat_dibeli = 100
where no_faktur = '009201' and kode_obat = '00201';

update rincian_pembelian 
set jumlah_obat_dibeli = 200
where no_faktur = '009201' and kode_obat = '00202';

update rincian_pembelian 
set jumlah_obat_dibeli = 200
where no_faktur = '080202' and kode_obat = '00302';

update rincian_pembelian 
set jumlah_obat_dibeli = 200
where no_faktur = '081202' and kode_obat = '00303';

update rincian_pembelian 
set jumlah_obat_dibeli = 100
where no_faktur = '001101' and kode_obat = '00101';

update rincian_pembelian 
set jumlah_obat_dibeli = 100
where no_faktur = '081203' and kode_obat = '00102';


-- 00101 = 100
-- 00102 = 150
-- 00201 = 100
-- 00202 = 200
-- 00302 = 200
-- 00303 = 200

-- retrieve data
select kode_obat,sisa_obat from obat;























-- 04.trigger function untuk menghitung sisa stok obat 
-- dalam table obat jika ada perubahan penjualan atau penjualan baru

-- membuat kolom baru sisa_obat pada table obat 
alter table obat 
add column sisa_obat int;

CREATE OR REPLACE FUNCTION update_stock_after_sale()
RETURNS TRIGGER AS $$
DECLARE 
sisa_ob int;
obat_terjual int;
BEGIN
	sisa_ob = 0;

-- memasukkan data obat yang dibeli ke variable sisa_ob 
	SELECT jumlah_obat_dijual INTO obat_terjual
	FROM rincian_penjualan
	WHERE kode_obat = NEW.kode_obat AND no_nota = NEW.no_nota;
	
	SELECT sisa_obat INTO sisa_ob FROM obat 
	where kode_obat = new.kode_obat;

  -- Mengurangkan jumlah obat dijual dari stok obat yang ada
  UPDATE obat
  SET sisa_obat = sisa_ob - obat_terjual
  WHERE kode_obat = NEW.kode_obat;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER stock_update_trigger_penjualan
AFTER INSERT or update ON rincian_penjualan
FOR EACH ROW
EXECUTE FUNCTION update_stock_after_sale();

-- demo
-- reset value sisa_obat
update obat 
set sisa_obat = 100
where kode_obat = '00201';

-- update rincian_penjualan for kode_obat = '00201'
update rincian_penjualan 
set jumlah_obat_dijual = 3
where no_nota = '000122' and kode_obat = '00201';

update rincian_penjualan 
set jumlah_obat_dijual = 3
where no_nota = '000133' and kode_obat = '00201';

update rincian_penjualan 
set jumlah_obat_dijual = 3
where no_nota = '000135' and kode_obat = '00201';

update rincian_penjualan 
set jumlah_obat_dijual = 4
where no_nota = '000136' and kode_obat = '00201';

update rincian_penjualan 
set jumlah_obat_dijual = 3
where no_nota = '000137' and kode_obat = '00201';

update rincian_penjualan 
set jumlah_obat_dijual = 3
where no_nota = '000139' and kode_obat = '00201';

-- retrieve data
select kode_obat,sisa_obat from obat;

























-- 05.Trigger Function untuk Memeriksa Ketersediaan Stok Obat 
-- pada Penjualan
CREATE OR REPLACE FUNCTION check_stock_availability()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.jumlah_obat_dijual > (SELECT sisa_obat FROM obat WHERE kode_obat = NEW.kode_obat) THEN
    RAISE EXCEPTION 'Stok obat tidak mencukupi';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER check_stock_trigger
BEFORE INSERT ON rincian_penjualan
FOR EACH ROW
EXECUTE FUNCTION check_stock_availability();


-- demo
-- masukkan no_nota dulu ke table transaksi_penjualan  baru bisa insert penjualan baru ke table rincian penjualan 
insert into transaksi_penjualan(no_nota,tanggal_penjualan,id_konsumen,id_karyawan)
values('000143','2023-10-15',2,18202);

insert into rincian_penjualan(no_nota,kode_obat, jumlah_obat_dijual)
values('000143','00102',250);

-- delete data that has been entered
delete from rincian_penjualan
where no_nota = '000143';

delete from transaksi_penjualan
where no_nota = '000143';

--  display exception 
select * from transaksi_penjualan;
