# Logo Directory

## Cara Menambahkan Logo

1. Simpan file logo Anda dengan nama **`logo.png`** di folder ini
2. Format yang didukung: PNG (recommended), JPG, JPEG
3. Ukuran yang disarankan: 
   - Lebar: 200-400px
   - Tinggi: 100-200px
   - Rasio: Landscape atau Square
4. Background: Transparan (PNG) untuk hasil terbaik

## Lokasi File

```
public/images/logo.png
```

## Penggunaan

Logo akan otomatis muncul di:
- ✅ Faktur penjualan (header)
- ✅ Watermark faktur (background)

## Contoh Nama File

- ✅ `logo.png` (BENAR)
- ❌ `Logo.png` (salah - case sensitive di Linux)
- ❌ `company-logo.png` (salah - harus nama persis)

## Tips

- Gunakan logo dengan resolusi tinggi untuk hasil cetak yang baik
- Pastikan logo terlihat jelas dengan background putih
- Jika logo tidak muncul, cek:
  1. Nama file harus persis `logo.png`
  2. File ada di folder `public/images/`
  3. Refresh browser (Ctrl+F5)

## Alternatif Format

Jika ingin menggunakan format lain, edit file:
`resources/views/sales/invoice.blade.php`

Ubah:
```php
@if(file_exists(public_path('images/logo.png')))
```

Menjadi:
```php
@if(file_exists(public_path('images/logo.jpg')))
```
