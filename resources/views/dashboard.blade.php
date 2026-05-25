@extends('layouts.app')

@section('title', 'Dashboard')
@section('page-title', 'Dashboard')

@section('content')
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
    <!-- Card Produksi Bulan Ini -->
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm text-gray-600 mb-1">Produksi Bulan Ini</p>
                <h3 class="text-3xl font-bold text-gray-800">{{ number_format($totalProduction) }}</h3>
                <p class="text-xs text-gray-500 mt-1">bungkus</p>
            </div>
            <div class="bg-blue-100 p-3 rounded-lg">
                <i class="fas fa-industry text-2xl text-blue-600"></i>
            </div>
        </div>
    </div>

    <!-- Card Penjualan Bulan Ini -->
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm text-gray-600 mb-1">Penjualan Bulan Ini</p>
                <h3 class="text-3xl font-bold text-gray-800">Rp {{ number_format($totalSales, 0, ',', '.') }}</h3>
                <p class="text-xs text-gray-500 mt-1">{{ $totalTransactions }} transaksi</p>
            </div>
            <div class="bg-green-100 p-3 rounded-lg">
                <i class="fas fa-shopping-cart text-2xl text-green-600"></i>
            </div>
        </div>
    </div>

    <!-- Card Pengeluaran Bulan Ini -->
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm text-gray-600 mb-1">Pengeluaran Bulan Ini</p>
                <h3 class="text-3xl font-bold text-gray-800">Rp {{ number_format($totalExpenses, 0, ',', '.') }}</h3>
                <p class="text-xs text-gray-500 mt-1">total biaya</p>
            </div>
            <div class="bg-red-100 p-3 rounded-lg">
                <i class="fas fa-receipt text-2xl text-red-600"></i>
            </div>
        </div>
    </div>

    <!-- Card Laba Bersih -->
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm text-gray-600 mb-1">Laba Bersih</p>
                <h3 class="text-3xl font-bold text-gray-800">Rp {{ number_format($totalSales - $totalExpenses, 0, ',', '.') }}</h3>
                <p class="text-xs text-gray-500 mt-1">bulan ini</p>
            </div>
            <div class="bg-purple-100 p-3 rounded-lg">
                <i class="fas fa-chart-line text-2xl text-purple-600"></i>
            </div>
        </div>
    </div>
</div>

<!-- Statistik Penjualan -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
    <!-- Rata-rata Penjualan -->
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-800">Statistik Penjualan</h3>
            <i class="fas fa-chart-pie text-blue-600"></i>
        </div>
        <div class="space-y-4">
            <div class="flex justify-between items-center">
                <span class="text-gray-600">Total Transaksi:</span>
                <span class="font-semibold text-gray-800">{{ $totalTransactions }}</span>
            </div>
            <div class="flex justify-between items-center">
                <span class="text-gray-600">Rata-rata per Transaksi:</span>
                <span class="font-semibold text-gray-800">Rp {{ number_format($averageSale, 0, ',', '.') }}</span>
            </div>
            <div class="flex justify-between items-center">
                <span class="text-gray-600">Total Pendapatan:</span>
                <span class="font-semibold text-green-600">Rp {{ number_format($totalSales, 0, ',', '.') }}</span>
            </div>
        </div>
    </div>

    <!-- Top 5 Produk Terlaris -->
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-800">Produk Terlaris</h3>
            <i class="fas fa-fire text-orange-600"></i>
        </div>
        @if($topProducts->count() > 0)
            <div class="space-y-3">
                @foreach($topProducts as $index => $product)
                    <div class="flex items-center justify-between">
                        <div class="flex items-center">
                            <span class="w-6 h-6 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center text-xs font-semibold mr-3">
                                {{ $index + 1 }}
                            </span>
                            <span class="text-gray-800">{{ $product->name }}</span>
                        </div>
                        <span class="font-semibold text-gray-800">{{ number_format($product->total_sold) }}</span>
                    </div>
                @endforeach
            </div>
        @else
            <p class="text-gray-500 text-center py-4">Belum ada data penjualan</p>
        @endif
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
    <!-- Produksi Terbaru -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-800">Produksi Terbaru</h3>
        </div>
        <div class="p-6">
            @if($recentProductions->count() > 0)
                <div class="space-y-3">
                    @foreach($recentProductions as $production)
                        <div class="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                            <div>
                                <p class="font-medium text-gray-800">{{ $production->product->name }}</p>
                                <p class="text-sm text-gray-500">{{ $production->production_date->format('d M Y') }}</p>
                            </div>
                            <div class="text-right">
                                <p class="font-semibold text-gray-800">{{ number_format($production->quantity) }} {{ $production->product->unit }}</p>
                                <span class="text-xs px-2 py-1 rounded {{ $production->type == 'rutin' ? 'bg-blue-100 text-blue-700' : 'bg-orange-100 text-orange-700' }}">
                                    {{ ucfirst($production->type) }}
                                </span>
                            </div>
                        </div>
                    @endforeach
                </div>
            @else
                <p class="text-gray-500 text-center py-4">Belum ada data produksi</p>
            @endif
        </div>
    </div>

    <!-- Penjualan Terbaru -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-800">Penjualan Terbaru</h3>
        </div>
        <div class="p-6">
            @if($recentSales->count() > 0)
                <div class="space-y-3">
                    @foreach($recentSales as $sale)
                        <div class="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                            <div>
                                <p class="font-medium text-gray-800">{{ $sale->invoice_number }}</p>
                                <p class="text-sm text-gray-500">{{ $sale->customer ? $sale->customer->name : 'Umum' }}</p>
                            </div>
                            <div class="text-right">
                                <p class="font-semibold text-gray-800">Rp {{ number_format($sale->total_amount, 0, ',', '.') }}</p>
                                <p class="text-xs text-gray-500">{{ $sale->sale_date->format('d M Y') }}</p>
                            </div>
                        </div>
                    @endforeach
                </div>
            @else
                <p class="text-gray-500 text-center py-4">Belum ada data penjualan</p>
            @endif
        </div>
    </div>
</div>

<!-- Stok Menipis -->
@if($lowStockProducts->count() > 0)
<div class="bg-white rounded-lg shadow-sm border border-gray-200">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">
            <i class="fas fa-exclamation-triangle text-yellow-500 mr-2"></i>
            Stok Menipis
        </h3>
    </div>
    <div class="p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            @foreach($lowStockProducts as $product)
                <div class="border border-yellow-200 bg-yellow-50 rounded-lg p-4">
                    <p class="font-medium text-gray-800">{{ $product->name }}</p>
                    <p class="text-2xl font-bold text-yellow-600 mt-2">{{ $product->stock }} {{ $product->unit }}</p>
                    <p class="text-xs text-gray-600 mt-1">Stok tersisa</p>
                </div>
            @endforeach
        </div>
    </div>
</div>
@endif
@endsection
