@extends('layouts.app')

@section('title', 'Data Produksi')
@section('page-title', 'Data Produksi')

@section('content')
<div class="bg-white rounded-lg shadow-sm border border-gray-200">
    <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
        <h3 class="text-lg font-semibold text-gray-800">Daftar Produksi</h3>
        <a href="{{ route('productions.create') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition">
            <i class="fas fa-plus mr-2"></i>Tambah Produksi
        </a>
    </div>

    <!-- Filter -->
    <div class="px-6 py-4 bg-gray-50 border-b border-gray-200">
        <form method="GET" action="{{ route('productions.index') }}" class="space-y-3">
            {{-- Search --}}
            <div class="relative">
                <span class="absolute inset-y-0 left-3 flex items-center text-gray-400">
                    <i class="fas fa-search text-sm"></i>
                </span>
                <input type="text" name="search" value="{{ request('search') }}"
                    placeholder="Cari nama produk, kategori, catatan..."
                    class="w-full pl-9 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
            </div>
            {{-- Filter grid --}}
            <div class="grid grid-cols-1 md:grid-cols-5 gap-3">
                <div>
                    <label class="block text-xs font-medium text-gray-600 mb-1">Kategori</label>
                    <select name="category" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
                        <option value="">Semua Kategori</option>
                        <option value="Abon Sapi" {{ request('category') == 'Abon Sapi' ? 'selected' : '' }}>Abon Sapi</option>
                        <option value="Abon Ayam" {{ request('category') == 'Abon Ayam' ? 'selected' : '' }}>Abon Ayam</option>
                        <option value="Abon Ikan" {{ request('category') == 'Abon Ikan' ? 'selected' : '' }}>Abon Ikan</option>
                        <option value="Abon Lainnya" {{ request('category') == 'Abon Lainnya' ? 'selected' : '' }}>Abon Lainnya</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-medium text-gray-600 mb-1">Jenis</label>
                    <select name="type" class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500">
                        <option value="">Semua Jenis</option>
                        <option value="rutin" {{ request('type') == 'rutin' ? 'selected' : '' }}>Rutin</option>
                        <option value="pesanan" {{ request('type') == 'pesanan' ? 'selected' : '' }}>Pesanan</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-medium text-gray-600 mb-1">Tanggal Mulai</label>
                    <input type="date" name="start_date"
                        value="{{ request('today') ? '' : request('start_date') }}"
                        {{ request('today') ? 'disabled' : '' }}
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed">
                </div>
                <div>
                    <label class="block text-xs font-medium text-gray-600 mb-1">Tanggal Akhir</label>
                    <input type="date" name="end_date"
                        value="{{ request('today') ? '' : request('end_date') }}"
                        {{ request('today') ? 'disabled' : '' }}
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed">
                </div>
                <div class="flex flex-col justify-end">
                    <label class="block text-xs font-medium text-gray-600 mb-1">Hari Ini</label>
                    <label class="flex items-center gap-2 px-3 py-2 border rounded-lg cursor-pointer text-sm
                        {{ request('today') ? 'bg-blue-50 border-blue-400 text-blue-700' : 'border-gray-300 text-gray-700' }}">
                        <input type="checkbox" name="today" value="1" onchange="this.form.submit()"
                            {{ request('today') ? 'checked' : '' }} class="accent-blue-600">
                        Hari Ini Saja
                    </label>
                </div>
            </div>
            {{-- Tombol --}}
            <div class="flex items-center space-x-2">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm transition">
                    <i class="fas fa-filter mr-2"></i>Filter
                </button>
                <a href="{{ route('productions.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm transition">
                    <i class="fas fa-redo mr-2"></i>Reset
                </a>
                @if(request('today'))
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-700">
                        <i class="fas fa-calendar-day mr-1"></i>Menampilkan produksi hari ini
                    </span>
                @endif
            </div>
        </form>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Produk</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jumlah</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jenis</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Dibuat Oleh</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($productions as $production)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 text-sm text-gray-800">
                            {{ $production->production_date->format('d M Y') }}
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex items-center gap-3">
                                <div class="w-9 h-9 rounded-lg bg-gray-50 border border-gray-200 flex items-center justify-center flex-shrink-0 overflow-hidden">
                                    @if($production->product?->image)
                                        <img src="{{ asset('storage/' . $production->product->image) }}"
                                            alt="{{ $production->product->name }}"
                                            class="w-9 h-9 object-cover">
                                    @else
                                        <img src="{{ asset('images/logo-abonmu.png') }}" alt="logo" class="w-7 h-7 object-contain">
                                    @endif
                                </div>
                                <p class="font-medium text-gray-800">{{ $production->product->name }}</p>
                            </div>
                        </td>
                        <td class="px-6 py-4 text-sm font-semibold text-gray-800">
                            {{ number_format($production->quantity) }} {{ $production->product->unit }}
                        </td>
                        <td class="px-6 py-4">
                            <span class="px-3 py-1 rounded-full text-xs font-medium {{ $production->type == 'rutin' ? 'bg-blue-100 text-blue-700' : 'bg-orange-100 text-orange-700' }}">
                                {{ ucfirst($production->type) }}
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <span class="px-2 py-1 bg-purple-100 text-purple-700 rounded text-xs font-medium">
                                {{ $production->category ?? '-' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600">
                            @if($production->createdBy)
                                <div class="flex items-center gap-1">
                                    <i class="fas fa-user-circle text-gray-400 text-xs"></i>
                                    <span>{{ $production->createdBy->name }}</span>
                                </div>
                            @else
                                <span class="text-gray-400">-</span>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex space-x-2">
                                <a href="{{ route('productions.show', $production) }}" class="text-green-600 hover:text-green-800">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <form action="{{ route('productions.destroy', $production) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-600 hover:text-red-800">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="px-6 py-8 text-center text-gray-500">
                            Belum ada data produksi
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="px-6 py-4 border-t border-gray-200">
        {{ $productions->links() }}
    </div>
</div>
@endsection
