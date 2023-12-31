PGDMP         +            	    {            APOTEK BESARI    15.4    15.4 F    h           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            i           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            j           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            k           1262    25230    APOTEK BESARI    DATABASE     �   CREATE DATABASE "APOTEK BESARI" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE "APOTEK BESARI";
                postgres    false            �            1255    25892 '   estimatemonthlyprofit(integer, integer) 	   PROCEDURE       CREATE PROCEDURE public.estimatemonthlyprofit(IN year integer, IN month integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    monthly_profit NUMERIC;
BEGIN
    SELECT SUM(obat."harga_jual" - rincian_pembelian."harga_beli")
    INTO monthly_profit
    FROM transaksi_penjualan tp, obat, rincian_pembelian
    WHERE EXTRACT(YEAR FROM tp."tanggal_penjualan") = year
    AND EXTRACT(MONTH FROM tp."tanggal_penjualan") = month;

    RAISE NOTICE 'Perkiraan Keuntungan Bulan % Tahun %: %', month, year, monthly_profit;
END;
$$;
 P   DROP PROCEDURE public.estimatemonthlyprofit(IN year integer, IN month integer);
       public          postgres    false            �            1255    25891    generateinvoicenumber()    FUNCTION       CREATE FUNCTION public.generateinvoicenumber() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    InvoiceNumber VARCHAR(20);
BEGIN
    InvoiceNumber = 'INV' || 
        EXTRACT(YEAR FROM current_date) ||
        LPAD(EXTRACT(MONTH FROM current_date)::TEXT, 2, '0') ||
        LPAD(EXTRACT(DAY FROM current_date)::TEXT, 2, '0') || '-' ||
        LPAD(CAST(COALESCE((SELECT MAX(CAST(SUBSTRING(InvoiceNumber, 12, 5) AS INT) + 1) FROM transaksi_penjualan), 1) AS VARCHAR), 5, '0');
    
    RETURN InvoiceNumber;
END;
$$;
 .   DROP FUNCTION public.generateinvoicenumber();
       public          postgres    false            �            1259    25231    berisi    TABLE     �   CREATE TABLE public.berisi (
    no_resep character varying(50) NOT NULL,
    kode_obat character varying(50) NOT NULL,
    dosis integer DEFAULT 0
);
    DROP TABLE public.berisi;
       public         heap    postgres    false            �            1259    25245    dokter    TABLE     �   CREATE TABLE public.dokter (
    id_dokter character varying(50) NOT NULL,
    nama_dokter character varying(100),
    no_hp_dokter character varying(50)
);
    DROP TABLE public.dokter;
       public         heap    postgres    false            �            1259    25256    karyawan    TABLE     �  CREATE TABLE public.karyawan (
    id_karyawan character varying(50) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    tanggal_lahir timestamp without time zone,
    jenis_kelamin character varying(50),
    bagian character varying(255),
    jalan character varying(100),
    rt_rw character varying(255),
    kelurahan character varying(100),
    kecamatan character varying(100),
    kota_kabupaten character varying(100),
    provinsi character varying(100)
);
    DROP TABLE public.karyawan;
       public         heap    postgres    false            �            1259    25931    konsumen_id_konsumen_seq    SEQUENCE     �   CREATE SEQUENCE public.konsumen_id_konsumen_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.konsumen_id_konsumen_seq;
       public          postgres    false            �            1259    25273    konsumen    TABLE     S  CREATE TABLE public.konsumen (
    id_konsumen bigint DEFAULT nextval('public.konsumen_id_konsumen_seq'::regclass) NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    tanggal_lahir timestamp with time zone,
    jenis_kelamin character varying(255),
    no_hp_konsumen character varying(15) NOT NULL
);
    DROP TABLE public.konsumen;
       public         heap    postgres    false    226            �            1259    25290    no_hp_karyawan    TABLE     �   CREATE TABLE public.no_hp_karyawan (
    id_karyawan character varying(50) NOT NULL,
    no_hp character varying(15) NOT NULL
);
 "   DROP TABLE public.no_hp_karyawan;
       public         heap    postgres    false            �            1259    25302    obat    TABLE     �   CREATE TABLE public.obat (
    kode_obat character varying(50) NOT NULL,
    nama_obat character varying(100),
    jenis_obat character varying(100),
    harga_jual double precision DEFAULT 0,
    expired_date timestamp without time zone
);
    DROP TABLE public.obat;
       public         heap    postgres    false            �            1259    25314    resep    TABLE     �   CREATE TABLE public.resep (
    no_resep character varying(50) NOT NULL,
    tanggal_resep timestamp without time zone,
    no_nota character varying(50),
    id_dokter character varying(50)
);
    DROP TABLE public.resep;
       public         heap    postgres    false            �            1259    25328    rincian_pembelian    TABLE     �   CREATE TABLE public.rincian_pembelian (
    no_faktur character varying(255) NOT NULL,
    kode_obat character varying(50) NOT NULL,
    jumlah_obat_dibeli integer DEFAULT 0,
    harga_beli integer DEFAULT 0
);
 %   DROP TABLE public.rincian_pembelian;
       public         heap    postgres    false            �            1259    25343    rincian_penjualan    TABLE     �   CREATE TABLE public.rincian_penjualan (
    no_nota character varying(50) NOT NULL,
    kode_obat character varying(50) NOT NULL,
    jumlah_obat_dijual integer DEFAULT 0
);
 %   DROP TABLE public.rincian_penjualan;
       public         heap    postgres    false            �            1259    25357    supplier    TABLE     �   CREATE TABLE public.supplier (
    id_supplier character varying(50) NOT NULL,
    nama_supplier character varying(50),
    no_telepon character varying(50),
    alamat character varying(255)
);
    DROP TABLE public.supplier;
       public         heap    postgres    false            �            1259    25369    transaksi_pembelian    TABLE     �   CREATE TABLE public.transaksi_pembelian (
    no_faktur character varying(255) NOT NULL,
    tanggal_pembelian timestamp with time zone,
    id_supplier character varying(50)
);
 '   DROP TABLE public.transaksi_pembelian;
       public         heap    postgres    false            �            1259    25380    transaksi_penjualan    TABLE     �   CREATE TABLE public.transaksi_penjualan (
    no_nota character varying(50) NOT NULL,
    tanggal_penjualan timestamp with time zone,
    id_konsumen bigint,
    id_karyawan character varying(50)
);
 '   DROP TABLE public.transaksi_penjualan;
       public         heap    postgres    false            Y          0    25231    berisi 
   TABLE DATA           <   COPY public.berisi (no_resep, kode_obat, dosis) FROM stdin;
    public          postgres    false    214   #[       Z          0    25245    dokter 
   TABLE DATA           F   COPY public.dokter (id_dokter, nama_dokter, no_hp_dokter) FROM stdin;
    public          postgres    false    215   �[       [          0    25256    karyawan 
   TABLE DATA           �   COPY public.karyawan (id_karyawan, first_name, last_name, tanggal_lahir, jenis_kelamin, bagian, jalan, rt_rw, kelurahan, kecamatan, kota_kabupaten, provinsi) FROM stdin;
    public          postgres    false    216   p\       \          0    25273    konsumen 
   TABLE DATA           t   COPY public.konsumen (id_konsumen, first_name, last_name, tanggal_lahir, jenis_kelamin, no_hp_konsumen) FROM stdin;
    public          postgres    false    217   �]       ]          0    25290    no_hp_karyawan 
   TABLE DATA           <   COPY public.no_hp_karyawan (id_karyawan, no_hp) FROM stdin;
    public          postgres    false    218   �_       ^          0    25302    obat 
   TABLE DATA           Z   COPY public.obat (kode_obat, nama_obat, jenis_obat, harga_jual, expired_date) FROM stdin;
    public          postgres    false    219   !`       _          0    25314    resep 
   TABLE DATA           L   COPY public.resep (no_resep, tanggal_resep, no_nota, id_dokter) FROM stdin;
    public          postgres    false    220   �`       `          0    25328    rincian_pembelian 
   TABLE DATA           a   COPY public.rincian_pembelian (no_faktur, kode_obat, jumlah_obat_dibeli, harga_beli) FROM stdin;
    public          postgres    false    221   ia       a          0    25343    rincian_penjualan 
   TABLE DATA           S   COPY public.rincian_penjualan (no_nota, kode_obat, jumlah_obat_dijual) FROM stdin;
    public          postgres    false    222   �a       b          0    25357    supplier 
   TABLE DATA           R   COPY public.supplier (id_supplier, nama_supplier, no_telepon, alamat) FROM stdin;
    public          postgres    false    223   fb       c          0    25369    transaksi_pembelian 
   TABLE DATA           X   COPY public.transaksi_pembelian (no_faktur, tanggal_pembelian, id_supplier) FROM stdin;
    public          postgres    false    224   xc       d          0    25380    transaksi_penjualan 
   TABLE DATA           c   COPY public.transaksi_penjualan (no_nota, tanggal_penjualan, id_konsumen, id_karyawan) FROM stdin;
    public          postgres    false    225   �c       l           0    0    konsumen_id_konsumen_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.konsumen_id_konsumen_seq', 1, false);
          public          postgres    false    226            �           2606    25930    konsumen konsumen_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.konsumen
    ADD CONSTRAINT konsumen_pkey PRIMARY KEY (id_konsumen);
 @   ALTER TABLE ONLY public.konsumen DROP CONSTRAINT konsumen_pkey;
       public            postgres    false    217            �           2606    25242    berisi pk_berisi 
   CONSTRAINT     _   ALTER TABLE ONLY public.berisi
    ADD CONSTRAINT pk_berisi PRIMARY KEY (no_resep, kode_obat);
 :   ALTER TABLE ONLY public.berisi DROP CONSTRAINT pk_berisi;
       public            postgres    false    214    214            �           2606    25255    dokter pk_dokter 
   CONSTRAINT     U   ALTER TABLE ONLY public.dokter
    ADD CONSTRAINT pk_dokter PRIMARY KEY (id_dokter);
 :   ALTER TABLE ONLY public.dokter DROP CONSTRAINT pk_dokter;
       public            postgres    false    215            �           2606    25272    karyawan pk_karyawan 
   CONSTRAINT     [   ALTER TABLE ONLY public.karyawan
    ADD CONSTRAINT pk_karyawan PRIMARY KEY (id_karyawan);
 >   ALTER TABLE ONLY public.karyawan DROP CONSTRAINT pk_karyawan;
       public            postgres    false    216            �           2606    25300     no_hp_karyawan pk_no_hp_karyawan 
   CONSTRAINT     n   ALTER TABLE ONLY public.no_hp_karyawan
    ADD CONSTRAINT pk_no_hp_karyawan PRIMARY KEY (id_karyawan, no_hp);
 J   ALTER TABLE ONLY public.no_hp_karyawan DROP CONSTRAINT pk_no_hp_karyawan;
       public            postgres    false    218    218            �           2606    25313    obat pk_obat 
   CONSTRAINT     Q   ALTER TABLE ONLY public.obat
    ADD CONSTRAINT pk_obat PRIMARY KEY (kode_obat);
 6   ALTER TABLE ONLY public.obat DROP CONSTRAINT pk_obat;
       public            postgres    false    219            �           2606    25324    resep pk_resep 
   CONSTRAINT     R   ALTER TABLE ONLY public.resep
    ADD CONSTRAINT pk_resep PRIMARY KEY (no_resep);
 8   ALTER TABLE ONLY public.resep DROP CONSTRAINT pk_resep;
       public            postgres    false    220            �           2606    25340 &   rincian_pembelian pk_rincian_pembelian 
   CONSTRAINT     v   ALTER TABLE ONLY public.rincian_pembelian
    ADD CONSTRAINT pk_rincian_pembelian PRIMARY KEY (no_faktur, kode_obat);
 P   ALTER TABLE ONLY public.rincian_pembelian DROP CONSTRAINT pk_rincian_pembelian;
       public            postgres    false    221    221            �           2606    25354 &   rincian_penjualan pk_rincian_penjualan 
   CONSTRAINT     t   ALTER TABLE ONLY public.rincian_penjualan
    ADD CONSTRAINT pk_rincian_penjualan PRIMARY KEY (no_nota, kode_obat);
 P   ALTER TABLE ONLY public.rincian_penjualan DROP CONSTRAINT pk_rincian_penjualan;
       public            postgres    false    222    222            �           2606    25367    supplier pk_supplier 
   CONSTRAINT     [   ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT pk_supplier PRIMARY KEY (id_supplier);
 >   ALTER TABLE ONLY public.supplier DROP CONSTRAINT pk_supplier;
       public            postgres    false    223            �           2606    25379 *   transaksi_pembelian pk_transaksi_pembelian 
   CONSTRAINT     o   ALTER TABLE ONLY public.transaksi_pembelian
    ADD CONSTRAINT pk_transaksi_pembelian PRIMARY KEY (no_faktur);
 T   ALTER TABLE ONLY public.transaksi_pembelian DROP CONSTRAINT pk_transaksi_pembelian;
       public            postgres    false    224            �           2606    25390 *   transaksi_penjualan pk_transaksi_penjualan 
   CONSTRAINT     m   ALTER TABLE ONLY public.transaksi_penjualan
    ADD CONSTRAINT pk_transaksi_penjualan PRIMARY KEY (no_nota);
 T   ALTER TABLE ONLY public.transaksi_penjualan DROP CONSTRAINT pk_transaksi_penjualan;
       public            postgres    false    225            �           1259    25325    dokterresep    INDEX     B   CREATE INDEX dokterresep ON public.resep USING btree (id_dokter);
    DROP INDEX public.dokterresep;
       public            postgres    false    220            �           1259    25326    idx_id_dokter    INDEX     D   CREATE INDEX idx_id_dokter ON public.resep USING btree (id_dokter);
 !   DROP INDEX public.idx_id_dokter;
       public            postgres    false    220            �           1259    25391    idx_id_karyawan    INDEX     V   CREATE INDEX idx_id_karyawan ON public.transaksi_penjualan USING btree (id_karyawan);
 #   DROP INDEX public.idx_id_karyawan;
       public            postgres    false    225            �           1259    25368    idx_id_supplier    INDEX     M   CREATE INDEX idx_id_supplier ON public.supplier USING btree (nama_supplier);
 #   DROP INDEX public.idx_id_supplier;
       public            postgres    false    223            �           1259    25301    karyawanno_hp_karyawan    INDEX     X   CREATE INDEX karyawanno_hp_karyawan ON public.no_hp_karyawan USING btree (id_karyawan);
 *   DROP INDEX public.karyawanno_hp_karyawan;
       public            postgres    false    218            �           1259    25392    karyawantransaksi_penjualan    INDEX     b   CREATE INDEX karyawantransaksi_penjualan ON public.transaksi_penjualan USING btree (id_karyawan);
 /   DROP INDEX public.karyawantransaksi_penjualan;
       public            postgres    false    225            �           1259    25933    konsumentransaksi_penjualan    INDEX     b   CREATE INDEX konsumentransaksi_penjualan ON public.transaksi_penjualan USING btree (id_konsumen);
 /   DROP INDEX public.konsumentransaksi_penjualan;
       public            postgres    false    225            �           1259    25243 
   obatberisi    INDEX     B   CREATE INDEX obatberisi ON public.berisi USING btree (kode_obat);
    DROP INDEX public.obatberisi;
       public            postgres    false    214            �           1259    25341    obatrincian_pembelian    INDEX     X   CREATE INDEX obatrincian_pembelian ON public.rincian_pembelian USING btree (kode_obat);
 )   DROP INDEX public.obatrincian_pembelian;
       public            postgres    false    221            �           1259    25355    obatrincian_penjualan    INDEX     X   CREATE INDEX obatrincian_penjualan ON public.rincian_penjualan USING btree (kode_obat);
 )   DROP INDEX public.obatrincian_penjualan;
       public            postgres    false    222            �           1259    25244    resepberisi    INDEX     B   CREATE INDEX resepberisi ON public.berisi USING btree (no_resep);
    DROP INDEX public.resepberisi;
       public            postgres    false    214            �           1259    25342 $   transaksi_pembelianrincian_pembelian    INDEX     g   CREATE INDEX transaksi_pembelianrincian_pembelian ON public.rincian_pembelian USING btree (no_faktur);
 8   DROP INDEX public.transaksi_pembelianrincian_pembelian;
       public            postgres    false    221            �           1259    25327    transaksi_penjualanresep    INDEX     M   CREATE INDEX transaksi_penjualanresep ON public.resep USING btree (no_nota);
 ,   DROP INDEX public.transaksi_penjualanresep;
       public            postgres    false    220            �           1259    25356 $   transaksi_penjualanrincian_penjualan    INDEX     e   CREATE INDEX transaksi_penjualanrincian_penjualan ON public.rincian_penjualan USING btree (no_nota);
 8   DROP INDEX public.transaksi_penjualanrincian_penjualan;
       public            postgres    false    222            �           2606    25409    resep dokterresep    FK CONSTRAINT     �   ALTER TABLE ONLY public.resep
    ADD CONSTRAINT dokterresep FOREIGN KEY (id_dokter) REFERENCES public.dokter(id_dokter) ON UPDATE CASCADE;
 ;   ALTER TABLE ONLY public.resep DROP CONSTRAINT dokterresep;
       public          postgres    false    220    215    3230            �           2606    25946    transaksi_penjualan id_karyawan    FK CONSTRAINT     �   ALTER TABLE ONLY public.transaksi_penjualan
    ADD CONSTRAINT id_karyawan FOREIGN KEY (id_karyawan) REFERENCES public.karyawan(id_karyawan) NOT VALID;
 I   ALTER TABLE ONLY public.transaksi_penjualan DROP CONSTRAINT id_karyawan;
       public          postgres    false    216    225    3232            �           2606    25941    transaksi_penjualan id_konsumen    FK CONSTRAINT     �   ALTER TABLE ONLY public.transaksi_penjualan
    ADD CONSTRAINT id_konsumen FOREIGN KEY (id_konsumen) REFERENCES public.konsumen(id_konsumen) NOT VALID;
 I   ALTER TABLE ONLY public.transaksi_penjualan DROP CONSTRAINT id_konsumen;
       public          postgres    false    217    3234    225            �           2606    25404 %   no_hp_karyawan karyawanno_hp_karyawan    FK CONSTRAINT     �   ALTER TABLE ONLY public.no_hp_karyawan
    ADD CONSTRAINT karyawanno_hp_karyawan FOREIGN KEY (id_karyawan) REFERENCES public.karyawan(id_karyawan) ON UPDATE CASCADE;
 O   ALTER TABLE ONLY public.no_hp_karyawan DROP CONSTRAINT karyawanno_hp_karyawan;
       public          postgres    false    216    3232    218            �           2606    25394    berisi obatberisi    FK CONSTRAINT     �   ALTER TABLE ONLY public.berisi
    ADD CONSTRAINT obatberisi FOREIGN KEY (kode_obat) REFERENCES public.obat(kode_obat) ON UPDATE CASCADE;
 ;   ALTER TABLE ONLY public.berisi DROP CONSTRAINT obatberisi;
       public          postgres    false    3239    219    214            �           2606    25419 '   rincian_pembelian obatrincian_pembelian    FK CONSTRAINT     �   ALTER TABLE ONLY public.rincian_pembelian
    ADD CONSTRAINT obatrincian_pembelian FOREIGN KEY (kode_obat) REFERENCES public.obat(kode_obat) ON UPDATE CASCADE;
 Q   ALTER TABLE ONLY public.rincian_pembelian DROP CONSTRAINT obatrincian_pembelian;
       public          postgres    false    219    3239    221            �           2606    25429 '   rincian_penjualan obatrincian_penjualan    FK CONSTRAINT     �   ALTER TABLE ONLY public.rincian_penjualan
    ADD CONSTRAINT obatrincian_penjualan FOREIGN KEY (kode_obat) REFERENCES public.obat(kode_obat) ON UPDATE CASCADE;
 Q   ALTER TABLE ONLY public.rincian_penjualan DROP CONSTRAINT obatrincian_penjualan;
       public          postgres    false    219    3239    222            �           2606    25399    berisi resepberisi    FK CONSTRAINT     �   ALTER TABLE ONLY public.berisi
    ADD CONSTRAINT resepberisi FOREIGN KEY (no_resep) REFERENCES public.resep(no_resep) ON UPDATE CASCADE;
 <   ALTER TABLE ONLY public.berisi DROP CONSTRAINT resepberisi;
       public          postgres    false    214    3243    220            �           2606    25439 /   transaksi_pembelian suppliertransaksi_pembelian    FK CONSTRAINT     �   ALTER TABLE ONLY public.transaksi_pembelian
    ADD CONSTRAINT suppliertransaksi_pembelian FOREIGN KEY (id_supplier) REFERENCES public.supplier(id_supplier) ON UPDATE CASCADE;
 Y   ALTER TABLE ONLY public.transaksi_pembelian DROP CONSTRAINT suppliertransaksi_pembelian;
       public          postgres    false    223    3255    224            �           2606    25424 6   rincian_pembelian transaksi_pembelianrincian_pembelian    FK CONSTRAINT     �   ALTER TABLE ONLY public.rincian_pembelian
    ADD CONSTRAINT transaksi_pembelianrincian_pembelian FOREIGN KEY (no_faktur) REFERENCES public.transaksi_pembelian(no_faktur) ON UPDATE CASCADE;
 `   ALTER TABLE ONLY public.rincian_pembelian DROP CONSTRAINT transaksi_pembelianrincian_pembelian;
       public          postgres    false    224    3257    221            �           2606    25414    resep transaksi_penjualanresep    FK CONSTRAINT     �   ALTER TABLE ONLY public.resep
    ADD CONSTRAINT transaksi_penjualanresep FOREIGN KEY (no_nota) REFERENCES public.transaksi_penjualan(no_nota) ON UPDATE CASCADE;
 H   ALTER TABLE ONLY public.resep DROP CONSTRAINT transaksi_penjualanresep;
       public          postgres    false    3262    220    225            �           2606    25434 6   rincian_penjualan transaksi_penjualanrincian_penjualan    FK CONSTRAINT     �   ALTER TABLE ONLY public.rincian_penjualan
    ADD CONSTRAINT transaksi_penjualanrincian_penjualan FOREIGN KEY (no_nota) REFERENCES public.transaksi_penjualan(no_nota) ON UPDATE CASCADE;
 `   ALTER TABLE ONLY public.rincian_penjualan DROP CONSTRAINT transaksi_penjualanrincian_penjualan;
       public          postgres    false    225    3262    222            Y   T   x�e���0C�s3��"�.�?i���}Y�l�PPc�'.eF��]����.V8,n9]��k�h��>"ff*(�f�'��      Z   �   x�U��j1�y
@�����,�� �(��&0�FJ(����$#��/�D@Zcק���f}���
��*��bx6���2��� "^*s��R�O�Z�%�WrN�|{����-� ����ˈ# *`��f��ql��0+E_�4X�r�M��s,J,%Π'h����x�˼>��+�@*mO�;M_-pߺ1�[U۸{6[��_ ���1���Y�      [   o  x����N�@F������.��w�ڦbM�V��fH�Х�]�>�6X��'!��Ξo>�{\�ub!��� �0�.�g�S,R���fX�c������V���>,mf��B\�.1���n�;9���V�D�6e�$����g�^��i��!�0��4�l�K�����&8���(�4�kU}�$�FX��F�BC�w����η�I���=
�7�}����	�&K3k*�sR��E)�]g��Ѩ���X;p(�s����u�H͑L��l�#^4��~�kס��wg�����̏0)X��R*X��Am�>5�Iyd�s|Fw�\����n��H�CK�$�-�cLu�0���q�7��      \   �  x�u�OkA�ϚO�{�"i�izs0�!u)	��\���׭�&��W^���]�i��{zzCp8{x��������;���a����D	� ba���a������E�RJN�����sw������4�Ns\�)�{r>����;�U�Q�o�(s�H�S�E{;�gXv��R������H�\�T�K�֟
���yb�%�M�=b� ��jk��V��[ǉe�֝ץȌ^�h�u�]�I�x�İ�f�{�0����=��p�[�� ��v�&�S�6ٝ�!\��@���Ya�c�G�վ�m@n��H��9����V�G�^{�tΜZ2~��Pa�tyx���]�'��1cøh8���xG�R��ltk5�-Y��ə9-\m�K=�n�=�f���!�E(Yu�9
M�����BƥE�C!%f���9����      ]   g   x�=���@��Q�ɘ����:BVQ��m���.U9��Cru'�"���"�� ��R�
�G� ]u�l��5�&�F������\�M�G3Ͻ�!��7�G5 A      ^   �   x�Uϱ�0�����@�i��L4��r�$-%�	�o1�Br���$$�{n��uG� @
*Pa)p�/A��J��v�dX)��:P�zɍ�6�s�:o��ok�s���6T���TQ�l�@�r�u�7g.������_����zM�[��}�zZį]�$?v�E�      _   �   x�}���0г4EHA����d�9j�H�p ��@Q�Q����� �i�/�+��C�u�xfU�T���+�C��zU^�*]�����c�]�\�P�U�U����U���$�+	�[��SU?��I`      `   H   x�]�A�0D�5���6�w���PH](�Ix� !�Z�%�9L���]Ǯ�Qb���r똭z5[U�u��EA�      a   �   x�e�K� �5fb�w���cP1k6��܀��Y���RH�=�C�i��/:S,�)�'1ɓ��>D���{9�ي5���YS����p�$䋀���Ͳ:�M�U�s�Ţ��M;w��Y�ob�C�rT6��IV���&�]��c�� Y�      b     x�U�Aj�0E��)� �X�-+˸PhLJH���9�4�����W.�-F�7��Xv8�V���c|�NHF�Y%���7m�K8zs�yOF��Y�G����-~@;�F8��m�*��	]Vq.%Blo�W�{��pA��<�����H����r�Q/�5�T�l����HA?h��φ�u��h	>�V�+� ���Є����KLߢa��"�`ͼ*p�rٶ�L�W���K�� 4]���EK�;����nq�      c   _   x�m�A
�0Dѵ9�{�L&�V����ajb���3�l"�
Sp���)^$�puC�l�E#�k���A���(���H����4��\E�A�$�      d   �   x�u�;�0��"}�h�c�A���r�s���5d% �x b,e�x.�q�P{���]����J=�V��R���bޔFF���7�"����Eܩɪ�kO���e�S�Q�lf/�T��l�����%l�/�2�,��-�;�����_�����L�N��t��^M�)J����(7�״Z���TR.9����Q�����~!��A�=     