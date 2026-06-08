# Panduan Penggunaan Sistem

## Daftar Isi
1. [Setup Awal](#setup-awal)
2. [Manajemen Produk](#manajemen-produk)
3. [Manajemen Karyawan](#manajemen-karyawan)
4. [Proses Produksi](#proses-produksi)
5. [Pencatatan Pengeluaran](#pencatatan-pengeluaran)
6. [Proses Penjualan](#proses-penjualan)
7. [Perhitungan Gaji](#perhitungan-gaji)

---

## Setup Awal

### 1. Jalankan Migrasi Database
```bash
php artisan migrate
```

### 2. (Opsional) Isi Data Awal
```bash
php artisan db:seed --class=InitialDataSeeder
```

Data awal yang akan dibuat:
- 3 Produk abon (Sapi Original, Sapi Pedas, Ayam Original)
- 3 Karyawan dengan tarif standar
- 3 Pelanggan contoh

---

## Manajemen Produk

### Menambah Produk Baru
1. Klik menu **Produk & Stok**
2. Klik tombol **Tambah Produk**
3. Isi form:
   - Nama Produk (contoh: Abon Sapi Original)
   - Deskripsi (opsional)
   - Harga per unit
   - Satuan (default: bungkus)
4. Klik **Simpan**

### Mengedit Produk
1. Di halaman Produk & Stok, klik ikon edit (pensil)
2. Ubah data yang diperlukan
3. Klik **Update**

**Catatan:** Stok tidak bisa diubah manual, akan otomatis update dari produksi dan penjualan.

---

## Manajemen Karyawan

### Menambah Karyawan
1. Klik menu **Karyawan**
2. Klik **Tambah Karyawan**
3. Isi form:
   - Nama Karyawan
   - Nomor Telepon
   - Alamat
   - **Tarif Produksi** (upah per unit produksi)
   - **Tarif Packing** (upah per bungkus penjualan)
   - Status Aktif (centang jika aktif)
4. Klik **Simpan**

### Contoh Tarif
- Tarif Produksi: Rp 500 per unit
- Tarif Packing: Rp 200 per bungkus

---

## Proses Produksi

### Mencatat Produksi
1. Klik menu **Produksi**
2. Klik **Tambah Produksi**
3. Isi form:
   - Tanggal Produksi
   - Pilih Produk
   - Jumlah Produksi
   - Jenis Produksi (Rutin/Pesanan)
   - **Centang karyawan yang terlibat** (minimal 1)
   - Catatan (opsional)
4. Klik **Simpan**

### Efek Setelah Produksi Disimpan
- Stok produk otomatis bertambah sesuai jumlah produksi
- Data karyawan tercatat untuk perhitungan gaji

### Melihat Detail Produksi
1. Di halaman Produksi, klik ikon mata (view)
2. Akan tampil:
   - Informasi produksi
   - Karyawan yang terlibat
   - Pengeluaran terkait (jika ada)

---

## Pencatatan Pengeluaran

### Menambah Pengeluaran
1. Klik menu **Pengeluaran**
2. Klik **Tambah Pengeluaran**
3. Isi form:
   - Tanggal Pengeluaran
   - Kategori (contoh: Bahan Baku, Bumbu, Kemasan, Gas, Listrik)
   - Jumlah (dalam Rupiah)
   - Produksi Terkait (opsional, jika pengeluaran untuk produksi tertentu)
   - Keterangan
4. Klik **Simpan**

### Kategori Pengeluaran Umum
- Bahan Baku (daging, ayam)
- Bumbu
- Kemasan (plastik, label)
- Gas
- Listrik
- Transportasi
- Operasional

---

## Proses Penjualan

### Membuat Transaksi Penjualan
1. Klik menu **Penjualan**
2. Klik **Tambah Penjualan**
3. Isi form:
   - Tanggal Penjualan
   - Jenis Penjualan (Ecer/Pesanan)
   - Pelanggan (opsional, pilih dari database atau kosongkan untuk "Umum")
   - **Item Penjualan:**
     - Pilih Produk
     - Masukkan Jumlah
     - Harga akan otomatis terisi (bisa diubah)
     - Klik **Tambah Item** untuk item tambahan
   - Catatan (opsional)
4. Total akan otomatis terhitung
5. Klik **Simpan**

### Efek Setelah Penjualan Disimpan
- Stok produk otomatis berkurang
- Nomor faktur otomatis ter-generate (format: INV-YYYYMMDD-XXXX)
- Jumlah bungkus tercatat untuk perhitungan gaji packing

### Mencetak Faktur
1. Di halaman Penjualan, klik ikon faktur
2. Atau di halaman Detail Penjualan, klik **Cetak Faktur**
3. Faktur akan terbuka di tab baru
4. Klik tombol **Cetak Faktur** untuk print

---

## Perhitungan Gaji

### Melihat Rekap Gaji Karyawan
1. Klik menu **Alokasi Gaji**
2. Pilih periode:
   - Tanggal Mulai
   - Tanggal Akhir
3. Klik **Filter**

### Informasi yang Ditampilkan
Untuk setiap karyawan:
- **Produksi:** Jumlah unit yang diproduksi
- **Gaji Produksi:** Jumlah produksi × Tarif produksi
- **Packing:** Jumlah bungkus yang dijual (dari semua penjualan)
- **Gaji Packing:** Jumlah packing × Tarif packing
- **Total Gaji:** Gaji Produksi + Gaji Packing

### Contoh Perhitungan
**Karyawan: Budi Santoso**
- Tarif Produksi: Rp 500/unit
- Tarif Packing: Rp 200/bungkus

**Aktivitas Bulan Januari:**
- Terlibat produksi 200 unit
- Total penjualan bulan ini: 150 bungkus

**Perhitungan:**
- Gaji Produksi: 200 × Rp 500 = Rp 100.000
- Gaji Packing: 150 × Rp 200 = Rp 30.000
- **Total Gaji: Rp 130.000**

---

## Dashboard

Dashboard menampilkan ringkasan:
- **Produksi Bulan Ini:** Total unit yang diproduksi
- **Penjualan Bulan Ini:** Total pendapatan
- **Pengeluaran Bulan Ini:** Total biaya
- **Laba Bersih:** Penjualan - Pengeluaran
- **Produksi Terbaru:** 5 produksi terakhir
- **Penjualan Terbaru:** 5 penjualan terakhir
- **Alert Stok Menipis:** Produk dengan stok < 50

---

## Tips Penggunaan

### 1. Alur Kerja Harian
- Pagi: Catat produksi hari ini
- Siang: Catat pengeluaran yang terjadi
- Sore: Catat penjualan yang terjadi
- Akhir hari: Cek dashboard untuk ringkasan

### 2. Alur Kerja Bulanan
- Awal bulan: Lihat rekap gaji bulan lalu
- Tengah bulan: Pantau stok dan produksi
- Akhir bulan: Review laporan keuangan

### 3. Manajemen Stok
- Pantau alert stok menipis di dashboard
- Rencanakan produksi berdasarkan stok
- Catat produksi segera setelah selesai

### 4. Backup Data
Lakukan backup database secara berkala:
```bash
# Export database
mysqldump -u username -p database_name > backup.sql

# Import database
mysql -u username -p database_name < backup.sql
```

---

## Troubleshooting

### Stok Tidak Update
- Pastikan produksi/penjualan tersimpan dengan benar
- Cek di halaman Produk & Stok untuk melihat stok terkini

### Gaji Tidak Muncul
- Pastikan karyawan dicentang saat input produksi
- Pastikan periode filter sudah benar
- Pastikan ada transaksi penjualan untuk gaji packing

### Faktur Tidak Muncul
- Pastikan penjualan sudah tersimpan
- Coba refresh halaman
- Cek browser popup blocker

---

## Kontak Support

Jika ada pertanyaan atau masalah, silakan hubungi administrator sistem.