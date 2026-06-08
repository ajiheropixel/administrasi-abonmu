<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthApiController;
use App\Http\Controllers\Api\ProductApiController;
use App\Http\Controllers\Api\ProductionApiController;
use App\Http\Controllers\Api\ExpenseApiController;
use App\Http\Controllers\Api\SaleApiController;
use App\Http\Controllers\Api\CustomerApiController;
use App\Http\Controllers\Api\EmployeeApiController;
use App\Http\Controllers\Api\DashboardApiController;
use App\Http\Controllers\Api\ReportApiController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {
    
    // Handle OPTIONS preflight
    Route::options('{any}', function () {
        return response('', 200)
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
            ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept');
    })->where('any', '.*');

    // Serve gambar storage dengan CORS header — dibutuhkan Flutter Web (Chrome)
    Route::get('image/{path}', function (string $path) {
        $fullPath = storage_path('app/public/' . $path);
        if (!file_exists($fullPath)) {
            return response()->json(['message' => 'Image not found'], 404);
        }
        $mime = mime_content_type($fullPath) ?: 'image/jpeg';
        return response()->file($fullPath, [
            'Access-Control-Allow-Origin' => '*',
            'Cache-Control'               => 'public, max-age=86400',
            'Content-Type'                => $mime,
        ]);
    })->where('path', '.*');

    // Public routes (no authentication required)
    Route::post('login', [AuthApiController::class, 'login']);
    
    // Protected routes (authentication required)
    Route::middleware('auth:sanctum')->group(function () {
        
        // Auth
        Route::post('logout', [AuthApiController::class, 'logout']);
        Route::get('profile', [AuthApiController::class, 'profile']);
        
        // Dashboard (accessible by all authenticated users)
        Route::get('dashboard/stats', [DashboardApiController::class, 'stats']);
        Route::get('dashboard/monthly-comparison', [DashboardApiController::class, 'monthlyComparison']);
        
        // Products (read-only for all, write for admin only)
        Route::get('products', [ProductApiController::class, 'index']);
        Route::get('products/categories', [ProductApiController::class, 'categories']);
        Route::get('products/{id}', [ProductApiController::class, 'show']);
        Route::get('products/{id}/stock', [ProductApiController::class, 'checkStock']);
        
        // Productions (read-only for all, write for admin only)
        Route::get('productions', [ProductionApiController::class, 'index']);
        Route::get('productions/statistics', [ProductionApiController::class, 'statistics']);
        Route::get('productions/{id}', [ProductionApiController::class, 'show']);
        
        // Expenses (read-only for all, write for admin only)
        Route::get('expenses', [ExpenseApiController::class, 'index']);
        Route::get('expenses/categories', [ExpenseApiController::class, 'categories']);
        Route::get('expenses/statistics', [ExpenseApiController::class, 'statistics']);
        Route::get('expenses/{id}', [ExpenseApiController::class, 'show']);
        
        // Sales (read-only for all, write for admin only)
        Route::get('sales', [SaleApiController::class, 'index']);
        Route::get('sales/statistics', [SaleApiController::class, 'statistics']);
        Route::get('sales/{id}', [SaleApiController::class, 'show']);
        Route::get('sales/{id}/invoice', [SaleApiController::class, 'invoice']);
        
        // Customers (read-only for all, write for admin only)
        Route::get('customers', [CustomerApiController::class, 'index']);
        Route::get('customers/{id}', [CustomerApiController::class, 'show']);
        
        // Employees (read-only for all, write for admin only)
        Route::get('employees', [EmployeeApiController::class, 'index']);
        Route::get('employees/{id}', [EmployeeApiController::class, 'show']);
        
        // Reports (accessible by all authenticated users)
        Route::get('reports/integrated', [ReportApiController::class, 'integrated']);
        Route::get('reports/integrated/download', [ReportApiController::class, 'downloadPdf']);
        Route::get('reports/production', [ReportApiController::class, 'production']);
        Route::get('reports/sales', [ReportApiController::class, 'sales']);
        Route::get('reports/expenses', [ReportApiController::class, 'expenses']);
        
        // Admin only routes (CRUD operations)
        Route::middleware('role:admin')->group(function () {
            
            // Products
            Route::post('products', [ProductApiController::class, 'store']);
            Route::put('products/{id}', [ProductApiController::class, 'update']);
            Route::delete('products/{id}', [ProductApiController::class, 'destroy']);
            
            // Productions
            Route::post('productions', [ProductionApiController::class, 'store']);
            Route::put('productions/{id}', [ProductionApiController::class, 'update']);
            Route::delete('productions/{id}', [ProductionApiController::class, 'destroy']);
            
            // Expenses
            Route::post('expenses', [ExpenseApiController::class, 'store']);
            Route::put('expenses/{id}', [ExpenseApiController::class, 'update']);
            Route::delete('expenses/{id}', [ExpenseApiController::class, 'destroy']);
            
            // Sales
            Route::post('sales', [SaleApiController::class, 'store']);
            Route::delete('sales/{id}', [SaleApiController::class, 'destroy']);
            
            // Customers
            Route::post('customers', [CustomerApiController::class, 'store']);
            Route::put('customers/{id}', [CustomerApiController::class, 'update']);
            Route::delete('customers/{id}', [CustomerApiController::class, 'destroy']);
            
            // Employees
            Route::post('employees', [EmployeeApiController::class, 'store']);
            Route::put('employees/{id}', [EmployeeApiController::class, 'update']);
            Route::delete('employees/{id}', [EmployeeApiController::class, 'destroy']);
            
        });
    });
});
