# 🏭 Sistem Informasi Administrasi Rumah Produksi Abon

[![Laravel](https://img.shields.io/badge/Laravel-10.x-red.svg)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.1+-blue.svg)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)]()

> Sistem berbasis web yang lengkap dan profesional untuk mengelola operasional rumah produksi abon, mencakup produksi, stok, pengeluaran, penjualan, faktur, dan alokasi gaji karyawan.

---

## 🚀 Quick Start

**Baru pertama kali?** Mulai di sini: **[START_HERE.md](START_HERE.md)** ⚡

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

Akses: **http://localhost:8000**

---

## Fitur Utama

- **Dashboard** - Ringkasan produksi, penjualan, pengeluaran, dan laba
- **Manajemen Produk & Stok** - Kelola produk dan pantau stok real-time
- **Produksi** - Catat produksi rutin dan pesanan dengan karyawan terlibat
- **Pengeluaran** - Catat biaya bahan baku, bumbu, kemasan, dan operasional
- **Penjualan** - Transaksi ecer dan pesanan dengan pengurangan stok otomatis
- **Faktur** - Generate faktur penjualan otomatis
- **Pelanggan** - Database pelanggan untuk penjualan pesanan
- **Karyawan** - Data karyawan dengan tarif produksi dan packing
- **Alokasi Gaji** - Hitung gaji berdasarkan produksi dan packing

## Teknologi

- Laravel 10
- PHP 8.1+
- MySQL/PostgreSQL
- Tailwind CSS
- Font Awesome Icons

## Instalasi

### 1. Clone Repository

```bash
git clone <repository-url>
cd <project-folder>
```

### 2. Install Dependencies

```bash
composer install
```

### 3. Konfigurasi Environment

```bash
copy .env.example .env
```

Edit file `.env` dan sesuaikan konfigurasi database:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=abon_db
DB_USERNAME=root
DB_PASSWORD=
```

### 4. Generate Application Key

```bash
php artisan key:generate
```

### 5. Jalankan Migrasi Database

```bash
php artisan migrate
```

### 6. Jalankan Server

```bash
php artisan serve
```

Akses aplikasi di: `http://localhost:8000`

## Struktur Database

### Tabel Utama

- **products** - Data produk abon
- **productions** - Catatan produksi
- **production_employees** - Relasi produksi dengan karyawan
- **expenses** - Pengeluaran produksi
- **sales** - Transaksi penjualan
- **sale_items** - Detail item penjualan
- **customers** - Data pelanggan
- **employees** - Data karyawan

## Alur Kerja Sistem

1. **Setup Awal**
   - Tambah produk abon
   - Tambah data karyawan dengan tarif
   - Tambah data pelanggan (opsional)

2. **Proses Produksi**
   - Catat produksi dengan pilih produk, jumlah, dan karyawan
   - Stok otomatis bertambah
   - Catat pengeluaran terkait produksi

3. **Proses Penjualan**
   - Buat transaksi penjualan
   - Pilih produk dan jumlah
   - Stok otomatis berkurang
   - Faktur otomatis ter-generate

4. **Perhitungan Gaji**
   - Pilih periode
   - Sistem hitung gaji produksi (jumlah produksi × tarif)
   - Sistem hitung gaji packing (jumlah penjualan × tarif)
   - Tampilkan total gaji per karyawan

## Desain Antarmuka

Sistem menggunakan desain modern dan profesional dengan:
- Sidebar navigasi dengan ikon
- Warna dominan slate/gray dengan aksen biru
- Card-based layout untuk dashboard
- Tabel responsif untuk data
- Form yang clean dan mudah digunakan
- Notifikasi sukses/error yang jelas

## Fitur Otomatis

- **Nomor Faktur** - Auto-generate dengan format INV-YYYYMMDD-XXXX
- **Manajemen Stok** - Otomatis update saat produksi dan penjualan
- **Perhitungan Total** - Auto-calculate di form penjualan
- **Perhitungan Gaji** - Otomatis berdasarkan aktivitas karyawan

## Laporan

Sistem menyediakan informasi:
- Ringkasan produksi bulanan
- Total penjualan dan pendapatan
- Total pengeluaran
- Laba bersih
- Stok menipis (alert)
- Rekap gaji karyawan per periode

## Lisensi

MIT License
