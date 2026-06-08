<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use App\Models\Customer;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SaleApiController extends Controller
{
    /**
     * Get all sales
     */
    public function index(Request $request)
    {
        $query = Sale::with(['customer', 'items.product']);
        
        // Filter by customer
        if ($request->filled('customer_id')) {
            $query->where('customer_id', $request->customer_id);
        }
        
        // Filter by type
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }
        
        // Filter by date range
        if ($request->filled('start_date')) {
            $query->whereDate('sale_date', '>=', $request->start_date);
        }
        
        if ($request->filled('end_date')) {
            $query->whereDate('sale_date', '<=', $request->end_date);
        }
        
        // Search by invoice number
        if ($request->filled('search')) {
            $query->where('invoice_number', 'like', '%' . $request->search . '%');
        }
        
        // Pagination
        $perPage = $request->input('per_page', 15);
        $sales = $query->latest('sale_date')->paginate($perPage);
        
        return response()->json([
            'success' => true,
            'data' => $sales->items(),
            'pagination' => [
                'current_page' => $sales->currentPage(),
                'last_page' => $sales->lastPage(),
                'per_page' => $sales->perPage(),
                'total' => $sales->total(),
            ]
        ]);
    }

    /**
     * Get single sale
     */
    public function show($id)
    {
        $sale = Sale::with(['customer', 'items.product'])->find($id);
        
        if (!$sale) {
            return response()->json([
                'success' => false,
                'message' => 'Data penjualan tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => $sale
        ]);
    }

    /**
     * Create new sale (Admin only)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'customer_id' => 'nullable|exists:customers,id',
            'sale_date' => 'required|date',
            'type' => 'required|in:ecer,pesanan',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.price' => 'required|numeric|min:0'
        ]);

        try {
            DB::beginTransaction();
            
            $totalAmount = 0;
            
            // Check stock availability
            foreach ($validated['items'] as $item) {
                $product = Product::find($item['product_id']);
                if ($product->stock < $item['quantity']) {
                    return response()->json([
                        'success' => false,
                        'message' => "Stok {$product->name} tidak mencukupi. Stok tersedia: {$product->stock}"
                    ], 400);
                }
                $totalAmount += $item['quantity'] * $item['price'];
            }

            $sale = Sale::create([
                'customer_id' => $validated['customer_id'],
                'sale_date' => $validated['sale_date'],
                'type' => $validated['type'],
                'total_amount' => $totalAmount,
                'notes' => $validated['notes'] ?? null
            ]);

            foreach ($validated['items'] as $item) {
                $sale->items()->create([
                    'product_id' => $item['product_id'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                    'subtotal' => $item['quantity'] * $item['price']
                ]);
            }
            
            DB::commit();
            
            $sale->load(['customer', 'items.product']);

            return response()->json([
                'success' => true,
                'message' => 'Penjualan berhasil ditambahkan',
                'data' => $sale
            ], 201);
            
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete sale (Admin only)
     */
    public function destroy($id)
    {
        $sale = Sale::find($id);
        
        if (!$sale) {
            return response()->json([
                'success' => false,
                'message' => 'Data penjualan tidak ditemukan'
            ], 404);
        }
        
        $sale->delete();

        return response()->json([
            'success' => true,
            'message' => 'Penjualan berhasil dihapus'
        ]);
    }

    /**
     * Get sale statistics
     */
    public function statistics(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));
        
        $query = Sale::whereBetween('sale_date', [$startDate, $endDate]);
        
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }
        
        $sales = $query->get();
        
        $stats = [
            'total_revenue' => $sales->sum('total_amount'),
            'total_transactions' => $sales->count(),
            'average_transaction' => $sales->count() > 0 ? $sales->sum('total_amount') / $sales->count() : 0,
            'by_type' => [
                'ecer' => $sales->where('type', 'ecer')->sum('total_amount'),
                'pesanan' => $sales->where('type', 'pesanan')->sum('total_amount'),
            ]
        ];
        
        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Get invoice data
     */
    public function invoice($id)
    {
        $sale = Sale::with(['customer', 'items.product'])->find($id);
        
        if (!$sale) {
            return response()->json([
                'success' => false,
                'message' => 'Data penjualan tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => $sale
        ]);
    }
}
