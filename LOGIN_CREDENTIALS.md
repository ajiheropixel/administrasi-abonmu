# 🔐 Login Credentials - Sistem Administrasi Rumah Produksi Abon

## Akun yang Tersedia

### 👤 ADMIN (Full Access)
- **Email**: `admin@abonmu.com`
- **Password**: `admin123`
- **Akses**: 
  - ✅ Dashboard
  - ✅ Produksi (Create, Read, Update, Delete)
  - ✅ Produk dan Stok (Create, Read, Update, Delete)
  - ✅ Pelanggan (Create, Read, Update, Delete)
  - ✅ Pengeluaran Produksi (Create, Read, Update, Delete)
  - ✅ Penjualan (Create, Read, Update, Delete)
  - ✅ Laporan (View & Download PDF)

---

### 👤 OWNER (View Only)
- **Email**: `owner@abonmu.com`
- **Password**: `owner123`
- **Akses**:
  - ✅ Dashboard (View Only)
  - ✅ Laporan (View & Download PDF)
  - ❌ Tidak bisa input/edit/delete data

---

## 🚀 Cara Login

1. Buka browser dan akses: `http://localhost/abonmu/login` atau `http://abonmu.test/login`
2. Masukkan email dan password sesuai role yang diinginkan
3. Klik tombol "Masuk"

---

## 🔄 Cara Mengganti Password

Jika ingin mengganti password, jalankan perintah berikut di terminal:

```bash
php artisan tinker
```

Kemudian jalankan:

```php
// Ganti password Admin
$user = User::where('email', 'admin@abonmu.com')->first();
$user->password = bcrypt('password_baru_anda');
$user->save();

// Ganti password Owner
$user = User::where('email', 'owner@abonmu.com')->first();
$user->password = bcrypt('password_baru_anda');
$user->save();
```

---

## 📱 Akses Mobile

Sistem sudah responsive dan bisa diakses melalui:
- 📱 Smartphone
- 💻 Tablet
- 🖥️ Desktop

---

## ⚠️ Catatan Keamanan

- **PENTING**: Segera ganti password default setelah login pertama kali
- Jangan bagikan kredensial login kepada orang yang tidak berwenang
- Gunakan password yang kuat (minimal 8 karakter, kombinasi huruf, angka, dan simbol)

---

## 🆘 Troubleshooting

### Lupa Password?
Hubungi administrator sistem atau jalankan seeder ulang:
```bash
php artisan db:seed --class=UserSeeder
```

### Tidak Bisa Login?
1. Pastikan sudah menjalankan migration: `php artisan migrate`
2. Pastikan sudah menjalankan seeder: `php artisan db:seed --class=UserSeeder`
3. Clear cache: `php artisan cache:clear`

---

**Dibuat pada**: {{ date('d F Y') }}
**Sistem**: Administrasi Rumah Produksi Abon
