# Quick Start Guide

## Instalasi Cepat (5 Menit)

### 1. Persiapan
Pastikan sudah terinstall:
- PHP 8.1 atau lebih tinggi
- Composer
- MySQL atau PostgreSQL
- Web server (Apache/Nginx) atau gunakan built-in PHP server

### 2. Setup Database
Buat database baru:
```sql
CREATE DATABASE abon_db;
```

### 3. Install & Setup
```bash
# Install dependencies
composer install

# Copy environment file
copy .env.example .env

# Generate application key
php artisan key:generate

# Edit .env dan sesuaikan database
# DB_DATABASE=abon_db
# DB_USERNAME=root
# DB_PASSWORD=

# Run migrations dengan data awal
php artisan migrate --seed

# Jalankan server
php artisan serve
```

### 4. Akses Aplikasi
Buka browser: http://localhost:8000

## Data Awal yang Tersedia

Setelah menjalankan seeder, sistem sudah memiliki:

### Produk:
- Abon Sapi Original (Rp 50.000)
- Abon Sapi Pedas (Rp 55.000)
- Abon Ayam Original (Rp 40.000)

### Karyawan:
- Budi Santoso (Tarif: Rp 500/unit, Rp 200/bungkus)
- Siti Aminah (Tarif: Rp 500/unit, Rp 200/bungkus)
- Ahmad Fauzi (Tarif: Rp 500/unit, Rp 200/bungkus)

### Pelanggan:
- Toko Berkah Jaya
- Warung Makan Sederhana
- Ibu Ratna

## Alur Penggunaan Pertama Kali

### Step 1: Catat Produksi
1. Klik menu **Produksi**
2. Klik **Tambah Produksi**
3. Isi:
   - Tanggal: Hari ini
   - Produk: Abon Sapi Original
   - Jumlah: 100
   - Jenis: Rutin
   - Centang: Budi Santoso dan Siti Aminah
4. Simpan

**Hasil:** Stok Abon Sapi Original bertambah 100 bungkus

### Step 2: Catat Pengeluaran
1. Klik menu **Pengeluaran**
2. Klik **Tambah Pengeluaran**
3. Isi:
   - Tanggal: Hari ini
   - Kategori: Bahan Baku
   - Jumlah: 500000
   - Keterangan: Daging sapi 5 kg
4. Simpan

### Step 3: Catat Penjualan
1. Klik menu **Penjualan**
2. Klik **Tambah Penjualan**
3. Isi:
   - Tanggal: Hari ini
   - Jenis: Ecer
   - Pelanggan: (kosongkan untuk umum)
   - Item:
     - Produk: Abon Sapi Original
     - Jumlah: 20
     - Harga: 50000 (auto-fill)
4. Simpan

**Hasil:** 
- Stok berkurang 20 bungkus
- Faktur ter-generate otomatis
- Bisa langsung dicetak

### Step 4: Lihat Dashboard
1. Klik menu **Dashboard**
2. Lihat ringkasan:
   - Produksi: 100 bungkus
   - Penjualan: Rp 1.000.000
   - Pengeluaran: Rp 500.000
   - Laba: Rp 500.000

### Step 5: Cek Gaji Karyawan
1. Klik menu **Alokasi Gaji**
2. Pilih periode bulan ini
3. Klik **Filter**
4. Lihat perhitungan:
   - Budi: Produksi (50 × 500) + Packing (20 × 200) = Rp 29.000
   - Siti: Produksi (50 × 500) + Packing (20 × 200) = Rp 29.000

## Tips Cepat

### Shortcut Menu:
- **Dashboard** - Ringkasan cepat
- **Produk & Stok** - Cek stok
- **Produksi** - Input produksi harian
- **Pengeluaran** - Catat biaya
- **Penjualan** - Transaksi & faktur
- **Alokasi Gaji** - Rekap gaji

### Workflow Harian:
```
Pagi → Catat Produksi
Siang → Catat Pengeluaran
Sore → Catat Penjualan
Malam → Cek Dashboard
```

### Workflow Bulanan:
```
Awal Bulan → Rekap Gaji Bulan Lalu
Tengah Bulan → Monitor Stok
Akhir Bulan → Review Laporan
```

## Troubleshooting Cepat

### Error: "No application encryption key"
```bash
php artisan key:generate
```

### Error: Database connection
- Cek .env file
- Pastikan database sudah dibuat
- Cek username/password

### Error: "Class not found"
```bash
composer dump-autoload
```

### Stok tidak update
- Refresh halaman
- Cek apakah transaksi tersimpan

### Lupa password database
- Edit .env
- Sesuaikan dengan kredensial database Anda

## Bantuan Lebih Lanjut

- **Panduan Lengkap:** Baca PANDUAN_PENGGUNAAN.md
- **Daftar Fitur:** Baca FITUR_SISTEM.md
- **Command Reference:** Baca COMMANDS.md
- **Struktur Database:** Lihat database_structure.sql

## Reset Database (Jika Perlu)

Untuk memulai dari awal:
```bash
php artisan migrate:fresh --seed
```

**PERINGATAN:** Ini akan menghapus semua data!

## Backup Data

Backup database secara berkala:
```bash
# Windows
mysqldump -u root -p abon_db > backup.sql

# Restore
mysql -u root -p abon_db < backup.sql
```

## Selamat Menggunakan!

Sistem siap digunakan. Mulai dengan workflow di atas dan sesuaikan dengan kebutuhan bisnis Anda.

Untuk pertanyaan lebih lanjut, lihat dokumentasi lengkap atau hubungi administrator sistem.