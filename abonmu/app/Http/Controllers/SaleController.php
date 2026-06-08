<?php

namespace App\Http\Controllers;

use Barryvdh\DomPDF\Facade\Pdf;
use App\Models\Sale;
use App\Models\Customer;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SaleController extends Controller
{
    public function index()
    {
        $sales = Sale::with('customer')->latest()->paginate(10);
        return view('sales.index', compact('sales'));
    }

    public function create()
    {
        $customers = Customer::all();
        $products = Product::where('stock', '>', 0)->get();
        return view('sales.create', compact('customers', 'products'));
    }

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

        DB::transaction(function () use ($validated) {
            $totalAmount = 0;
            
            foreach ($validated['items'] as $item) {
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
        });

        return redirect()->route('sales.index')->with('success', 'Penjualan berhasil ditambahkan');
    }

    public function show(Sale $sale)
    {
        $sale->load(['customer', 'items.product']);
        return view('sales.show', compact('sale'));
    }

    public function invoice(Sale $sale)
    {
        // Preview faktur di browser (dengan tombol cetak & tutup)
        $sale->load(['customer', 'items.product']);
        return view('sales.invoice', compact('sale'));
    }

    public function downloadInvoice(Sale $sale)
    {
        // Download PDF (tanpa tombol, bersih untuk PDF)
        $sale->load(['customer', 'items.product']);

        $pdf = Pdf::loadView('sales.invoice-pdf', compact('sale'));

        return $pdf->download('Faktur-'.$sale->invoice_number.'.pdf');
    }

    public function destroy(Sale $sale)
    {
        $sale->delete();
        return redirect()->route('sales.index')->with('success', 'Penjualan berhasil dihapus');
    }
}