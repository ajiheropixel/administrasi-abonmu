# API Documentation - Sistem Administrasi Rumah Produksi AbonMu

## Base URL
```
http://your-domain.com/api/v1
```

## Authentication
API menggunakan Laravel Sanctum untuk autentikasi. Setelah login, gunakan token yang diberikan di header setiap request:

```
Authorization: Bearer {your-token}
```

---

## 1. Authentication

### Login
**POST** `/login`

Request Body:
```json
{
  "email": "admin@abonmu.com",
  "password": "admin123"
}
```

Response Success (200):
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "user": {
      "id": 1,
      "name": "Admin",
      "email": "admin@abonmu.com",
      "role": "admin"
    },
    "token": "1|xxxxxxxxxxxxxxxxxxxxx"
  }
}
```

Response Error (401):
```json
{
  "success": false,
  "message": "Email atau password salah"
}
```

### Logout
**POST** `/logout`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "message": "Logout berhasil"
}
```

### Get Profile
**GET** `/profile`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Admin",
    "email": "admin@abonmu.com",
    "role": "admin"
  }
}
```

---

## 2. Dashboard

### Get Dashboard Statistics
**GET** `/dashboard/stats`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `month` - Bulan (1-12), default: bulan sekarang
- `year` - Tahun (YYYY), default: tahun sekarang

Response (200):
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_production": 5000,
      "total_sales": 75000000,
      "total_expenses": 25000000,
      "net_profit": 50000000,
      "total_transactions": 150,
      "average_sale": 500000
    },
    "recent_productions": [...],
    "recent_sales": [...],
    "top_products": [...],
    "low_stock_products": [...],
    "charts": {
      "sales": [...],
      "production": [...]
    }
  }
}
```

### Get Monthly Comparison
**GET** `/dashboard/monthly-comparison`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `months` - Jumlah bulan (default: 6)

Response (200):
```json
{
  "success": true,
  "data": [
    {
      "month": "Jan 2026",
      "production": 4500,
      "sales": 65000000,
      "expenses": 20000000,
      "profit": 45000000
    },
    ...
  ]
}
```

---

## 3. Products

### Get All Products
**GET** `/products`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `category` - Filter by category
- `search` - Search by name
- `per_page` - Items per page (default: 15)
- `page` - Page number

Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Abon Ayam 100gr",
      "category": "Abon Ayam",
      "description": "Abon ayam premium",
      "price": 25000,
      "stock": 150,
      "unit": "bungkus",
      "created_at": "2026-01-01T00:00:00.000000Z",
      "updated_at": "2026-01-01T00:00:00.000000Z"
    },
    ...
  ],
  "pagination": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 75
  }
}
```

### Get Single Product
**GET** `/products/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Abon Ayam 100gr",
    "category": "Abon Ayam",
    "description": "Abon ayam premium",
    "price": 25000,
    "stock": 150,
    "unit": "bungkus"
  }
}
```

### Check Product Stock
**GET** `/products/{id}/stock`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {
    "product_id": 1,
    "product_name": "Abon Ayam 100gr",
    "stock": 150,
    "unit": "bungkus",
    "is_low_stock": false
  }
}
```

### Get Product Categories
**GET** `/products/categories`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": [
    "Abon Ayam",
    "Abon Sapi",
    "Abon Ikan",
    "Abon Lainnya"
  ]
}
```

### Create Product (Admin Only)
**POST** `/products`

Headers: `Authorization: Bearer {token}`

Request Body:
```json
{
  "name": "Abon Ayam 100gr",
  "category": "Abon Ayam",
  "description": "Abon ayam premium",
  "price": 25000,
  "unit": "bungkus"
}
```

Response (201):
```json
{
  "success": true,
  "message": "Produk berhasil ditambahkan",
  "data": {...}
}
```

### Update Product (Admin Only)
**PUT** `/products/{id}`

Headers: `Authorization: Bearer {token}`

Request Body: (sama seperti Create)

Response (200):
```json
{
  "success": true,
  "message": "Produk berhasil diperbarui",
  "data": {...}
}
```

### Delete Product (Admin Only)
**DELETE** `/products/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "message": "Produk berhasil dihapus"
}
```

---

## 4. Productions

### Get All Productions
**GET** `/productions`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `category` - Filter by category
- `type` - Filter by type (rutin/pesanan)
- `product_id` - Filter by product
- `start_date` - Filter by start date (YYYY-MM-DD)
- `end_date` - Filter by end date (YYYY-MM-DD)
- `per_page` - Items per page (default: 15)
- `page` - Page number

Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "product_id": 1,
      "production_date": "2026-03-10",
      "quantity": 500,
      "type": "rutin",
      "category": "Abon Ayam",
      "notes": "Produksi rutin",
      "product": {
        "id": 1,
        "name": "Abon Ayam 100gr",
        ...
      }
    },
    ...
  ],
  "pagination": {...}
}
```

### Get Single Production
**GET** `/productions/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "product_id": 1,
    "production_date": "2026-03-10",
    "quantity": 500,
    "type": "rutin",
    "category": "Abon Ayam",
    "notes": "Produksi rutin",
    "product": {...},
    "expenses": [...]
  }
}
```

### Get Production Statistics
**GET** `/productions/statistics`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `start_date` - Start date (YYYY-MM-DD)
- `end_date` - End date (YYYY-MM-DD)
- `category` - Filter by category
- `type` - Filter by type

Response (200):
```json
{
  "success": true,
  "data": {
    "total_production": 5000,
    "total_rutin": 3000,
    "total_pesanan": 2000,
    "total_transactions": 50,
    "by_category": {
      "Abon Ayam": {
        "total": 3000,
        "rutin": 2000,
        "pesanan": 1000
      },
      ...
    }
  }
}
```

### Create Production (Admin Only)
**POST** `/productions`

Headers: `Authorization: Bearer {token}`

Request Body:
```json
{
  "product_id": 1,
  "production_date": "2026-03-10",
  "quantity": 500,
  "type": "rutin",
  "category": "Abon Ayam",
  "notes": "Produksi rutin"
}
```

Response (201):
```json
{
  "success": true,
  "message": "Data produksi berhasil ditambahkan",
  "data": {...}
}
```

### Update Production (Admin Only)
**PUT** `/productions/{id}`

Headers: `Authorization: Bearer {token}`

Request Body: (sama seperti Create)

Response (200):
```json
{
  "success": true,
  "message": "Data produksi berhasil diperbarui",
  "data": {...}
}
```

### Delete Production (Admin Only)
**DELETE** `/productions/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "message": "Data produksi berhasil dihapus"
}
```

---

## 5. Expenses

### Get All Expenses
**GET** `/expenses`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `category` - Filter by category
- `production_id` - Filter by production
- `start_date` - Filter by start date (YYYY-MM-DD)
- `end_date` - Filter by end date (YYYY-MM-DD)
- `per_page` - Items per page (default: 15)
- `page` - Page number

Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "production_id": 1,
      "expense_date": "2026-03-10",
      "category": "Bahan Baku",
      "amount": 500000,
      "description": "Pembelian ayam",
      "production": {
        "id": 1,
        "product": {...}
      }
    },
    ...
  ],
  "pagination": {...}
}
```

### Get Single Expense
**GET** `/expenses/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {...}
}
```

### Get Expense Categories
**GET** `/expenses/categories`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": [
    "Bahan Baku",
    "Operasional",
    "Transportasi",
    ...
  ]
}
```

### Get Expense Statistics
**GET** `/expenses/statistics`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `start_date` - Start date (YYYY-MM-DD)
- `end_date` - End date (YYYY-MM-DD)
- `category` - Filter by category

Response (200):
```json
{
  "success": true,
  "data": {
    "total_amount": 25000000,
    "total_transactions": 100,
    "by_category": {
      "Bahan Baku": {
        "total_amount": 15000000,
        "count": 50
      },
      ...
    }
  }
}
```

### Create Expense (Admin Only)
**POST** `/expenses`

Headers: `Authorization: Bearer {token}`

Request Body:
```json
{
  "production_id": 1,
  "expense_date": "2026-03-10",
  "category": "Bahan Baku",
  "amount": 500000,
  "description": "Pembelian ayam"
}
```

Response (201):
```json
{
  "success": true,
  "message": "Pengeluaran berhasil ditambahkan",
  "data": {...}
}
```

### Update Expense (Admin Only)
**PUT** `/expenses/{id}`

Headers: `Authorization: Bearer {token}`

Request Body: (sama seperti Create)

Response (200):
```json
{
  "success": true,
  "message": "Pengeluaran berhasil diperbarui",
  "data": {...}
}
```

### Delete Expense (Admin Only)
**DELETE** `/expenses/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "message": "Pengeluaran berhasil dihapus"
}
```

---

## 6. Sales

### Get All Sales
**GET** `/sales`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `customer_id` - Filter by customer
- `type` - Filter by type (ecer/pesanan)
- `start_date` - Filter by start date (YYYY-MM-DD)
- `end_date` - Filter by end date (YYYY-MM-DD)
- `search` - Search by invoice number
- `per_page` - Items per page (default: 15)
- `page` - Page number

Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "invoice_number": "INV-20260310-0001",
      "customer_id": 1,
      "sale_date": "2026-03-10",
      "type": "pesanan",
      "total_amount": 1500000,
      "notes": "Pesanan khusus",
      "customer": {
        "id": 1,
        "name": "Toko ABC",
        ...
      },
      "items": [
        {
          "id": 1,
          "product_id": 1,
          "quantity": 50,
          "price": 25000,
          "subtotal": 1250000,
          "product": {...}
        },
        ...
      ]
    },
    ...
  ],
  "pagination": {...}
}
```

### Get Single Sale
**GET** `/sales/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {...}
}
```

### Get Invoice Data
**GET** `/sales/{id}/invoice`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {...}
}
```

### Get Sales Statistics
**GET** `/sales/statistics`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `start_date` - Start date (YYYY-MM-DD)
- `end_date` - End date (YYYY-MM-DD)
- `type` - Filter by type

Response (200):
```json
{
  "success": true,
  "data": {
    "total_revenue": 75000000,
    "total_transactions": 150,
    "average_transaction": 500000,
    "by_type": {
      "ecer": 25000000,
      "pesanan": 50000000
    }
  }
}
```

### Create Sale (Admin Only)
**POST** `/sales`

Headers: `Authorization: Bearer {token}`

Request Body:
```json
{
  "customer_id": 1,
  "sale_date": "2026-03-10",
  "type": "pesanan",
  "notes": "Pesanan khusus",
  "items": [
    {
      "product_id": 1,
      "quantity": 50,
      "price": 25000
    },
    {
      "product_id": 2,
      "quantity": 30,
      "price": 15000
    }
  ]
}
```

Response (201):
```json
{
  "success": true,
  "message": "Penjualan berhasil ditambahkan",
  "data": {...}
}
```

Response Error - Stock Insufficient (400):
```json
{
  "success": false,
  "message": "Stok Abon Ayam 100gr tidak mencukupi. Stok tersedia: 20"
}
```

### Delete Sale (Admin Only)
**DELETE** `/sales/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "message": "Penjualan berhasil dihapus"
}
```

---

## 7. Customers

### Get All Customers
**GET** `/customers`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `search` - Search by name or phone
- `per_page` - Items per page (default: 15)
- `page` - Page number

Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Toko ABC",
      "phone": "081234567890",
      "address": "Jl. Contoh No. 123"
    },
    ...
  ],
  "pagination": {...}
}
```

### Get Single Customer
**GET** `/customers/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Toko ABC",
    "phone": "081234567890",
    "address": "Jl. Contoh No. 123",
    "sales": [...]
  }
}
```

### Create Customer (Admin Only)
**POST** `/customers`

Headers: `Authorization: Bearer {token}`

Request Body:
```json
{
  "name": "Toko ABC",
  "phone": "081234567890",
  "address": "Jl. Contoh No. 123"
}
```

Response (201):
```json
{
  "success": true,
  "message": "Pelanggan berhasil ditambahkan",
  "data": {...}
}
```

### Update Customer (Admin Only)
**PUT** `/customers/{id}`

Headers: `Authorization: Bearer {token}`

Request Body: (sama seperti Create)

Response (200):
```json
{
  "success": true,
  "message": "Pelanggan berhasil diperbarui",
  "data": {...}
}
```

### Delete Customer (Admin Only)
**DELETE** `/customers/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "message": "Pelanggan berhasil dihapus"
}
```

---

## 8. Employees

### Get All Employees
**GET** `/employees`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `search` - Search by name
- `position` - Filter by position
- `per_page` - Items per page (default: 15)
- `page` - Page number

Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "position": "Produksi",
      "phone": "081234567890",
      "address": "Jl. Contoh No. 123",
      "salary": 3000000
    },
    ...
  ],
  "pagination": {...}
}
```

### Get Single Employee
**GET** `/employees/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "data": {...}
}
```

### Create Employee (Admin Only)
**POST** `/employees`

Headers: `Authorization: Bearer {token}`

Request Body:
```json
{
  "name": "John Doe",
  "position": "Produksi",
  "phone": "081234567890",
  "address": "Jl. Contoh No. 123",
  "salary": 3000000
}
```

Response (201):
```json
{
  "success": true,
  "message": "Karyawan berhasil ditambahkan",
  "data": {...}
}
```

### Update Employee (Admin Only)
**PUT** `/employees/{id}`

Headers: `Authorization: Bearer {token}`

Request Body: (sama seperti Create)

Response (200):
```json
{
  "success": true,
  "message": "Karyawan berhasil diperbarui",
  "data": {...}
}
```

### Delete Employee (Admin Only)
**DELETE** `/employees/{id}`

Headers: `Authorization: Bearer {token}`

Response (200):
```json
{
  "success": true,
  "message": "Karyawan berhasil dihapus"
}
```

---

## 9. Reports

### Get Integrated Report
**GET** `/reports/integrated`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `start_date` - Start date (YYYY-MM-DD)
- `end_date` - End date (YYYY-MM-DD)
- `category` - Filter by category
- `type` - Filter by type
- `product_id` - Filter by product

Response (200):
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_production": 5000,
      "total_sales": 75000000,
      "total_expenses": 25000000,
      "net_profit": 50000000,
      "total_transactions": 150
    },
    "productions": [...],
    "expenses": [...],
    "sales": [...],
    "production_by_category": {...},
    "sales_by_product": [...],
    "expenses_by_category": {...},
    "period": {
      "start_date": "2026-03-01",
      "end_date": "2026-03-31"
    }
  }
}
```

### Download Integrated Report PDF
**GET** `/reports/integrated/download`

Headers: `Authorization: Bearer {token}`

Query Parameters: (sama seperti Get Integrated Report)

Response: PDF File Download

### Get Production Report
**GET** `/reports/production`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `start_date` - Start date (YYYY-MM-DD)
- `end_date` - End date (YYYY-MM-DD)
- `category` - Filter by category
- `type` - Filter by type
- `product_id` - Filter by product

Response (200):
```json
{
  "success": true,
  "data": {
    "productions": [...],
    "statistics": {
      "total_production": 5000,
      "total_rutin": 3000,
      "total_pesanan": 2000,
      "total_transactions": 50
    },
    "period": {
      "start_date": "2026-03-01",
      "end_date": "2026-03-31"
    }
  }
}
```

### Get Sales Report
**GET** `/reports/sales`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `start_date` - Start date (YYYY-MM-DD)
- `end_date` - End date (YYYY-MM-DD)

Response (200):
```json
{
  "success": true,
  "data": {
    "sales": [...],
    "statistics": {
      "total_revenue": 75000000,
      "total_transactions": 150,
      "average_transaction": 500000
    },
    "period": {
      "start_date": "2026-03-01",
      "end_date": "2026-03-31"
    }
  }
}
```

### Get Expense Report
**GET** `/reports/expenses`

Headers: `Authorization: Bearer {token}`

Query Parameters (optional):
- `start_date` - Start date (YYYY-MM-DD)
- `end_date` - End date (YYYY-MM-DD)

Response (200):
```json
{
  "success": true,
  "data": {
    "expenses": [...],
    "statistics": {
      "total_expense": 25000000,
      "total_transactions": 100,
      "by_category": {...}
    },
    "period": {
      "start_date": "2026-03-01",
      "end_date": "2026-03-31"
    }
  }
}
```

---

## Error Responses

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthenticated."
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Anda tidak memiliki akses. Hanya admin yang dapat melakukan operasi ini."
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Data tidak ditemukan"
}
```

### 422 Validation Error
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": [
      "The email field is required."
    ],
    "password": [
      "The password field is required."
    ]
  }
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Terjadi kesalahan: [error message]"
}
```

---

## Role-Based Access Control

### Admin Role
- Full access ke semua endpoint
- Dapat melakukan CRUD operations (Create, Read, Update, Delete)

### Owner Role
- Read-only access ke:
  - Dashboard
  - Products (view only)
  - Productions (view only)
  - Expenses (view only)
  - Sales (view only)
  - Customers (view only)
  - Employees (view only)
  - Reports (view & download)
- Tidak dapat melakukan Create, Update, atau Delete operations

---

## Testing dengan Postman/Insomnia

1. **Login** terlebih dahulu untuk mendapatkan token
2. **Copy token** dari response login
3. **Set Authorization header** di setiap request berikutnya:
   - Type: Bearer Token
   - Token: [paste token dari login]
4. **Test endpoint** sesuai kebutuhan

---

## Notes

- Semua tanggal menggunakan format: `YYYY-MM-DD`
- Semua response menggunakan format JSON
- Pagination default: 15 items per page
- Token tidak memiliki expiration (bisa diatur di config/sanctum.php)
- Untuk production, sebaiknya set token expiration
