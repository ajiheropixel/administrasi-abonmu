@extends('layouts.app')

@section('title', 'Laporan Produksi')
@section('page-title', 'Laporan Produksi')

@section('content')
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Filter Laporan Produksi</h3>
    </div>
    <div class="p-6">
        <form method="GET" action="{{ route('reports.production') }}" class="grid grid-cols-1 md:grid-cols-5 gap-4">
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
            <div class="md:col-span-5 flex space-x-2">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm transition">
                    <i class="fas fa-filter mr-2"></i>Filter
                </button>
                <a href="{{ route('reports.production') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm transition">
                    <i class="fas fa-redo mr-2"></i>Reset
                </a>
                <button type="button" onclick="window.print()" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm transition ml-auto">
                    <i class="fas fa-print mr-2"></i>Cetak
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Summary Cards -->
<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Total Produksi</p>
        <h3 class="text-3xl font-bold text-blue-600">{{ number_format($totalProduction) }}</h3>
        <p class="text-xs text-gray-500 mt-1">bungkus</p>
    </div>
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Produksi Rutin</p>
        <h3 class="text-3xl font-bold text-green-600">{{ number_format($totalRutin) }}</h3>
        <p class="text-xs text-gray-500 mt-1">bungkus</p>
    </div>
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Produksi Pesanan</p>
        <h3 class="text-3xl font-bold text-orange-600">{{ number_format($totalPesanan) }}</h3>
        <p class="text-xs text-gray-500 mt-1">bungkus</p>
    </div>
    <div class="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-1">Jumlah Transaksi</p>
        <h3 class="text-3xl font-bold text-purple-600">{{ $totalTransactions }}</h3>
        <p class="text-xs text-gray-500 mt-1">transaksi</p>
    </div>
</div>

<!-- Production by Category -->
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
                        <td class="px-6 py-4 text-center text-gray-600">{{ $item->total_count }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endif

<!-- Detailed Production List -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200">
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
    
    @if($productions->hasPages())
    <div class="px-6 py-4 border-t border-gray-200">
        {{ $productions->appends(request()->query())->links() }}
    </div>
    @endif
</div>
@endsection
