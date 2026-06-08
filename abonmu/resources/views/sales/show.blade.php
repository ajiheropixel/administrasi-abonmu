@extends('layouts.app')

@section('title', 'Detail Penjualan')
@section('page-title', 'Detail Penjualan')

@section('content')
    <div class="max-w-4xl">
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
           <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
    <h3 class="text-lg font-semibold text-gray-800">Informasi Penjualan</h3>
    <div class="flex gap-2">
        <a href="{{ route('sales.invoice.download', $sale) }}"
            class="inline-flex items-center bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition text-sm">
            <i class="fas fa-download mr-2"></i>Download Faktur
        </a>

        <a href="{{ route('sales.index') }}" 
            class="inline-flex items-center text-blue-600 hover:text-blue-800 px-4 py-2 border border-blue-600 rounded-lg transition text-sm">
            <i class="fas fa-arrow-left mr-2"></i>Kembali
        </a>
    </div>
</div>

            <div class="p-6 space-y-4">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600">No. Faktur</p>
                        <p class="font-semibold text-gray-800">{{ $sale->invoice_number }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Tanggal Penjualan</p>
                        <p class="font-semibold text-gray-800">{{ $sale->sale_date->format('d F Y') }}</p>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600">Pelanggan</p>
                        <p class="font-semibold text-gray-800">{{ $sale->customer ? $sale->customer->name : 'Umum' }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Jenis Penjualan</p>
                        <span
                            class="inline-block px-3 py-1 rounded-full text-sm font-medium {{ $sale->type == 'ecer' ? 'bg-green-100 text-green-700' : 'bg-purple-100 text-purple-700' }}">
                            {{ ucfirst($sale->type) }}
                        </span>
                    </div>
                </div>

                @if ($sale->notes)
                    <div>
                        <p class="text-sm text-gray-600">Catatan</p>
                        <p class="text-gray-800">{{ $sale->notes }}</p>
                    </div>
                @endif
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-800">Item Penjualan</h3>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50 border-b border-gray-200">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">No</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Produk</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Jumlah</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Harga</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Subtotal</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @foreach ($sale->items as $index => $item)
                            <tr>
                                <td class="px-6 py-4 text-sm text-gray-800">{{ $index + 1 }}</td>
                                <td class="px-6 py-4 text-sm text-gray-800">{{ $item->product->name }}</td>
                                <td class="px-6 py-4 text-sm text-right text-gray-800">{{ number_format($item->quantity) }}
                                    {{ $item->product->unit }}</td>
                                <td class="px-6 py-4 text-sm text-right text-gray-800">Rp
                                    {{ number_format($item->price, 0, ',', '.') }}</td>
                                <td class="px-6 py-4 text-sm text-right font-semibold text-gray-800">Rp
                                    {{ number_format($item->subtotal, 0, ',', '.') }}</td>
                            </tr>
                        @endforeach
                        <tr class="bg-gray-50 font-semibold">
                            <td colspan="4" class="px-6 py-4 text-right text-lg">TOTAL:</td>
                            <td class="px-6 py-4 text-right text-lg text-blue-600">Rp
                                {{ number_format($sale->total_amount, 0, ',', '.') }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
@endsection
