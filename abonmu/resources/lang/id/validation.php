<?php

return [
    'required' => ':attribute harus diisi.',
    'string' => ':attribute harus berupa teks.',
    'max' => [
        'string' => ':attribute tidak boleh lebih dari :max karakter.',
    ],
    'min' => [
        'numeric' => ':attribute minimal :min.',
        'array' => ':attribute minimal harus memiliki :min item.',
    ],
    'numeric' => ':attribute harus berupa angka.',
    'integer' => ':attribute harus berupa bilangan bulat.',
    'date' => ':attribute harus berupa tanggal yang valid.',
    'exists' => ':attribute yang dipilih tidak valid.',
    'unique' => ':attribute sudah digunakan.',
    'in' => ':attribute yang dipilih tidak valid.',
    'array' => ':attribute harus berupa array.',
    
    'attributes' => [
        'name' => 'Nama',
        'phone' => 'Nomor Telepon',
        'address' => 'Alamat',
        'price' => 'Harga',
        'quantity' => 'Jumlah',
        'product_id' => 'Produk',
        'customer_id' => 'Pelanggan',
        'employee_id' => 'Karyawan',
        'production_date' => 'Tanggal Produksi',
        'sale_date' => 'Tanggal Penjualan',
        'expense_date' => 'Tanggal Pengeluaran',
        'category' => 'Kategori',
        'amount' => 'Jumlah',
        'description' => 'Keterangan',
        'type' => 'Jenis',
        'notes' => 'Catatan',
        'employees' => 'Karyawan',
        'items' => 'Item',
        'production_rate' => 'Tarif Produksi',
        'packing_rate' => 'Tarif Packing',
    ],
];
