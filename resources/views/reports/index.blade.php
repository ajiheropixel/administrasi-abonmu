@extends('layouts.app')

@section('title', 'Laporan Lengkap')
@section('page-title', 'Laporan Lengkap')

@section('content')
<!-- Filter Section -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Filter Periode</h3>
    </div>
    <div class="p-6">
        <form method="GET" action="{{ route('reports.index') }}">
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tanggal Mulai</label>
                    <input type="date" name="start_date" value="{{ $startDate }}"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tanggal Akhir</label>
                    <input type="date" name="end_date" value="{{ $endDate }}"
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
                <a href="{{ route('reports.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg text-sm transition">
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
        <h3 class="text-3xl font-bold text-green-600">{{ number_format($productionRutin) }}</h3>
        <p class="text-xs text-gray-500 mt-1">bungkus</p>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Produksi Pesanan</p>
        <h3 class="text-3xl font-bold text-orange-600">{{ number_format($productionPesanan) }}</h3>
        <p class="text-xs text-gray-500 mt-1">bungkus</p>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Total Transaksi</p>
        <h3 class="text-3xl font-bold text-purple-600">{{ number_format($totalTransactions) }}</h3>
        <p class="text-xs text-gray-500 mt-1">transaksi</p>
    </div>
</div>

<!-- Production by Category Summary -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Ringkasan Produksi per Produk</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Produk</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Total Produksi</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Produksi Rutin</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Produksi Pesanan</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($productions as $production)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 font-medium text-gray-800">{{ $production['product_name'] }}</td>
                        <td class="px-6 py-4 text-center font-semibold text-gray-800">{{ number_format($production['total_quantity']) }}</td>
                        <td class="px-6 py-4 text-center text-gray-600">{{ number_format($production['rutin_count']) }}</td>
                        <td class="px-6 py-4 text-center text-gray-600">{{ number_format($production['pesanan_count']) }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="px-6 py-8 text-center text-gray-500">Tidak ada data produksi</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Summary Cards - Keuangan -->
<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Total Penjualan</p>
        <h3 class="text-3xl font-bold text-green-600">Rp {{ number_format($totalRevenue, 0, ',', '.') }}</h3>
        <p class="text-xs text-gray-500 mt-1">pendapatan</p>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Total Pengeluaran</p>
        <h3 class="text-3xl font-bold text-red-600">Rp {{ number_format($totalExpense, 0, ',', '.') }}</h3>
        <p class="text-xs text-gray-500 mt-1">biaya produksi</p>
    </div>

    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Laba Bersih</p>
        <h3 class="text-3xl font-bold {{ $netProfit >= 0 ? 'text-purple-600' : 'text-red-600' }}">
            Rp {{ number_format($netProfit, 0, ',', '.') }}
        </h3>
        <p class="text-xs text-gray-500 mt-1">periode ini</p>
    </div>
</div>

<!-- Sales Summary -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Ringkasan Penjualan per Produk</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Produk</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Total Terjual</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total Pendapatan</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($salesByProduct as $sale)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 font-medium text-gray-800">{{ $sale->name }}</td>
                        <td class="px-6 py-4 text-center font-semibold text-gray-800">{{ number_format($sale->total_quantity) }}</td>
                        <td class="px-6 py-4 text-right font-semibold text-green-600">Rp {{ number_format($sale->total_amount, 0, ',', '.') }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="3" class="px-6 py-8 text-center text-gray-500">Tidak ada data penjualan</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<!-- Expense Summary -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Ringkasan Pengeluaran per Kategori</h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Jumlah Transaksi</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total Pengeluaran</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($expenses as $expense)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 font-medium text-gray-800">{{ $expense['category'] }}</td>
                        <td class="px-6 py-4 text-center text-gray-600">{{ $expense['count'] }}</td>
                        <td class="px-6 py-4 text-right font-semibold text-red-600">Rp {{ number_format($expense['total_amount'], 0, ',', '.') }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="3" class="px-6 py-8 text-center text-gray-500">Tidak ada data pengeluaran</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
