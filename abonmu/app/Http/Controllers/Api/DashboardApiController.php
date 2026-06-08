<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Production;
use App\Models\Sale;
use App\Models\Expense;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardApiController extends Controller
{
    /**
     * Get dashboard statistics
     */
    public function stats(Request $request)
    {
        $month = $request->input('month', date('m'));
        $year = $request->input('year', date('Y'));
        
        try {
            // Production stats
            $totalProduction = Production::whereMonth('production_date', $month)
                ->whereYear('production_date', $year)
                ->sum('quantity');
            
            $recentProductions = Production::with('product')
                ->latest()
                ->take(5)
                ->get();
            
            // Sales stats
            $totalSales = Sale::whereMonth('sale_date', $month)
                ->whereYear('sale_date', $year)
                ->sum('total_amount');
            
            $recentSales = Sale::with('customer')
                ->latest()
                ->take(5)
                ->get();
            
            $totalTransactions = Sale::whereMonth('sale_date', $month)
                ->whereYear('sale_date', $year)
                ->count();
            
            $averageSale = $totalTransactions > 0 ? $totalSales / $totalTransactions : 0;
            
            // Top products
            $topProducts = DB::table('sale_items')
                ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
                ->join('products', 'sale_items.product_id', '=', 'products.id')
                ->whereMonth('sales.sale_date', $month)
                ->whereYear('sales.sale_date', $year)
                ->select('products.name', DB::raw('SUM(sale_items.quantity) as total_sold'))
                ->groupBy('products.id', 'products.name')
                ->orderBy('total_sold', 'desc')
                ->take(5)
                ->get();
            
            // Expense stats
            $totalExpenses = Expense::whereMonth('expense_date', $month)
                ->whereYear('expense_date', $year)
                ->sum('amount');
            
            // Low stock products
            $lowStockProducts = Product::where('stock', '<', 50)->get();
            
            // Sales chart (last 7 days)
            $salesChart = Sale::selectRaw('DATE(sale_date) as date, SUM(total_amount) as total')
                ->where('sale_date', '>=', now()->subDays(6))
                ->groupBy('date')
                ->orderBy('date')
                ->get();
            
            // Production chart (last 7 days)
            $productionChart = Production::selectRaw('DATE(production_date) as date, SUM(quantity) as total')
                ->where('production_date', '>=', now()->subDays(6))
                ->groupBy('date')
                ->orderBy('date')
                ->get();
            
            return response()->json([
                'success' => true,
                'data' => [
                    'summary' => [
                        'total_production' => $totalProduction,
                        'total_sales' => $totalSales,
                        'total_expenses' => $totalExpenses,
                        'net_profit' => $totalSales - $totalExpenses,
                        'total_transactions' => $totalTransactions,
                        'average_sale' => $averageSale,
                    ],
                    'recent_productions' => $recentProductions,
                    'recent_sales' => $recentSales,
                    'top_products' => $topProducts,
                    'low_stock_products' => $lowStockProducts,
                    'charts' => [
                        'sales' => $salesChart,
                        'production' => $productionChart,
                    ]
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get monthly comparison
     */
    public function monthlyComparison(Request $request)
    {
        $months = $request->input('months', 6); // Default 6 months
        
        $data = [];
        
        for ($i = $months - 1; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $month = $date->format('m');
            $year = $date->format('Y');
            
            $production = Production::whereMonth('production_date', $month)
                ->whereYear('production_date', $year)
                ->sum('quantity');
            
            $sales = Sale::whereMonth('sale_date', $month)
                ->whereYear('sale_date', $year)
                ->sum('total_amount');
            
            $expenses = Expense::whereMonth('expense_date', $month)
                ->whereYear('expense_date', $year)
                ->sum('amount');
            
            $data[] = [
                'month' => $date->format('M Y'),
                'production' => $production,
                'sales' => $sales,
                'expenses' => $expenses,
                'profit' => $sales - $expenses,
            ];
        }
        
        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
