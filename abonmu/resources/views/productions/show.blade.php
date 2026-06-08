@extends('layouts.app')

@section('title', 'Detail Produksi')
@section('page-title', 'Detail Produksi')

@section('content')
<div class="max-w-4xl">
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
        <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h3 class="text-lg font-semibold text-gray-800">Informasi Produksi</h3>
            <a href="{{ route('productions.index') }}" class="text-blue-600 hover:text-blue-800">
                <i class="fas fa-arrow-left mr-2"></i>Kembali
            </a>
        </div>

        <div class="p-6 space-y-4">
            <div class="grid grid-cols-2 gap-4">
                <div>
                    <p class="text-sm text-gray-600">Tanggal Produksi</p>
                    <p class="font-semibold text-gray-800">{{ $production->production_date->format('d F Y') }}</p>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Jenis Produksi</p>
                    <span class="inline-block px-3 py-1 rounded-full text-sm font-medium {{ $production->type == 'rutin' ? 'bg-blue-100 text-blue-700' : 'bg-orange-100 text-orange-700' }}">
                        {{ ucfirst($production->type) }}
                    </span>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <p class="text-sm text-gray-600">Produk</p>
                    <div class="flex items-center gap-3 mt-1">
                        <div class="w-12 h-12 rounded-lg overflow-hidden bg-gray-100 border border-gray-200 flex-shrink-0">
                            @if($production->product?->image)
                                <img src="{{ asset('storage/' . $production->product->image) }}"
                                    alt="{{ $production->product->name }}"
                                    class="w-12 h-12 object-cover">
                            @else
                                <div class="w-12 h-12 flex items-center justify-center">
                                    <img src="{{ asset('images/logo-abonmu.png') }}" class="w-8 h-8 object-contain">
                                </div>
                            @endif
                        </div>
                        <p class="font-semibold text-gray-800">{{ $production->product->name }}</p>
                    </div>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Jumlah Produksi</p>
                    <p class="font-semibold text-gray-800">{{ number_format($production->quantity) }} {{ $production->product->unit }}</p>
                </div>
            </div>

            @if($production->notes)
                <div>
                    <p class="text-sm text-gray-600">Catatan</p>
                    <p class="text-gray-800">{{ $production->notes }}</p>
                </div>
            @endif
        </div>
    </div>

    <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-800">Karyawan yang Terlibat</h3>
        </div>
        <div class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                @foreach($production->employees as $employee)
                    <div class="border border-gray-200 rounded-lg p-4">
                        <p class="font-medium text-gray-800">{{ $employee->name }}</p>
                        <p class="text-sm text-gray-600 mt-1">Tarif Produksi: Rp {{ number_format($employee->production_rate, 0, ',', '.') }}</p>
                    </div>
                @endforeach
            </div>
        </div>
    </div>

    @if($production->expenses->count() > 0)
        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-800">Pengeluaran Terkait</h3>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50 border-b border-gray-200">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kategori</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jumlah</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Keterangan</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @foreach($production->expenses as $expense)
                            <tr>
                                <td class="px-6 py-4 text-sm text-gray-800">{{ $expense->expense_date->format('d M Y') }}</td>
                                <td class="px-6 py-4 text-sm text-gray-800">{{ $expense->category }}</td>
                                <td class="px-6 py-4 text-sm font-semibold text-gray-800">Rp {{ number_format($expense->amount, 0, ',', '.') }}</td>
                                <td class="px-6 py-4 text-sm text-gray-600">{{ $expense->description ?? '-' }}</td>
                            </tr>
                        @endforeach
                        <tr class="bg-gray-50 font-semibold">
                            <td colspan="2" class="px-6 py-4 text-right">Total Pengeluaran:</td>
                            <td colspan="2" class="px-6 py-4">Rp {{ number_format($production->expenses->sum('amount'), 0, ',', '.') }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    @endif
</div>
@endsection
