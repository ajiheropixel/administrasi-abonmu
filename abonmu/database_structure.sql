-- ============================================
-- STRUKTUR DATABASE
-- Sistem Informasi Administrasi Rumah Produksi Abon
-- ============================================

-- Tabel Products
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    unit VARCHAR(50) DEFAULT 'bungkus',
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);

-- Tabel Employees
CREATE TABLE employees (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    production_rate DECIMAL(10,2) DEFAULT 0,
    packing_rate DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);

-- Tabel Productions
CREATE TABLE productions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    production_date DATE NOT NULL,
    quantity INT NOT NULL,
    type ENUM('rutin', 'pesanan') DEFAULT 'rutin',
    notes TEXT,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Tabel Production_Employees (Pivot)
CREATE TABLE production_employees (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    production_id BIGINT UNSIGNED NOT NULL,
    employee_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (production_id) REFERENCES productions(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);

-- Tabel Expenses
CREATE TABLE expenses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    production_id BIGINT UNSIGNED,
    expense_date DATE NOT NULL,
    category VARCHAR(255) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (production_id) REFERENCES productions(id) ON DELETE SET NULL
);

-- Tabel Customers
CREATE TABLE customers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);

-- Tabel Sales
CREATE TABLE sales (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(255) UNIQUE NOT NULL,
    customer_id BIGINT UNSIGNED,
    sale_date DATE NOT NULL,
    type ENUM('ecer', 'pesanan') DEFAULT 'ecer',
    total_amount DECIMAL(12,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
);

-- Tabel Sale_Items
CREATE TABLE sale_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- ============================================
-- RELASI ANTAR TABEL
-- ============================================

-- 1. products -> productions (One to Many)
-- 2. products -> sale_items (One to Many)
-- 3. employees -> production_employees (Many to Many via productions)
-- 4. productions -> production_employees (Many to Many via employees)
-- 5. productions -> expenses (One to Many)
-- 6. customers -> sales (One to Many)
-- 7. sales -> sale_items (One to Many)

-- ============================================
-- LOGIKA BISNIS OTOMATIS
-- ============================================

-- 1. Saat produksi dibuat:
--    - Stok produk bertambah sesuai quantity

-- 2. Saat penjualan dibuat:
--    - Nomor faktur auto-generate (INV-YYYYMMDD-XXXX)
--    - Stok produk berkurang sesuai quantity

-- 3. Perhitungan gaji:
--    - Gaji Produksi = SUM(quantity produksi) × tarif_produksi
--    - Gaji Packing = SUM(quantity penjualan) × tarif_packing
--    - Total Gaji = Gaji Produksi + Gaji Packing

-- ============================================
-- CONTOH QUERY UNTUK LAPORAN
-- ============================================

-- Laporan Produksi Bulan Ini
SELECT 
    p.production_date,
    pr.name as product_name,
    p.quantity,
    p.type
FROM productions p
JOIN products pr ON p.product_id = pr.id
WHERE MONTH(p.production_date) = MONTH(CURRENT_DATE)
ORDER BY p.production_date DESC;

-- Laporan Penjualan Bulan Ini
SELECT 
    s.invoice_number,
    s.sale_date,
    COALESCE(c.name, 'Umum') as customer_name,
    s.total_amount
FROM sales s
LEFT JOIN customers c ON s.customer_id = c.id
WHERE MONTH(s.sale_date) = MONTH(CURRENT_DATE)
ORDER BY s.sale_date DESC;

-- Laporan Pengeluaran Bulan Ini
SELECT 
    e.expense_date,
    e.category,
    e.amount,
    e.description
FROM expenses e
WHERE MONTH(e.expense_date) = MONTH(CURRENT_DATE)
ORDER BY e.expense_date DESC;

-- Rekap Gaji Karyawan
SELECT 
    e.name as employee_name,
    COUNT(DISTINCT pe.production_id) as total_productions,
    SUM(p.quantity) as total_units_produced,
    SUM(p.quantity) * e.production_rate as production_salary,
    (SELECT SUM(si.quantity) 
     FROM sale_items si 
     JOIN sales s ON si.sale_id = s.id 
     WHERE MONTH(s.sale_date) = MONTH(CURRENT_DATE)) as total_packing,
    (SELECT SUM(si.quantity) 
     FROM sale_items si 
     JOIN sales s ON si.sale_id = s.id 
     WHERE MONTH(s.sale_date) = MONTH(CURRENT_DATE)) * e.packing_rate as packing_salary
FROM employees e
LEFT JOIN production_employees pe ON e.id = pe.employee_id
LEFT JOIN productions p ON pe.production_id = p.id
WHERE e.is_active = 1
  AND MONTH(p.production_date) = MONTH(CURRENT_DATE)
GROUP BY e.id, e.name, e.production_rate, e.packing_rate;