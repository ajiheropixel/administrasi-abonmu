# 📸 Cara Menambahkan Logo di Faktur

## Langkah Mudah (3 Menit)

### 1️⃣ Siapkan File Logo

**Format yang Didukung:**
- ✅ PNG (Recommended - support transparansi)
- ✅ JPG / JPEG
- ✅ GIF

**Ukuran yang Disarankan:**
- Lebar: 200-400 pixel
- Tinggi: 100-200 pixel
- Rasio: Landscape atau Square
- File size: < 500 KB

**Tips:**
- Gunakan background transparan (PNG)
- Resolusi tinggi untuk hasil cetak bagus
- Logo harus jelas dan tidak blur

---

### 2️⃣ Upload Logo

**Cara 1: Copy Manual**
```
1. Buka folder project
2. Masuk ke: public/images/
3. Copy file logo Anda ke folder ini
4. Rename file menjadi: logo.png
```

**Cara 2: Via File Manager**
```
1. Buka File Explorer / Finder
2. Navigate ke: C:\laragon\www\abonmu\public\images\
   (sesuaikan dengan lokasi project Anda)
3. Paste file logo
4. Rename menjadi: logo.png
```

**PENTING:**
- ⚠️ Nama file HARUS persis: `logo.png` (lowercase)
- ⚠️ Jangan gunakan spasi atau karakter khusus
- ⚠️ Jika pakai JPG, rename menjadi `logo.jpg` dan edit kode

---

### 3️⃣ Cek Hasil

**Test Logo:**
```
1. Buka sistem di browser
2. Buat transaksi penjualan (atau buka yang sudah ada)
3. Klik tombol "Cetak Faktur"
4. Logo akan muncul di header faktur!
```

**Jika Logo Tidak Muncul:**
- Refresh browser (Ctrl + F5)
- Clear cache browser
- Cek nama file (harus persis `logo.png`)
- Cek lokasi file (harus di `public/images/`)

---

## 🎨 Contoh Struktur Folder

```
project-root/
├── public/
│   ├── images/
│   │   ├── logo.png          ← TARUH LOGO DI SINI
│   │   └── README.md
│   ├── css/
│   └── js/
├── resources/
└── ...
```

---

## 📋 Checklist

Sebelum upload, pastikan:

- [ ] File logo sudah siap
- [ ] Format PNG atau JPG
- [ ] Ukuran tidak terlalu besar (< 500 KB)
- [ ] Logo terlihat jelas
- [ ] Background transparan (jika PNG)
- [ ] Nama file: `logo.png`
- [ ] Lokasi: `public/images/`

---

## 🔧 Troubleshooting

### Logo Tidak Muncul?

**Problem 1: File tidak ditemukan**
```
Solusi:
- Cek lokasi file: public/images/logo.png
- Cek nama file (case sensitive di Linux)
- Pastikan file tidak corrupt
```

**Problem 2: Logo terlalu besar/kecil**
```
Solusi:
Edit file: resources/views/sales/invoice.blade.php

Cari bagian:
.logo { 
    max-width: 100px;  ← Ubah ini
    max-height: 100px; ← Ubah ini
}
```

**Problem 3: Logo blur saat dicetak**
```
Solusi:
- Gunakan logo resolusi tinggi (min 300 DPI)
- Format PNG lebih baik dari JPG
- Ukuran file original lebih besar = kualitas lebih baik
```

---

## 💡 Tips & Trik

### 1. Logo dengan Background Transparan

Jika logo Anda punya background warna:
```
1. Gunakan tool online: remove.bg
2. Upload logo Anda
3. Download hasil (PNG transparan)
4. Upload ke sistem
```

### 2. Resize Logo

Jika logo terlalu besar:
```
1. Gunakan tool online: iloveimg.com/resize-image
2. Set ukuran: 300x150 pixel
3. Download hasil
4. Upload ke sistem
```

### 3. Optimize File Size

Jika file terlalu besar:
```
1. Gunakan tool: tinypng.com
2. Upload logo
3. Download hasil (ukuran lebih kecil, kualitas sama)
4. Upload ke sistem
```

---

## 🎯 Hasil Akhir

Setelah logo ditambahkan, faktur akan menampilkan:

```
┌─────────────────────────────────────────┐
│  [LOGO]  RUMAH PRODUKSI ABON           │
│          Sistem Administrasi            │
│          Alamat, Telp, Email            │
├─────────────────────────────────────────┤
│  FAKTUR: INV-20240115-0001              │
│  Tanggal: 15 Januari 2024               │
│                                          │
│  PELANGGAN: Toko ABC                    │
│  ...                                     │
└─────────────────────────────────────────┘
```

---

## 📞 Butuh Bantuan?

### Kontak Support:
- 📧 Email: support@example.com
- 💬 WhatsApp: 0812-3456-7890
- 📖 Dokumentasi: Baca FAQ.md

### Video Tutorial:
- Coming soon!

---

## ✅ Selesai!

Setelah mengikuti langkah di atas, logo Anda akan muncul di:
- ✅ Header faktur penjualan
- ✅ Watermark di background (opsional)
- ✅ Semua faktur yang dicetak

**Selamat! Faktur Anda sekarang lebih profesional! 🎉**

---

**Last Updated:** January 2024  
**Difficulty:** ⭐ Easy (3 minutes)  
**Status:** ✅ Tested & Working
