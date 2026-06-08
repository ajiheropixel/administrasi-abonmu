<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_id' => 'required|exists:products,id',
            'production_date' => 'required|date',
            'quantity' => 'required|integer|min:1',
            'type' => 'required|in:rutin,pesanan',
            'notes' => 'nullable|string',
            'employees' => 'required|array|min:1',
            'employees.*' => 'exists:employees,id'
        ];
    }

    public function messages(): array
    {
        return [
            'product_id.required' => 'Produk harus dipilih',
            'product_id.exists' => 'Produk tidak valid',
            'production_date.required' => 'Tanggal produksi harus diisi',
            'production_date.date' => 'Format tanggal tidak valid',
            'quantity.required' => 'Jumlah produksi harus diisi',
            'quantity.integer' => 'Jumlah harus berupa angka',
            'quantity.min' => 'Jumlah minimal 1',
            'type.required' => 'Jenis produksi harus dipilih',
            'type.in' => 'Jenis produksi tidak valid',
            'employees.required' => 'Minimal pilih 1 karyawan',
            'employees.min' => 'Minimal pilih 1 karyawan',
            'employees.*.exists' => 'Karyawan tidak valid'
        ];
    }
}
