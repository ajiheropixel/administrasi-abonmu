# AbonMu Mobile App

Flutter mobile application untuk Sistem Administrasi Rumah Produksi AbonMu.

## 📱 Fitur Lengkap

### ✅ Dashboard
- Statistik real-time (produksi, penjualan, pengeluaran, laba bersih)
- Chart tren 6 bulan (penjualan vs pengeluaran)
- Top 5 produk terlaris
- Alert stok menipis
- Ringkasan transaksi bulanan

### ✅ Manajemen Produk
- CRUD produk (Admin only)
- Filter by kategori
- Search by nama
- Badge status stok (normal/low/critical)
- Pagination & infinite scroll

### ✅ Manajemen Produksi
- CRUD produksi (Admin only)
- Filter by tipe (rutin/pesanan)
- Filter by tanggal
- Detail produksi + pengeluaran terkait
- Statistik produksi

### ✅ Manajemen Penjualan
- Form penjualan multi-item
- Auto-generate invoice number
- Validasi stok real-time
- Filter by tipe (ecer/pesanan)
- Detail invoice lengkap
- Statistik penjualan

### ✅ Manajemen Pengeluaran
- CRUD pengeluaran (Admin only)
- Kategori pengeluaran
- Link ke produksi
- Statistik by kategori

### ✅ Manajemen Pelanggan
- CRUD pelanggan (Admin only)
- Search by nama/telepon
- History penjualan

### ✅ Manajemen Karyawan
- CRUD karyawan (Admin only)
- Data gaji & posisi
- Search by nama

### ✅ Laporan Terintegrasi
- Laporan produksi, penjualan, pengeluaran
- Filter by periode (date range)
- 3 tab: Terintegrasi, Produksi, Keuangan
- Kalkulasi laba bersih otomatis

### ✅ Autentikasi & Role
- Login dengan Sanctum token
- 2 role: Admin (full access) & Owner (read-only)
- Auto-logout
- Persistent session

## 🏗️ Arsitektur

```
lib/
├── main.dart                    # Entry point
├── core/
│   ├── constants/               # Colors, Theme, Constants
│   ├── network/                 # API Client (HTTP + error handling)
│   └── utils/                   # Currency & Date formatters
├── data/
│   ├── models/                  # 9 data models
│   └── repositories/            # 9 repositories (API calls)
├── providers/                   # 8 state management providers
└── presentation/
    ├── widgets/                 # 8 reusable widgets
    └── screens/                 # 10 modul screens
```

**Pattern:** Clean Architecture + Provider (State Management)

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Chrome/Edge (untuk web) atau Android/iOS device

### Installation

1. **Clone & Navigate**
```bash
cd mobile
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Konfigurasi API**

Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://your-domain.com/api/v1';
```

Ganti dengan URL backend Laravel Anda.

4. **Run di Web (Chrome)**
```bash
flutter run -d chrome --web-port 8080
```

5. **Run di Windows**
```bash
flutter run -d windows
```

6. **Run di Android/iOS**
```bash
flutter run
```

## 🔐 Login Credentials

**Admin:**
- Email: `admin@abonmu.com`
- Password: `admin123`

**Owner (Read-only):**
- Email: `owner@abonmu.com`
- Password: `owner123`

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0                  # HTTP client
  provider: ^6.1.2              # State management
  shared_preferences: ^2.2.3    # Local storage
  fl_chart: ^0.68.0             # Charts
  intl: ^0.19.0                 # Internationalization
```

## 🎨 Design System

### Colors
- **Primary:** `#D4622A` (Orange/Brown - tema abon)
- **Secondary:** `#2D6A4F` (Green)
- **Success:** `#2D6A4F`
- **Warning:** `#E9C46A`
- **Error:** `#E63946`
- **Info:** `#457B9D`

### Typography
- Font: Roboto
- Heading: 18-28px, Bold
- Body: 13-14px, Regular/Medium
- Caption: 11-12px, Regular

## 📱 Screens Overview

| Screen | Route | Access |
|--------|-------|--------|
| Login | `/` | Public |
| Dashboard | `/main` (tab 0) | Auth |
| Products | `/main` (tab 1) | Auth |
| Productions | `/main` (tab 2) | Auth |
| Sales | `/main` (tab 3) | Auth |
| More | `/main` (tab 4) | Auth |
| Expenses | `/expenses` | Auth |
| Customers | `/customers` | Auth |
| Employees | `/employees` | Auth |
| Reports | `/reports` | Auth |

## 🔧 Development

### Run Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

### Build Release

**Web:**
```bash
flutter build web --release
```

**Windows:**
```bash
flutter build windows --release
```

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📝 API Integration

App ini terintegrasi penuh dengan Laravel backend melalui REST API:

- **Base URL:** Configurable di `app_constants.dart`
- **Auth:** Laravel Sanctum (Bearer token)
- **Format:** JSON
- **Error Handling:** Centralized di `ApiClient`

### API Endpoints Used
- `POST /login` - Authentication
- `GET /dashboard/stats` - Dashboard data
- `GET /products` - Product list
- `POST /products` - Create product
- `GET /sales` - Sales list
- `POST /sales` - Create sale
- ... dan 30+ endpoint lainnya

## 🐛 Troubleshooting

### Error: "No supported devices"
```bash
flutter create . --platforms=web,windows
flutter pub get
```

### Error: "Unable to find directory entry"
Hapus `assets:` section dari `pubspec.yaml` jika tidak dipakai.

### Error: "Connection refused"
Pastikan backend Laravel sudah running dan `baseUrl` di `app_constants.dart` sudah benar.

### Build web lambat
Build pertama memang lambat (1-2 menit). Build selanjutnya lebih cepat dengan hot reload.

## 📄 License

Proprietary - AbonMu System

## 👨‍💻 Developer

Developed with Flutter & ❤️

---

**Version:** 1.0.0  
**Last Updated:** 2026-05-05
