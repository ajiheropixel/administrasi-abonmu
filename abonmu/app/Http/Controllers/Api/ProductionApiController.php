<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Production;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductionApiController extends Controller
{
    /**
     * Get all productions
     */
    public function index(Request $request)
    {
        $query = Production::with(['product', 'createdBy', 'updatedBy']);

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

        // Filter: today only
        if ($request->boolean('today')) {
            $query->whereDate('production_date', today());
        } else {
            // Filter by date range
            if ($request->filled('start_date')) {
                $query->whereDate('production_date', '>=', $request->start_date);
            }
            if ($request->filled('end_date')) {
                $query->whereDate('production_date', '<=', $request->end_date);
            }
        }

        // Search by product name or notes
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->whereHas('product', function ($pq) use ($search) {
                    $pq->where('name', 'like', '%' . $search . '%');
                })->orWhere('notes', 'like', '%' . $search . '%')
                  ->orWhere('category', 'like', '%' . $search . '%');
            });
        }

        // Pagination
        $perPage = $request->input('per_page', 15);
        $productions = $query->latest('production_date')->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $productions->items(),
            'pagination' => [
                'current_page' => $productions->currentPage(),
                'last_page'    => $productions->lastPage(),
                'per_page'     => $productions->perPage(),
                'total'        => $productions->total(),
            ]
        ]);
    }

    /**
     * Get single production
     */
    public function show($id)
    {
        $production = Production::with(['product', 'expenses', 'createdBy', 'updatedBy'])->find($id);

        if (!$production) {
            return response()->json([
                'success' => false,
                'message' => 'Data produksi tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => $production
        ]);
    }

    /**
     * Create new production (Admin only)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'product_id'      => 'required|exists:products,id',
            'production_date' => 'required|date',
            'quantity'        => 'required|integer|min:1',
            'type'            => 'required|in:rutin,pesanan',
            'category'        => 'required|string|max:255',
            'notes'           => 'nullable|string',
        ]);

        $validated['created_by'] = $request->user()->id;
        $validated['updated_by'] = $request->user()->id;

        $production = Production::create($validated);
        $production->load(['product', 'createdBy', 'updatedBy']);

        return response()->json([
            'success' => true,
            'message' => 'Data produksi berhasil ditambahkan',
            'data'    => $production
        ], 201);
    }

    /**
     * Update production (Admin only)
     */
    public function update(Request $request, $id)
    {
        $production = Production::find($id);

        if (!$production) {
            return response()->json([
                'success' => false,
                'message' => 'Data produksi tidak ditemukan'
            ], 404);
        }

        $validated = $request->validate([
            'product_id'      => 'required|exists:products,id',
            'production_date' => 'required|date',
            'quantity'        => 'required|integer|min:1',
            'type'            => 'required|in:rutin,pesanan',
            'category'        => 'required|string|max:255',
            'notes'           => 'nullable|string',
        ]);

        $validated['updated_by'] = $request->user()->id;

        // Adjust stock
        $production->product->decrement('stock', $production->quantity);
        $production->update($validated);
        $production->load(['product', 'createdBy', 'updatedBy']);
        $production->product->increment('stock', $validated['quantity']);

        return response()->json([
            'success' => true,
            'message' => 'Data produksi berhasil diperbarui',
            'data'    => $production
        ]);
    }

    /**
     * Delete production (Admin only)
     */
    public function destroy($id)
    {
        $production = Production::find($id);

        if (!$production) {
            return response()->json([
                'success' => false,
                'message' => 'Data produksi tidak ditemukan'
            ], 404);
        }

        $production->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data produksi berhasil dihapus'
        ]);
    }

    /**
     * Get production statistics
     */
    public function statistics(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate   = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        $query = Production::whereBetween('production_date', [$startDate, $endDate]);

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        $productions = $query->get();

        $stats = [
            'total_production'  => $productions->sum('quantity'),
            'total_rutin'       => $productions->where('type', 'rutin')->sum('quantity'),
            'total_pesanan'     => $productions->where('type', 'pesanan')->sum('quantity'),
            'total_transactions'=> $productions->count(),
            'by_category'       => $productions->groupBy('category')->map(function ($items) {
                return [
                    'total'   => $items->sum('quantity'),
                    'rutin'   => $items->where('type', 'rutin')->sum('quantity'),
                    'pesanan' => $items->where('type', 'pesanan')->sum('quantity'),
                ];
            }),
        ];

        return response()->json([
            'success' => true,
            'data'    => $stats
        ]);
    }
}
