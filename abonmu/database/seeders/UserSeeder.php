<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create Admin User
        User::create([
            'name' => 'Administrator',
            'email' => 'admin@abonmu.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
        ]);

        // Create Owner User
        User::create([
            'name' => 'Owner',
            'email' => 'owner@abonmu.com',
            'password' => Hash::make('owner123'),
            'role' => 'owner',
        ]);

        $this->command->info('✅ Users created successfully!');
        $this->command->info('');
        $this->command->info('📋 Login Credentials:');
        $this->command->info('');
        $this->command->info('👤 ADMIN:');
        $this->command->info('   Email: admin@abonmu.com');
        $this->command->info('   Password: admin123');
        $this->command->info('');
        $this->command->info('👤 OWNER:');
        $this->command->info('   Email: owner@abonmu.com');
        $this->command->info('   Password: owner123');
    }
}
