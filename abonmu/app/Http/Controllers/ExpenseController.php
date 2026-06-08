<?php

namespace App\Http\Controllers;

use App\Models\Expense;
use App\Models\Production;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
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
        
        $expenses = $query->latest()->paginate(10)->withQueryString();
        
        // Get unique categories from database
        $categories = Expense::select('category')
            ->distinct()
            ->orderBy('category')
            ->pluck('category');
        
        // Get all productions for filter (latest 50)
        $productions = Production::with('product')
            ->latest()
            ->limit(50)
            ->get();
        
        return view('expenses.index', compact('expenses', 'categories', 'productions'));
    }

    public function create()
    {
        $productions = Production::with('product')->latest()->get();
        return view('expenses.create', compact('productions'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'production_id' => 'nullable|exists:productions,id',
            'expense_date' => 'required|date',
            'category' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0',
            'description' => 'nullable|string'
        ]);

        Expense::create($validated);

        return redirect()->route('expenses.index')->with('success', 'Pengeluaran berhasil ditambahkan');
    }

    public function edit(Expense $expense)
    {
        $productions = Production::with('product')->latest()->get();
        return view('expenses.edit', compact('expense', 'productions'));
    }

    public function update(Request $request, Expense $expense)
    {
        $validated = $request->validate([
            'production_id' => 'nullable|exists:productions,id',
            'expense_date' => 'required|date',
            'category' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0',
            'description' => 'nullable|string'
        ]);

        $expense->update($validated);

        return redirect()->route('expenses.index')->with('success', 'Pengeluaran berhasil diperbarui');
    }

    public function destroy(Expense $expense)
    {
        $expense->delete();
        return redirect()->route('expenses.index')->with('success', 'Pengeluaran berhasil dihapus');
    }
}
