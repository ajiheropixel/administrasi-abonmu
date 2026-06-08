<?php

namespace App\Http\Controllers;

use App\Models\Production;
use App\Models\Sale;
use App\Models\Expense;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        try {
            $totalProduction = Production::whereMonth('production_date', date('m'))->sum('quantity');
            $recentProductions = Production::with('product')->latest()->take(5)->get();
        } catch (\Exception $e) {
            $totalProduction = 0;
            $recentProductions = collect();
        }
        
        try {
            $totalSales = Sale::whereMonth('sale_date', date('m'))->sum('total_amount');
            $recentSales = Sale::with('customer')->latest()->take(5)->get();
            
            // Statistik Penjualan
            $totalTransactions = Sale::whereMonth('sale_date', date('m'))->count();
            $averageSale = $totalTransactions > 0 ? $totalSales / $totalTransactions : 0;
            $topProducts = DB::table('sale_items')
                ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
                ->join('products', 'sale_items.product_id', '=', 'products.id')
                ->whereMonth('sales.sale_date', date('m'))
                ->select('products.name', DB::raw('SUM(sale_items.quantity) as total_sold'))
                ->groupBy('products.id', 'products.name')
                ->orderBy('total_sold', 'desc')
                ->take(5)
                ->get();
            
            // Data untuk chart penjualan 7 hari terakhir
            $salesChart = Sale::selectRaw('DATE(sale_date) as date, SUM(total_amount) as total')
                ->where('sale_date', '>=', now()->subDays(6))
                ->groupBy('date')
                ->orderBy('date')
                ->get();
            
            // Data untuk chart produksi 7 hari terakhir
            $productionChart = Production::selectRaw('DATE(production_date) as date, SUM(quantity) as total')
                ->where('production_date', '>=', now()->subDays(6))
                ->groupBy('date')
                ->orderBy('date')
                ->get();
                
        } catch (\Exception $e) {
            $totalSales = 0;
            $recentSales = collect();
            $totalTransactions = 0;
            $averageSale = 0;
            $topProducts = collect();
            $salesChart = collect();
            $productionChart = collect();
        }
        
        try {
            $totalExpenses = Expense::whereMonth('expense_date', date('m'))->sum('amount');
        } catch (\Exception $e) {
            $totalExpenses = 0;
        }
        
        $lowStockProducts = Product::where('stock', '<', 50)->get();
        
        return view('dashboard', compact(
            'totalProduction',
            'totalSales',
            'totalExpenses',
            'lowStockProducts',
            'recentProductions',
            'recentSales',
            'totalTransactions',
            'averageSale',
            'topProducts',
            'salesChart',
            'productionChart'
        ));
    }
}
