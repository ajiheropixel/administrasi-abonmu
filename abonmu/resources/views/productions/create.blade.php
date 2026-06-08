@extends('layouts.app')

@section('title', 'Tambah Produksi')
@section('page-title', 'Tambah Produksi')

@section('content')
<div class="max-w-2xl">
    <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-800">Form Tambah Produksi</h3>
        </div>

        <form action="{{ route('productions.store') }}" method="POST" class="p-6 space-y-4">
            @csrf

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Tanggal Produksi</label>
                <input type="date" name="production_date" value="{{ old('production_date', date('Y-m-d')) }}" required
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Produk</label>
                <select name="product_id" required
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    <option value="">Pilih Produk</option>
                    @foreach($products as $product)
                        <option value="{{ $product->id }}" {{ old('product_id') == $product->id ? 'selected' : '' }}>
                            {{ $product->name }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Jumlah Produksi</label>
                <input type="number" name="quantity" value="{{ old('quantity') }}" required min="1"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Jenis Produksi</label>
                <select name="type" required
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    <option value="rutin" {{ old('type') == 'rutin' ? 'selected' : '' }}>Rutin</option>
                    <option value="pesanan" {{ old('type') == 'pesanan' ? 'selected' : '' }}>Pesanan</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Kategori</label>
                <select name="category" required
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    <option value="">Pilih Kategori</option>
                    <option value="Abon Sapi" {{ old('category') == 'Abon Sapi' ? 'selected' : '' }}>Abon Sapi</option>
                    <option value="Abon Ayam" {{ old('category') == 'Abon Ayam' ? 'selected' : '' }}>Abon Ayam</option>
                    <option value="Abon Ikan" {{ old('category') == 'Abon Ikan' ? 'selected' : '' }}>Abon Ikan</option>
                    <option value="Abon Lainnya" {{ old('category') == 'Abon Lainnya' ? 'selected' : '' }}>Abon Lainnya</option>
                </select>
                @error('category')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Catatan</label>
                <textarea name="notes" rows="3"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">{{ old('notes') }}</textarea>
            </div>

            <div class="flex space-x-3 pt-4">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition">
                    <i class="fas fa-save mr-2"></i>Simpan
                </button>
                <a href="{{ route('productions.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg transition">
                    Batal
                </a>
            </div>
        </form>
    </div>
</div>
@endsection
