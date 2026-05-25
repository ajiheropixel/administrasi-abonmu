<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ProductionController;
use App\Http\Controllers\ExpenseController;
use App\Http\Controllers\SaleController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\EmployeeController;
use App\Http\Controllers\SalaryController;
use App\Http\Controllers\AuthController;

// Test route (no database required)
Route::get('/test', function () {
    return '<h1>Laravel App is Working!</h1><p>Database connection issue detected. Please start MySQL server and create "abonmu" database.</p>';
});

// Authentication Routes
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Protected Routes (require authentication)
Route::middleware(['auth'])->group(function () {
    // Dashboard - accessible by both admin and owner
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

    // Reports - accessible by both admin and owner
    Route::prefix('reports')->name('reports.')->group(function () {
        Route::get('/', [App\Http\Controllers\ReportController::class, 'index'])->name('index');
        Route::get('/production', [App\Http\Controllers\ReportController::class, 'productionReport'])->name('production');
        Route::get('/sales', [App\Http\Controllers\ReportController::class, 'salesReport'])->name('sales');
        Route::get('/expense', [App\Http\Controllers\ReportController::class, 'expenseReport'])->name('expense');
        Route::get('/integrated', [App\Http\Controllers\ReportController::class, 'integratedReport'])->name('integrated');
        Route::get('/integrated/download', [App\Http\Controllers\ReportController::class, 'downloadIntegratedReport'])->name('integrated.download');
    });

    // Admin Only Routes
    Route::middleware(['role:admin'])->group(function () {
        Route::resource('products', ProductController::class);
        Route::resource('productions', ProductionController::class);
        Route::resource('expenses', ExpenseController::class);
        Route::resource('customers', CustomerController::class);
        Route::resource('employees', EmployeeController::class);

        Route::resource('sales', SaleController::class);
        Route::get('sales/{sale}/invoice', [SaleController::class, 'invoice'])->name('sales.invoice');
        Route::get('/sales/{sale}/invoice/download', [SaleController::class, 'downloadInvoice'])->name('sales.invoice.download');

        Route::get('salaries', [SalaryController::class, 'index'])->name('salaries.index');
    });
});
