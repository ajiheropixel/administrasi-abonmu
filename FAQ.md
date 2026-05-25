# Frequently Asked Questions (FAQ)

## Umum

### Q: Apa itu Sistem Informasi Administrasi Rumah Produksi Abon?
**A:** Sistem berbasis web yang dibangun dengan Laravel untuk mengelola operasional rumah produksi abon, mencakup produksi, stok, pengeluaran, penjualan, faktur, dan alokasi gaji karyawan.

### Q: Apakah sistem ini gratis?
**A:** Ya, sistem ini menggunakan lisensi MIT dan dapat digunakan secara gratis. Anda bebas memodifikasi sesuai kebutuhan.

### Q: Apakah perlu koneksi internet?
**A:** Tidak, sistem dapat berjalan di localhost atau server lokal tanpa internet. Internet hanya diperlukan untuk instalasi dependencies awal.

### Q: Berapa biaya hosting?
**A:** Tergantung provider. Untuk shared hosting sekitar Rp 20.000-50.000/bulan. VPS sekitar Rp 50.000-200.000/bulan.

## Instalasi

### Q: Apa saja yang dibutuhkan untuk menjalankan sistem?
**A:** 
- PHP 8.1 atau lebih tinggi
- MySQL atau PostgreSQL
- Composer
- Web server (Apache/Nginx atau built-in PHP server)

### Q: Bagaimana cara install di Windows?
**A:** 
1. Install XAMPP atau Laragon
2. Clone/download project
3. Jalankan `composer install`
4. Setup `.env` file
5. Run `php artisan migrate --seed`
6. Akses via browser

### Q: Error "composer: command not found"?
**A:** Install Composer terlebih dahulu dari https://getcomposer.org/download/

### Q: Error "No application encryption key"?
**A:** Jalankan `php artisan key:generate`

## Penggunaan

### Q: Bagaimana cara menambah produk baru?
**A:** 
1. Klik menu "Produk & Stok"
2. Klik tombol "Tambah Produk"
3. Isi form (nama, harga, satuan)
4. Klik "Simpan"

### Q: Kenapa stok tidak bisa diubah manual?
**A:** Stok dikelola otomatis oleh sistem. Stok bertambah saat produksi dan berkurang saat penjualan. Ini untuk menjaga akurasi data.

### Q: Bagaimana cara mencetak faktur?
**A:** 
1. Buka detail penjualan
2. Klik tombol "Cetak Faktur"
3. Faktur akan terbuka di tab baru
4. Klik tombol "Cetak" atau Ctrl+P

### Q: Apakah bisa menghapus transaksi yang sudah dibuat?
**A:** Ya, tapi hati-hati karena akan mempengaruhi stok dan laporan. Pastikan data yang dihapus memang salah.

### Q: Bagaimana cara menghitung gaji karyawan?
**A:** 
1. Klik menu "Alokasi Gaji"
2. Pilih periode (tanggal mulai dan akhir)
3. Klik "Filter"
4. Sistem akan menghitung otomatis berdasarkan:
   - Gaji Produksi = Jumlah produksi × Tarif produksi
   - Gaji Packing = Jumlah penjualan × Tarif packing

## Stok & Produksi

### Q: Apa bedanya produksi "Rutin" dan "Pesanan"?
**A:** 
- **Rutin:** Produksi terjadwal/reguler
- **Pesanan:** Produksi berdasarkan pesanan khusus
Keduanya sama-sama menambah stok, hanya berbeda kategori untuk laporan.

### Q: Kenapa stok tidak bertambah setelah input produksi?
**A:** 
- Pastikan produksi tersimpan dengan benar (ada notifikasi sukses)
- Refresh halaman produk
- Cek di detail produksi apakah data sudah masuk

### Q: Bagaimana jika salah input jumlah produksi?
**A:** Hapus data produksi yang salah, lalu input ulang dengan data yang benar.

### Q: Apakah bisa produksi tanpa karyawan?
**A:** Tidak, minimal harus memilih 1 karyawan yang terlibat dalam produksi.

## Penjualan

### Q: Apa bedanya penjualan "Ecer" dan "Pesanan"?
**A:** 
- **Ecer:** Penjualan langsung/retail
- **Pesanan:** Penjualan berdasarkan pesanan pelanggan
Keduanya sama-sama mengurangi stok, hanya berbeda kategori.

### Q: Apakah harus memilih pelanggan saat penjualan?
**A:** Tidak, pelanggan opsional. Jika tidak dipilih, akan tercatat sebagai "Umum".

### Q: Bagaimana jika stok tidak cukup?
**A:** Sistem akan menampilkan error dan tidak mengizinkan penjualan melebihi stok yang tersedia.

### Q: Apakah bisa mengubah harga saat penjualan?
**A:** Ya, harga akan otomatis terisi dari data produk, tapi bisa diubah manual jika ada diskon atau harga khusus.

### Q: Format nomor faktur seperti apa?
**A:** Format: INV-YYYYMMDD-XXXX
Contoh: INV-20240115-0001 (faktur pertama tanggal 15 Januari 2024)

## Laporan

### Q: Bagaimana cara melihat laporan bulanan?
**A:** 
1. Klik menu "Laporan"
2. Pilih tanggal mulai (awal bulan) dan tanggal akhir (akhir bulan)
3. Klik "Filter"

### Q: Apakah bisa export laporan ke Excel?
**A:** Fitur ini belum tersedia di versi 1.0. Akan ditambahkan di versi mendatang.

### Q: Bagaimana cara menghitung laba bersih?
**A:** Laba Bersih = Total Penjualan - Total Pengeluaran
Perhitungan otomatis ditampilkan di dashboard dan laporan.

## Gaji Karyawan

### Q: Bagaimana sistem menghitung gaji?
**A:** 
- **Gaji Produksi:** Jumlah unit yang diproduksi × Tarif produksi karyawan
- **Gaji Packing:** Total penjualan periode tersebut × Tarif packing karyawan
- **Total Gaji:** Gaji Produksi + Gaji Packing

### Q: Kenapa gaji packing sama untuk semua karyawan?
**A:** Karena sistem menghitung packing berdasarkan total penjualan, bukan per karyawan. Ini asumsi bahwa semua karyawan aktif terlibat dalam packing.

### Q: Apakah bisa custom perhitungan gaji?
**A:** Saat ini menggunakan sistem standar. Untuk custom, perlu modifikasi kode di SalaryController.

### Q: Bagaimana jika karyawan resign?
**A:** Ubah status karyawan menjadi "Tidak Aktif". Karyawan tidak aktif tidak akan muncul di form produksi dan perhitungan gaji.

## Teknis

### Q: Bagaimana cara backup data?
**A:** 
```bash
# Backup database
mysqldump -u username -p database_name > backup.sql

# Backup files
tar -czf backup.tar.gz /path/to/project
```

### Q: Bagaimana cara restore data?
**A:** 
```bash
mysql -u username -p database_name < backup.sql
```

### Q: Apakah data aman?
**A:** Ya, sistem menggunakan:
- CSRF protection
- SQL injection prevention
- XSS protection
- Input validation

### Q: Bagaimana cara update sistem?
**A:** 
1. Backup data terlebih dahulu
2. Pull/download versi terbaru
3. Run `composer update`
4. Run `php artisan migrate`
5. Clear cache: `php artisan cache:clear`

### Q: Apakah bisa diakses dari HP?
**A:** Ya, desain responsif dan bisa diakses dari smartphone/tablet.

### Q: Apakah bisa multi-user?
**A:** Versi 1.0 belum ada sistem login. Untuk multi-user dengan role, perlu implementasi authentication.

## Troubleshooting

### Q: Error 500 Internal Server Error?
**A:** 
1. Cek `storage/logs/laravel.log`
2. Pastikan permission folder storage dan bootstrap/cache: `chmod -R 775`
3. Clear cache: `php artisan cache:clear`
4. Cek `.env` configuration

### Q: Halaman blank/putih?
**A:** 
1. Set `APP_DEBUG=true` di `.env` untuk melihat error
2. Cek error log
3. Pastikan semua dependencies terinstall: `composer install`

### Q: Database connection error?
**A:** 
1. Cek kredensial database di `.env`
2. Pastikan MySQL/PostgreSQL running
3. Test koneksi: `mysql -u username -p`

### Q: Stok tidak update?
**A:** 
1. Refresh halaman
2. Cek apakah transaksi tersimpan
3. Cek `storage/logs/laravel.log` untuk error
4. Pastikan tidak ada error JavaScript di console browser

### Q: Faktur tidak bisa dicetak?
**A:** 
1. Cek popup blocker browser
2. Coba browser lain
3. Pastikan JavaScript enabled
4. Cek console browser untuk error

### Q: Pagination tidak muncul?
**A:** Pagination hanya muncul jika data lebih dari 10 records per halaman.

### Q: Tanggal tidak sesuai?
**A:** 
1. Cek timezone di `config/app.php`
2. Set: `'timezone' => 'Asia/Jakarta'`
3. Clear config: `php artisan config:clear`

## Pengembangan

### Q: Bagaimana cara menambah fitur baru?
**A:** 
1. Buat migration untuk database
2. Buat model
3. Buat controller
4. Buat views
5. Tambahkan routes
6. Update dokumentasi

### Q: Apakah bisa custom desain?
**A:** Ya, edit file di `resources/views/` dan sesuaikan Tailwind CSS classes.

### Q: Bagaimana cara menambah field baru?
**A:** 
1. Buat migration: `php artisan make:migration add_field_to_table`
2. Update model (tambahkan ke $fillable)
3. Update controller validation
4. Update views (form dan display)

### Q: Apakah ada API?
**A:** Ya, ada beberapa API endpoints. Lihat `API_DOCUMENTATION.md` untuk detail.

### Q: Bagaimana cara kontribusi?
**A:** 
1. Fork repository
2. Buat branch baru
3. Commit changes
4. Push ke branch
5. Create pull request

## Lisensi & Support

### Q: Apakah boleh dimodifikasi?
**A:** Ya, sistem menggunakan MIT License. Bebas dimodifikasi dan didistribusikan.

### Q: Apakah boleh dijual?
**A:** Ya, tapi harus tetap mencantumkan lisensi MIT.

### Q: Dimana bisa dapat support?
**A:** 
- Baca dokumentasi lengkap
- Cek GitHub issues
- Email developer
- Community forum (jika ada)

### Q: Apakah ada versi berbayar dengan fitur lebih lengkap?
**A:** Saat ini hanya ada versi open source. Untuk custom development, bisa hubungi developer.

## Tips & Tricks

### Q: Apa workflow terbaik untuk penggunaan harian?
**A:** 
1. Pagi: Input produksi hari ini
2. Siang: Catat pengeluaran yang terjadi
3. Sore: Input penjualan
4. Malam: Cek dashboard untuk summary

### Q: Bagaimana cara menjaga akurasi data?
**A:** 
- Input data segera setelah transaksi
- Double check sebelum save
- Backup data secara berkala
- Jangan hapus data sembarangan
- Training user yang menggunakan sistem

### Q: Rekomendasi untuk performa optimal?
**A:** 
- Gunakan SSD untuk database
- Enable OPcache
- Optimize database queries
- Regular maintenance
- Monitor server resources

---

**Tidak menemukan jawaban?**
Silakan hubungi support atau buat issue di GitHub repository.