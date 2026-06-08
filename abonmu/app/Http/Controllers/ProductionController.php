<?php

namespace App\Http\Controllers;

use App\Models\Production;
use App\Models\Product;
use App\Models\Employee;
use Illuminate\Http\Request;

class ProductionController extends Controller
{
    public function index(Request $request)
    {
        $query = Production::with(['product', 'createdBy']);

        // Filter by category
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        // Filter by type
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        // Filter: today only
        if ($request->boolean('today')) {
            $query->whereDate('production_date', today());
        } else {
            if ($request->filled('start_date')) {
                $query->whereDate('production_date', '>=', $request->start_date);
            }
            if ($request->filled('end_date')) {
                $query->whereDate('production_date', '<=', $request->end_date);
            }
        }

        // Search by product name, category, or notes
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->whereHas('product', fn($pq) => $pq->where('name', 'like', "%$search%"))
                  ->orWhere('category', 'like', "%$search%")
                  ->orWhere('notes', 'like', "%$search%");
            });
        }

        $productions = $query->latest('production_date')->paginate(10)->withQueryString();

        return view('productions.index', compact('productions'));
    }

    public function create()
    {
        $products = Product::all();
        return view('productions.create', compact('products'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'production_date' => 'required|date',
            'quantity' => 'required|integer|min:1',
            'type' => 'required|in:rutin,pesanan',
            'category' => 'required|string|max:255',
            'notes' => 'nullable|string'
        ]);

        $production = Production::create($validated);

        return redirect()->route('productions.index')->with('success', 'Data produksi berhasil ditambahkan');
    }

    public function show(Production $production)
    {
        $production->load(['product', 'employees', 'expenses']);
        return view('productions.show', compact('production'));
    }

    public function destroy(Production $production)
    {
        $production->delete();
        return redirect()->route('productions.index')->with('success', 'Data produksi berhasil dihapus');
    }
}
