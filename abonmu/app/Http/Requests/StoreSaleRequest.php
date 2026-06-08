<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSaleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'customer_id' => 'nullable|exists:customers,id',
            'sale_date' => 'required|date',
            'type' => 'required|in:ecer,pesanan',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.price' => 'required|numeric|min:0'
        ];
    }

    public function messages(): array
    {
        return [
            'sale_date.required' => 'Tanggal penjualan harus diisi',
            'type.required' => 'Jenis penjualan harus dipilih',
            'items.required' => 'Minimal tambahkan 1 item',
            'items.min' => 'Minimal tambahkan 1 item',
            'items.*.product_id.required' => 'Produk harus dipilih',
            'items.*.product_id.exists' => 'Produk tidak valid',
            'items.*.quantity.required' => 'Jumlah harus diisi',
            'items.*.quantity.min' => 'Jumlah minimal 1',
            'items.*.price.required' => 'Harga harus diisi',
            'items.*.price.min' => 'Harga tidak boleh negatif'
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            if ($this->has('items')) {
                foreach ($this->items as $index => $item) {
                    if (isset($item['product_id']) && isset($item['quantity'])) {
                        $product = \App\Models\Product::find($item['product_id']);
                        if ($product && $product->stock < $item['quantity']) {
                            $validator->errors()->add(
                                "items.{$index}.quantity",
                                "Stok {$product->name} tidak mencukupi. Tersedia: {$product->stock}"
                            );
                        }
                    }
                }
            }
        });
    }
}
