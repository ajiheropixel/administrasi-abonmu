@extends('layouts.app')

@section('title', 'Edit Produk')
@section('page-title', 'Edit Produk')

@section('content')
<div class="max-w-2xl">
    <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-800">Form Edit Produk</h3>
        </div>

        <form action="{{ route('products.update', $product) }}" method="POST" enctype="multipart/form-data" class="p-6 space-y-4">
            @csrf
            @method('PUT')

            {{-- Foto Produk --}}
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Foto Produk</label>
                <div id="drop-zone"
                    class="relative border-2 border-dashed border-gray-300 rounded-lg p-4 text-center cursor-pointer hover:border-blue-400 hover:bg-blue-50 transition"
                    onclick="document.getElementById('image-input').click()">
                    @if($product->image)
                        <img id="preview" src="{{ asset('storage/' . $product->image) }}" alt="{{ $product->name }}"
                            class="mx-auto mb-2 h-32 w-32 object-cover rounded-lg">
                        <div id="placeholder" class="hidden">
                            <i class="fas fa-cloud-upload-alt text-3xl text-gray-400 mb-2"></i>
                            <p class="text-sm text-gray-500">Klik untuk ganti gambar</p>
                        </div>
                    @else
                        <img id="preview" src="" alt="" class="hidden mx-auto mb-2 h-32 w-32 object-cover rounded-lg">
                        <div id="placeholder">
                            <i class="fas fa-cloud-upload-alt text-3xl text-gray-400 mb-2"></i>
                            <p class="text-sm text-gray-500">Klik atau seret gambar ke sini</p>
                            <p class="text-xs text-gray-400 mt-1">JPG, PNG, WebP • Maks 2MB</p>
                        </div>
                    @endif
                    <input id="image-input" type="file" name="image" accept="image/*" class="hidden"
                        onchange="previewImage(this)">
                </div>
                @if($product->image)
                    <p class="text-xs text-gray-400 mt-1">
                        <i class="fas fa-info-circle mr-1"></i>Pilih file baru untuk mengganti foto
                    </p>
                @endif
                @error('image')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Nama Produk</label>
                <input type="text" name="name" value="{{ old('name', $product->name) }}" required
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                @error('name')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Kategori</label>
                <select name="category" required
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    <option value="">Pilih Kategori</option>
                    <option value="Abon Sapi" {{ old('category', $product->category) == 'Abon Sapi' ? 'selected' : '' }}>Abon Sapi</option>
                    <option value="Abon Ayam" {{ old('category', $product->category) == 'Abon Ayam' ? 'selected' : '' }}>Abon Ayam</option>
                    <option value="Abon Ikan" {{ old('category', $product->category) == 'Abon Ikan' ? 'selected' : '' }}>Abon Ikan</option>
                    <option value="Abon Lainnya" {{ old('category', $product->category) == 'Abon Lainnya' ? 'selected' : '' }}>Abon Lainnya</option>
                </select>
                @error('category')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Deskripsi</label>
                <textarea name="description" rows="3"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">{{ old('description', $product->description) }}</textarea>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Harga</label>
                    <input type="number" name="price" value="{{ old('price', $product->price) }}" required step="0.01"
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    @error('price')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Satuan</label>
                    <input type="text" name="unit" value="{{ old('unit', $product->unit) }}" required
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                </div>
            </div>

            <div class="bg-gray-50 p-4 rounded-lg">
                <p class="text-sm text-gray-600">Stok saat ini: <span class="font-semibold">{{ $product->stock }} {{ $product->unit }}</span></p>
                <p class="text-xs text-gray-500 mt-1">Stok dikelola otomatis melalui produksi dan penjualan</p>
            </div>

            <div class="flex space-x-3 pt-4">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition">
                    <i class="fas fa-save mr-2"></i>Update
                </button>
                <a href="{{ route('products.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg transition">
                    Batal
                </a>
            </div>
        </form>
    </div>
</div>

<script>
function previewImage(input) {
    const preview = document.getElementById('preview');
    const placeholder = document.getElementById('placeholder');
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = e => {
            preview.src = e.target.result;
            preview.classList.remove('hidden');
            placeholder.classList.add('hidden');
        };
        reader.readAsDataURL(input.files[0]);
    }
}
</script>
@endsection
