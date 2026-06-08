@extends('layouts.app')

@section('title', 'Data Penjualan')
@section('page-title', 'Data Penjualan')

@section('content')
<div class="bg-white rounded-lg shadow-sm border border-gray-200">
    <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
        <h3 class="text-lg font-semibold text-gray-800">Daftar Penjualan</h3>
        <a href="{{ route('sales.create') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition">
            <i class="fas fa-plus mr-2"></i>Tambah Penjualan
        </a>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">No. Faktur</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pelanggan</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jenis</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($sales as $sale)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">
                            <p class="font-medium text-gray-800">{{ $sale->invoice_number }}</p>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-800">
                            {{ $sale->sale_date->format('d M Y') }}
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-800">
                            {{ $sale->customer ? $sale->customer->name : 'Umum' }}
                        </td>
                        <td class="px-6 py-4">
                            <span class="px-3 py-1 rounded-full text-xs font-medium {{ $sale->type == 'ecer' ? 'bg-green-100 text-green-700' : 'bg-purple-100 text-purple-700' }}">
                                {{ ucfirst($sale->type) }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm font-semibold text-gray-800">
                            Rp {{ number_format($sale->total_amount, 0, ',', '.') }}
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex space-x-2">
                                <a href="{{ route('sales.show', $sale) }}" class="text-green-600 hover:text-green-800" title="Detail">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="{{ route('sales.invoice', $sale) }}" class="text-blue-600 hover:text-blue-800" title="Cetak Faktur" target="_blank">
                                    <i class="fas fa-file-invoice"></i>
                                </a>
                                <form action="{{ route('sales.destroy', $sale) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-600 hover:text-red-800" title="Hapus">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-6 py-8 text-center text-gray-500">
                            Belum ada data penjualan
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="px-6 py-4 border-t border-gray-200">
        {{ $sales->links() }}
    </div>
</div>
@endsection
