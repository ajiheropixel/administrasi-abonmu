<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Product;
use App\Models\Employee;
use App\Models\Customer;

class InitialDataSeeder extends Seeder
{
    public function run(): void
    {
        // Seed Products
        Product::create([
            'name' => 'Abon Sapi Original',
            'description' => 'Abon sapi dengan rasa original',
            'price' => 50000,
            'stock' => 0,
            'unit' => 'bungkus'
        ]);

        Product::create([
            'name' => 'Abon Sapi Pedas',
            'description' => 'Abon sapi dengan rasa pedas',
            'price' => 55000,
            'stock' => 0,
            'unit' => 'bungkus'
        ]);

        Product::create([
            'name' => 'Abon Ayam Original',
            'description' => 'Abon ayam dengan rasa original',
            'price' => 40000,
            'stock' => 0,
            'unit' => 'bungkus'
        ]);

        // Seed Employees
        Employee::create([
            'name' => 'Budi Santoso',
            'phone' => '081234567890',
            'address' => 'Jl. Merdeka No. 10',
            'production_rate' => 500,
            'packing_rate' => 200,
            'is_active' => true
        ]);

        Employee::create([
            'name' => 'Siti Aminah',
            'phone' => '081234567891',
            'address' => 'Jl. Sudirman No. 20',
            'production_rate' => 500,
            'packing_rate' => 200,
            'is_active' => true
        ]);

        Employee::create([
            'name' => 'Ahmad Fauzi',
            'phone' => '081234567892',
            'address' => 'Jl. Gatot Subroto No. 30',
            'production_rate' => 500,
            'packing_rate' => 200,
            'is_active' => true
        ]);

        // Seed Customers
        Customer::create([
            'name' => 'Toko Berkah Jaya',
            'phone' => '081234567893',
            'address' => 'Jl. Pasar Baru No. 15'
        ]);

        Customer::create([
            'name' => 'Warung Makan Sederhana',
            'phone' => '081234567894',
            'address' => 'Jl. Ahmad Yani No. 25'
        ]);

        Customer::create([
            'name' => 'Ibu Ratna',
            'phone' => '081234567895',
            'address' => 'Jl. Diponegoro No. 35'
        ]);
    }
}
