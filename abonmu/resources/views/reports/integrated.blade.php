@extends('layouts.app')

@section('title', 'Laporan Terintegrasi')
@section('page-title', 'Laporan Terintegrasi')

@section('content')
<!-- Filter Section -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Filter Laporan Terintegrasi</h3>
    </div>
    <div class="p-6">
        <form method="GET" action="{{ route('reports.integrated') }}">
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tanggal Mulai</label>
                    <input type="date" name="start_date" value="{{ request('start_date', $startDate) }}"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tanggal Akhir</label>
                    <input type="date" name="end_date" value="{{ request('end_date', $endDate) }}"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Kategori</label>
                    <select name="category" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
                        <option value="">Semua Kategori</option>
                        <option value="Abon Sapi" {{ request('category') == 'Abon Sapi' ? 'selected' : '' }}>Abon Sapi</option>
                        <option value="Abon Ayam" {{ request('category') == 'Abon Ayam' ? 'selected' : '' }}>Abon Ayam</option>
                        <option value="Abon Ikan" {{ request('category') == 'Abon Ikan' ? 'selected' : '' }}>Abon Ikan</option>
                        <option value="Abon Lainnya" {{ request('category') == 'Abon Lainnya' ? 'selected' : '' }}>Abon Lainnya</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Jenis</label>
                    <select name="type" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
                        <option value="">Semua Jenis</option>
                        <option value="rutin" {{ request('type') == 'rutin' ? 'selected' : '' }}>Rutin</option>
                        <option value="pesanan" {{ request('type') == 'pesanan' ? 'selected' : '' }}>Pesanan</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Produk</label>
                    <select name="product_id" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
                        <option value="">Semua Produk</option>
                        @foreach($products as $product)
                            <option value="{{ $product->id }}" {{ request('product_id') == $product->id ? 'selected' : '' }}>
                                {{ $product->name }}
                            </option>
                        @endforeach
                    </select>
                </div>
            </div>
            
            <div class="flex gap-2">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg text-sm transition">
                    <i class="fas fa-filter mr-2"></i>Filter
                </button>
                <a href="{{ route('reports.integrated') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg text-sm transition">
                    <i class="fas fa-redo mr-2"></i>Reset
                </a>
                <a href="{{ route('reports.integrated.download', request()->query()) }}" 
                   class="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg transition text-sm"
                   target="_blank">
                    <i class="fas fa-download mr-2"></i>Unduh Laporan
                </a>
            </div>
        </form>
    </div>
</div>

<!-- Summary Cards - Produksi -->
<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Total Produksi</p>
        <h3 class="text-3xl font-bold text-blue-600">{{ number_format($totalProduction) }}</h3>
        <p class="text-xs text-gray-500 mt-1">bungkus</p>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Produksi Rutin</p>
        <h3 class="text-3xl font-bold text-green-600">{{ number_format($productions->where('type', 'rutin')->sum('quantity')) }}</h3>
        <p class="text-xs text-gray-500 mt-1">bungkus</p>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Produksi Pesanan</p>
        <h3 class="text-3xl font-bold text-orange-600">{{ number_format($productions->where('type', 'pesanan')->sum('quantity')) }}</h3>
        <p class="text-xs text-gray-500 mt-1">bungkus</p>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Total Transaksi</p>
        <h3 class="text-3xl font-bold text-purple-600">{{ number_format($productions->count()) }}</h3>
        <p class="text-xs text-gray-500 mt-1">transaksi</p>
    </div>
</div>

<!-- Production by Category Summary -->
@if($productionByCategory->count() > 0)
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Produksi per Kategori</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Total Produksi</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Rutin</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Pesanan</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Transaksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @foreach($productionByCategory as $item)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">
                            <span class="px-3 py-1 bg-purple-100 text-purple-700 rounded text-sm font-medium">
                                {{ $item->category ?? 'Tidak ada kategori' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-center font-bold text-gray-800">{{ number_format($item->total_quantity) }}</td>
                        <td class="px-6 py-4 text-center text-gray-600">{{ number_format($item->rutin_quantity) }}</td>
                        <td class="px-6 py-4 text-center text-gray-600">{{ number_format($item->pesanan_quantity) }}</td>
                        <td class="px-6 py-4 text-center text-gray-600">{{ number_format($item->total_count) }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endif

<!-- Production Details -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Detail Produksi</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Produk</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Jumlah</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Jenis</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Catatan</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($productions as $production)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 text-sm text-gray-800">{{ $production->production_date->format('d M Y') }}</td>
                        <td class="px-6 py-4 font-medium text-gray-800">{{ $production->product->name }}</td>
                        <td class="px-6 py-4">
                            <span class="px-2 py-1 bg-purple-100 text-purple-700 rounded text-xs font-medium">
                                {{ $production->category ?? '-' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-center font-semibold text-gray-800">
                            {{ number_format($production->quantity) }} {{ $production->product->unit }}
                        </td>
                        <td class="px-6 py-4 text-center">
                            <span class="px-3 py-1 rounded-full text-xs font-medium {{ $production->type == 'rutin' ? 'bg-blue-100 text-blue-700' : 'bg-orange-100 text-orange-700' }}">
                                {{ ucfirst($production->type) }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600">{{ $production->notes ?? '-' }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-6 py-8 text-center text-gray-500">Tidak ada data produksi</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Summary Cards - Keuangan -->
<div class="mb-6">
    <h3 class="text-lg font-semibold text-gray-800 mb-4">Ringkasan Keuangan</h3>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
            <p class="text-sm text-gray-600 mb-1">Total Penjualan</p>
            <h3 class="text-3xl font-bold text-green-600">Rp {{ number_format($totalSales, 0, ',', '.') }}</h3>
            <p class="text-xs text-gray-500 mt-1">{{ $totalTransactions }} transaksi</p>
        </div>

        <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
            <p class="text-sm text-gray-600 mb-1">Total Pengeluaran</p>
            <h3 class="text-3xl font-bold text-red-600">Rp {{ number_format($totalExpenses, 0, ',', '.') }}</h3>
            <p class="text-xs text-gray-500 mt-1">total biaya</p>
        </div>

        <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
            <p class="text-sm text-gray-600 mb-1">Laba Bersih</p>
            <h3 class="text-3xl font-bold {{ $netProfit >= 0 ? 'text-purple-600' : 'text-red-600' }}">
                Rp {{ number_format($netProfit, 0, ',', '.') }}
            </h3>
            <p class="text-xs text-gray-500 mt-1">periode ini</p>
        </div>
    </div>
</div>

<!-- Expense Details -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Detail Pengeluaran</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Produksi Terkait</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Jumlah</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Keterangan</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($expenses as $expense)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 text-sm text-gray-800">{{ $expense->expense_date->format('d M Y') }}</td>
                        <td class="px-6 py-4">
                            <span class="px-3 py-1 rounded-full text-xs font-medium bg-orange-100 text-orange-700">
                                {{ $expense->category }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600">
                            {{ $expense->production ? $expense->production->product->name . ' - ' . $expense->production->production_date->format('d M Y') : '-' }}
                        </td>
                        <td class="px-6 py-4 text-right font-semibold text-red-600">
                            Rp {{ number_format($expense->amount, 0, ',', '.') }}
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600">{{ $expense->description ?? '-' }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="px-6 py-8 text-center text-gray-500">Tidak ada data pengeluaran</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Sales Details -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Detail Penjualan</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Invoice</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pelanggan</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Item</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($sales as $sale)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 text-sm text-gray-800">{{ $sale->sale_date->format('d M Y') }}</td>
                        <td class="px-6 py-4 font-medium text-gray-800">{{ $sale->invoice_number }}</td>
                        <td class="px-6 py-4 text-sm text-gray-600">{{ $sale->customer ? $sale->customer->name : 'Umum' }}</td>
                        <td class="px-6 py-4 text-sm text-gray-600">
                            @foreach($sale->items as $item)
                                <div>{{ $item->product->name }} ({{ number_format($item->quantity) }} {{ $item->product->unit }})</div>
                            @endforeach
                        </td>
                        <td class="px-6 py-4 text-right font-semibold text-green-600">
                            Rp {{ number_format($sale->total_amount, 0, ',', '.') }}
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="px-6 py-8 text-center text-gray-500">Tidak ada data penjualan</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
