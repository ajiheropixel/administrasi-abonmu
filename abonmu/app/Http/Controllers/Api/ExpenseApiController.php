<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Expense;
use App\Models\Production;
use Illuminate\Http\Request;

class ExpenseApiController extends Controller
{
    /**
     * Get all expenses
     */
    public function index(Request $request)
    {
        $query = Expense::with('production.product');
        
        // Filter by category
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }
        
        // Filter by production
        if ($request->filled('production_id')) {
            $query->where('production_id', $request->production_id);
        }
        
        // Filter by date range
        if ($request->filled('start_date')) {
            $query->whereDate('expense_date', '>=', $request->start_date);
        }
        
        if ($request->filled('end_date')) {
            $query->whereDate('expense_date', '<=', $request->end_date);
        }
        
        // Pagination
        $perPage = $request->input('per_page', 15);
        $expenses = $query->latest('expense_date')->paginate($perPage);
        
        return response()->json([
            'success' => true,
            'data' => $expenses->items(),
            'pagination' => [
                'current_page' => $expenses->currentPage(),
                'last_page' => $expenses->lastPage(),
                'per_page' => $expenses->perPage(),
                'total' => $expenses->total(),
            ]
        ]);
    }

    /**
     * Get single expense
     */
    public function show($id)
    {
        $expense = Expense::with('production.product')->find($id);
        
        if (!$expense) {
            return response()->json([
                'success' => false,
                'message' => 'Data pengeluaran tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => $expense
        ]);
    }

    /**
     * Create new expense (Admin only)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'production_id' => 'nullable|exists:productions,id',
            'expense_date' => 'required|date',
            'category' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0',
            'description' => 'nullable|string'
        ]);

        $expense = Expense::create($validated);
        $expense->load('production.product');

        return response()->json([
            'success' => true,
            'message' => 'Pengeluaran berhasil ditambahkan',
            'data' => $expense
        ], 201);
    }

    /**
     * Update expense (Admin only)
     */
    public function update(Request $request, $id)
    {
        $expense = Expense::find($id);
        
        if (!$expense) {
            return response()->json([
                'success' => false,
                'message' => 'Data pengeluaran tidak ditemukan'
            ], 404);
        }
        
        $validated = $request->validate([
            'production_id' => 'nullable|exists:productions,id',
            'expense_date' => 'required|date',
            'category' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0',
            'description' => 'nullable|string'
        ]);

        $expense->update($validated);
        $expense->load('production.product');

        return response()->json([
            'success' => true,
            'message' => 'Pengeluaran berhasil diperbarui',
            'data' => $expense
        ]);
    }

    /**
     * Delete expense (Admin only)
     */
    public function destroy($id)
    {
        $expense = Expense::find($id);
        
        if (!$expense) {
            return response()->json([
                'success' => false,
                'message' => 'Data pengeluaran tidak ditemukan'
            ], 404);
        }
        
        $expense->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pengeluaran berhasil dihapus'
        ]);
    }

    /**
     * Get expense categories
     */
    public function categories()
    {
        $categories = Expense::select('category')
            ->distinct()
            ->orderBy('category')
            ->pluck('category');
        
        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    /**
     * Get expense statistics
     */
    public function statistics(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));
        
        $query = Expense::whereBetween('expense_date', [$startDate, $endDate]);
        
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }
        
        $expenses = $query->get();
        
        $stats = [
            'total_amount' => $expenses->sum('amount'),
            'total_transactions' => $expenses->count(),
            'by_category' => $expenses->groupBy('category')->map(function($items) {
                return [
                    'total_amount' => $items->sum('amount'),
                    'count' => $items->count(),
                ];
            })
        ];
        
        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }
}
