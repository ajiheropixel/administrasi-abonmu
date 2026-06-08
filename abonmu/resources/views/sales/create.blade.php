@extends('layouts.app')

@section('title', 'Tambah Penjualan')
@section('page-title', 'Tambah Penjualan')

@section('content')
<div class="max-w-4xl">
    <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-800">Form Tambah Penjualan</h3>
        </div>

        <form action="{{ route('sales.store') }}" method="POST" class="p-6 space-y-4" id="saleForm">
            @csrf

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tanggal Penjualan</label>
                    <input type="date" name="sale_date" value="{{ old('sale_date', date('Y-m-d')) }}" required
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Jenis Penjualan</label>
                    <select name="type" required
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <option value="ecer" {{ old('type') == 'ecer' ? 'selected' : '' }}>Ecer</option>
                        <option value="pesanan" {{ old('type') == 'pesanan' ? 'selected' : '' }}>Pesanan</option>
                    </select>
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Pelanggan (Opsional)</label>
                <select name="customer_id"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    <option value="">Umum</option>
                    @foreach($customers as $customer)
                        <option value="{{ $customer->id }}" {{ old('customer_id') == $customer->id ? 'selected' : '' }}>
                            {{ $customer->name }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Item Penjualan</label>
                <div id="itemsContainer" class="space-y-3">
                    <div class="item-row border border-gray-300 rounded-lg p-4">
                        <div class="grid grid-cols-12 gap-3">
                            <div class="col-span-5">
                                <select name="items[0][product_id]" required class="w-full px-3 py-2 border border-gray-300 rounded-lg product-select">
                                    <option value="">Pilih Produk</option>
                                    @foreach($products as $product)
                                        <option value="{{ $product->id }}" data-price="{{ $product->price }}" data-stock="{{ $product->stock }}">
                                            {{ $product->name }} (Stok: {{ $product->stock }})
                                        </option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="col-span-2">
                                <input type="number" name="items[0][quantity]" placeholder="Jumlah" required min="1" class="w-full px-3 py-2 border border-gray-300 rounded-lg quantity-input">
                            </div>
                            <div class="col-span-3">
                                <input type="number" name="items[0][price]" placeholder="Harga" required min="0" step="0.01" class="w-full px-3 py-2 border border-gray-300 rounded-lg price-input">
                            </div>
                            <div class="col-span-2 flex items-center">
                                <button type="button" class="text-red-600 hover:text-red-800 remove-item" disabled>
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <button type="button" id="addItem" class="mt-3 text-blue-600 hover:text-blue-800 text-sm">
                    <i class="fas fa-plus mr-1"></i>Tambah Item
                </button>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Catatan</label>
                <textarea name="notes" rows="2"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">{{ old('notes') }}</textarea>
            </div>

            <div class="bg-gray-50 p-4 rounded-lg">
                <p class="text-lg font-semibold text-gray-800">Total: <span id="totalAmount">Rp 0</span></p>
            </div>

            <div class="flex space-x-3 pt-4">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition">
                    <i class="fas fa-save mr-2"></i>Simpan
                </button>
                <a href="{{ route('sales.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg transition">
                    Batal
                </a>
            </div>
        </form>
    </div>
</div>

@push('scripts')
<script>
let itemIndex = 1;

document.getElementById('addItem').addEventListener('click', function() {
    const container = document.getElementById('itemsContainer');
    const newItem = document.querySelector('.item-row').cloneNode(true);
    
    newItem.querySelectorAll('input, select').forEach(input => {
        input.name = input.name.replace(/\[\d+\]/, `[${itemIndex}]`);
        if (input.tagName === 'INPUT') input.value = '';
        if (input.tagName === 'SELECT') input.selectedIndex = 0;
    });
    
    newItem.querySelector('.remove-item').disabled = false;
    container.appendChild(newItem);
    itemIndex++;
    attachEventListeners();
});

document.getElementById('itemsContainer').addEventListener('click', function(e) {
    if (e.target.closest('.remove-item')) {
        e.target.closest('.item-row').remove();
        calculateTotal();
    }
});

function attachEventListeners() {
    document.querySelectorAll('.product-select').forEach(select => {
        select.removeEventListener('change', handleProductChange);
        select.addEventListener('change', handleProductChange);
    });
    
    document.querySelectorAll('.quantity-input, .price-input').forEach(input => {
        input.removeEventListener('input', calculateTotal);
        input.addEventListener('input', calculateTotal);
    });
}

function handleProductChange(e) {
    const option = e.target.selectedOptions[0];
    const price = option.dataset.price;
    const row = e.target.closest('.item-row');
    const priceInput = row.querySelector('.price-input');
    if (price) priceInput.value = price;
    calculateTotal();
}

function calculateTotal() {
    let total = 0;
    document.querySelectorAll('.item-row').forEach(row => {
        const qty = parseFloat(row.querySelector('.quantity-input').value) || 0;
        const price = parseFloat(row.querySelector('.price-input').value) || 0;
        total += qty * price;
    });
    document.getElementById('totalAmount').textContent = 'Rp ' + total.toLocaleString('id-ID');
}

attachEventListeners();
</script>
@endpush
@endsection
