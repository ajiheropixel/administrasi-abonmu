<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Production;
use App\Models\Sale;
use App\Models\Expense;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Barryvdh\DomPDF\Facade\Pdf;

class ReportApiController extends Controller
{
    /**
     * Get integrated report data
     */
    public function integrated(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        // Build production query with filters
        $productionQuery = Production::with('product')
            ->whereBetween('production_date', [$startDate, $endDate]);

        if ($request->filled('category')) {
            $productionQuery->where('category', $request->category);
        }

        if ($request->filled('type')) {
            $productionQuery->where('type', $request->type);
        }

        if ($request->filled('product_id')) {
            $productionQuery->where('product_id', $request->product_id);
        }

        $productions = $productionQuery->orderBy('production_date', 'desc')->get();

        // Build expense query with filters
        $expenseQuery = Expense::with('production.product')
            ->whereBetween('expense_date', [$startDate, $endDate]);

        if ($request->filled('category')) {
            $expenseQuery->where('category', $request->category);
        }

        if ($request->filled('product_id')) {
            $expenseQuery->whereHas('production', function($q) use ($request) {
                $q->where('product_id', $request->product_id);
            });
        }

        $expenses = $expenseQuery->orderBy('expense_date', 'desc')->get();

        // Build sales query with filters
        $salesQuery = Sale::with(['customer', 'items.product'])
            ->whereBetween('sale_date', [$startDate, $endDate]);

        if ($request->filled('product_id')) {
            $salesQuery->whereHas('items', function($q) use ($request) {
                $q->where('product_id', $request->product_id);
            });
        }

        $sales = $salesQuery->orderBy('sale_date', 'desc')->get();

        // Calculate totals
        $totalProduction = $productions->sum('quantity');
        $totalSales = $sales->sum('total_amount');
        $totalExpenses = $expenses->sum('amount');
        $netProfit = $totalSales - $totalExpenses;
        $totalTransactions = $sales->count();

        // Production by category
        $productionByCategory = $productions->groupBy('category')->map(function($items) {
            return [
                'total' => $items->sum('quantity'),
                'rutin' => $items->where('type', 'rutin')->sum('quantity'),
                'pesanan' => $items->where('type', 'pesanan')->sum('quantity'),
            ];
        });

        // Sales by product
        $salesByProduct = DB::table('sale_items')
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->join('products', 'sale_items.product_id', '=', 'products.id')
            ->whereBetween('sales.sale_date', [$startDate, $endDate])
            ->when($request->filled('product_id'), function($q) use ($request) {
                return $q->where('sale_items.product_id', $request->product_id);
            })
            ->select('products.name', DB::raw('SUM(sale_items.quantity) as total_quantity'), DB::raw('SUM(sale_items.subtotal) as total_amount'))
            ->groupBy('products.id', 'products.name')
            ->get();

        // Expenses by category
        $expensesByCategory = $expenses->groupBy('category')->map(function($items) {
            return [
                'total_amount' => $items->sum('amount'),
                'count' => $items->count(),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'summary' => [
                    'total_production' => $totalProduction,
                    'total_sales' => $totalSales,
                    'total_expenses' => $totalExpenses,
                    'net_profit' => $netProfit,
                    'total_transactions' => $totalTransactions,
                ],
                'productions' => $productions,
                'expenses' => $expenses,
                'sales' => $sales,
                'production_by_category' => $productionByCategory,
                'sales_by_product' => $salesByProduct,
                'expenses_by_category' => $expensesByCategory,
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ]
            ]
        ]);
    }

    /**
     * Download integrated report as PDF
     */
    public function downloadPdf(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        // Build production query with filters
        $productionQuery = Production::with('product')
            ->whereBetween('production_date', [$startDate, $endDate]);

        if ($request->filled('category')) {
            $productionQuery->where('category', $request->category);
        }

        if ($request->filled('type')) {
            $productionQuery->where('type', $request->type);
        }

        if ($request->filled('product_id')) {
            $productionQuery->where('product_id', $request->product_id);
        }

        $allProductions = $productionQuery->get();
        
        // Calculate production stats
        $totalProduction = $allProductions->sum('quantity');
        $productionRutin = $allProductions->where('type', 'rutin')->sum('quantity');
        $productionPesanan = $allProductions->where('type', 'pesanan')->sum('quantity');
        $totalTransactions = $allProductions->count();

        // Production by product
        $productionsByProduct = $allProductions->groupBy('product_id')
            ->map(function ($items) {
                return [
                    'product_name' => $items->first()->product->name,
                    'total_quantity' => $items->sum('quantity'),
                    'rutin_count' => $items->where('type', 'rutin')->sum('quantity'),
                    'pesanan_count' => $items->where('type', 'pesanan')->sum('quantity'),
                ];
            });

        // Build sales query with filters
        $salesQuery = Sale::with(['customer', 'items.product'])
            ->whereBetween('sale_date', [$startDate, $endDate]);

        if ($request->filled('product_id')) {
            $salesQuery->whereHas('items', function($q) use ($request) {
                $q->where('product_id', $request->product_id);
            });
        }

        $sales = $salesQuery->get();

        // Sales by product
        $salesByProduct = DB::table('sale_items')
            ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
            ->join('products', 'sale_items.product_id', '=', 'products.id')
            ->whereBetween('sales.sale_date', [$startDate, $endDate])
            ->when($request->filled('product_id'), function($q) use ($request) {
                return $q->where('sale_items.product_id', $request->product_id);
            })
            ->select('products.name', DB::raw('SUM(sale_items.quantity) as total_quantity'), DB::raw('SUM(sale_items.subtotal) as total_amount'))
            ->groupBy('products.id', 'products.name')
            ->get();

        // Build expense query with filters
        $expenseQuery = Expense::with('production.product')
            ->whereBetween('expense_date', [$startDate, $endDate]);

        if ($request->filled('category')) {
            $expenseQuery->where('category', $request->category);
        }

        if ($request->filled('product_id')) {
            $expenseQuery->whereHas('production', function($q) use ($request) {
                $q->where('product_id', $request->product_id);
            });
        }

        $expenses = $expenseQuery->get();

        // Expenses by category
        $expensesByCategory = $expenses->groupBy('category')
            ->map(function ($items) {
                return [
                    'category' => $items->first()->category,
                    'total_amount' => $items->sum('amount'),
                    'count' => $items->count(),
                ];
            });

        // Calculate totals
        $totalSales = $sales->sum('total_amount');
        $totalExpenses = $expenses->sum('amount');
        $netProfit = $totalSales - $totalExpenses;

        $products = Product::all();

        // Generate PDF
        $pdf = Pdf::loadView('reports.integrated-pdf', compact(
            'allProductions',
            'productionsByProduct',
            'salesByProduct',
            'expensesByCategory',
            'sales',
            'expenses',
            'totalProduction',
            'productionRutin',
            'productionPesanan',
            'totalTransactions',
            'totalSales',
            'totalExpenses',
            'netProfit',
            'products',
            'startDate',
            'endDate'
        ));

        $pdf->setPaper('a4', 'portrait');

        $filename = 'Laporan_' . $startDate . '_' . $endDate . '.pdf';

        return $pdf->download($filename);
    }

    /**
     * Get production report
     */
    public function production(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        $query = Production::with('product')
            ->whereBetween('production_date', [$startDate, $endDate]);

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('product_id')) {
            $query->where('product_id', $request->product_id);
        }

        $productions = $query->orderBy('production_date', 'desc')->get();

        $stats = [
            'total_production' => $productions->sum('quantity'),
            'total_rutin' => $productions->where('type', 'rutin')->sum('quantity'),
            'total_pesanan' => $productions->where('type', 'pesanan')->sum('quantity'),
            'total_transactions' => $productions->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'productions' => $productions,
                'statistics' => $stats,
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ]
            ]
        ]);
    }

    /**
     * Get sales report
     */
    public function sales(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        $sales = Sale::with(['customer', 'items.product'])
            ->whereBetween('sale_date', [$startDate, $endDate])
            ->orderBy('sale_date', 'desc')
            ->get();

        $stats = [
            'total_revenue' => $sales->sum('total_amount'),
            'total_transactions' => $sales->count(),
            'average_transaction' => $sales->count() > 0 ? $sales->sum('total_amount') / $sales->count() : 0,
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'sales' => $sales,
                'statistics' => $stats,
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ]
            ]
        ]);
    }

    /**
     * Get expense report
     */
    public function expenses(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        $expenses = Expense::with('production.product')
            ->whereBetween('expense_date', [$startDate, $endDate])
            ->orderBy('expense_date', 'desc')
            ->get();

        $byCategory = $expenses->groupBy('category')->map(function ($items) {
            return [
                'total_amount' => $items->sum('amount'),
                'count' => $items->count(),
            ];
        });

        $stats = [
            'total_expense' => $expenses->sum('amount'),
            'total_transactions' => $expenses->count(),
            'by_category' => $byCategory,
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'expenses' => $expenses,
                'statistics' => $stats,
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ]
            ]
        ]);
    }
}
