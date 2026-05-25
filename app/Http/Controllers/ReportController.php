<?php

namespace App\Http\Controllers;

use App\Models\Production;
use App\Models\Sale;
use App\Models\Expense;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Barryvdh\DomPDF\Facade\Pdf;

class ReportController extends Controller
{
    public function index(Request $request)
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

        // Production Report
        $productions = Production::with('product')
            ->whereBetween('production_date', [$startDate, $endDate])
            ->when($request->filled('category'), function($q) use ($request) {
                return $q->where('category', $request->category);
            })
            ->when($request->filled('type'), function($q) use ($request) {
                return $q->where('type', $request->type);
            })
            ->when($request->filled('product_id'), function($q) use ($request) {
                return $q->where('product_id', $request->product_id);
            })
            ->get()
            ->groupBy('product_id')
            ->map(function ($items) {
                return [
                    'product_name' => $items->first()->product->name,
                    'total_quantity' => $items->sum('quantity'),
                    'rutin_count' => $items->where('type', 'rutin')->sum('quantity'),
                    'pesanan_count' => $items->where('type', 'pesanan')->sum('quantity'),
                ];
            });

        // Sales Report
        $sales = Sale::with('items.product')
            ->whereBetween('sale_date', [$startDate, $endDate])
            ->when($request->filled('product_id'), function($q) use ($request) {
                return $q->whereHas('items', function($query) use ($request) {
                    $query->where('product_id', $request->product_id);
                });
            })
            ->get();

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

        // Expense Report
        $expenses = Expense::whereBetween('expense_date', [$startDate, $endDate])
            ->when($request->filled('category'), function($q) use ($request) {
                return $q->where('category', $request->category);
            })
            ->when($request->filled('product_id'), function($q) use ($request) {
                return $q->whereHas('production', function($query) use ($request) {
                    $query->where('product_id', $request->product_id);
                });
            })
            ->get()
            ->groupBy('category')
            ->map(function ($items) {
                return [
                    'category' => $items->first()->category,
                    'total_amount' => $items->sum('amount'),
                    'count' => $items->count(),
                ];
            });

        // Summary
        $totalRevenue = $sales->sum('total_amount');
        $totalExpense = Expense::whereBetween('expense_date', [$startDate, $endDate])
            ->when($request->filled('category'), function($q) use ($request) {
                return $q->where('category', $request->category);
            })
            ->when($request->filled('product_id'), function($q) use ($request) {
                return $q->whereHas('production', function($query) use ($request) {
                    $query->where('product_id', $request->product_id);
                });
            })
            ->sum('amount');
        $netProfit = $totalRevenue - $totalExpense;

        $products = Product::all();

        return view('reports.index', compact(
            'productions',
            'salesByProduct',
            'expenses',
            'totalRevenue',
            'totalExpense',
            'netProfit',
            'totalProduction',
            'productionRutin',
            'productionPesanan',
            'totalTransactions',
            'products',
            'startDate',
            'endDate'
        ));
    }

    public function productionReport(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        $query = Production::with('product')
            ->whereBetween('production_date', [$startDate, $endDate]);

        // Filter by category
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        // Filter by type
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        // Filter by product
        if ($request->filled('product_id')) {
            $query->where('product_id', $request->product_id);
        }

        $productions = $query->orderBy('production_date', 'desc')->paginate(20)->withQueryString();

        // Statistics
        $allProductions = $query->get();
        $totalProduction = $allProductions->sum('quantity');
        $totalRutin = $allProductions->where('type', 'rutin')->sum('quantity');
        $totalPesanan = $allProductions->where('type', 'pesanan')->sum('quantity');
        $totalTransactions = $allProductions->count();

        // Production by category
        $productionByCategory = Production::selectRaw('category, 
            SUM(quantity) as total_quantity,
            SUM(CASE WHEN type = "rutin" THEN quantity ELSE 0 END) as rutin_quantity,
            SUM(CASE WHEN type = "pesanan" THEN quantity ELSE 0 END) as pesanan_quantity,
            COUNT(*) as total_count')
            ->whereBetween('production_date', [$startDate, $endDate])
            ->when($request->filled('category'), function($q) use ($request) {
                return $q->where('category', $request->category);
            })
            ->when($request->filled('type'), function($q) use ($request) {
                return $q->where('type', $request->type);
            })
            ->when($request->filled('product_id'), function($q) use ($request) {
                return $q->where('product_id', $request->product_id);
            })
            ->groupBy('category')
            ->get();

        $products = Product::all();

        return view('reports.production', compact(
            'productions', 
            'totalProduction', 
            'totalRutin',
            'totalPesanan',
            'totalTransactions',
            'productionByCategory',
            'products',
            'startDate', 
            'endDate'
        ));
    }

    public function salesReport(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        $sales = Sale::with(['customer', 'items.product'])
            ->whereBetween('sale_date', [$startDate, $endDate])
            ->orderBy('sale_date', 'desc')
            ->get();

        $totalRevenue = $sales->sum('total_amount');

        return view('reports.sales', compact('sales', 'totalRevenue', 'startDate', 'endDate'));
    }

    public function expenseReport(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        $expenses = Expense::with('production.product')
            ->whereBetween('expense_date', [$startDate, $endDate])
            ->orderBy('expense_date', 'desc')
            ->get();

        $totalExpense = $expenses->sum('amount');

        $byCategory = $expenses->groupBy('category')->map(function ($items) {
            return $items->sum('amount');
        });

        return view('reports.expense', compact('expenses', 'totalExpense', 'byCategory', 'startDate', 'endDate'));
    }

    public function integratedReport(Request $request)
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
        $productionByCategory = Production::selectRaw('category, 
            SUM(quantity) as total_quantity,
            SUM(CASE WHEN type = "rutin" THEN quantity ELSE 0 END) as rutin_quantity,
            SUM(CASE WHEN type = "pesanan" THEN quantity ELSE 0 END) as pesanan_quantity')
            ->whereBetween('production_date', [$startDate, $endDate])
            ->when($request->filled('category'), function($q) use ($request) {
                return $q->where('category', $request->category);
            })
            ->when($request->filled('type'), function($q) use ($request) {
                return $q->where('type', $request->type);
            })
            ->when($request->filled('product_id'), function($q) use ($request) {
                return $q->where('product_id', $request->product_id);
            })
            ->groupBy('category')
            ->get();

        $products = Product::all();

        return view('reports.integrated', compact(
            'productions',
            'expenses',
            'sales',
            'totalProduction',
            'totalSales',
            'totalExpenses',
            'netProfit',
            'totalTransactions',
            'productionByCategory',
            'products',
            'startDate',
            'endDate'
        ));
    }

    public function downloadIntegratedReport(Request $request)
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
}
