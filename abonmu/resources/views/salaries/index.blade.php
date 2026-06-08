@extends('layouts.app')

@section('title', 'Alokasi Gaji Karyawan')
@section('page-title', 'Alokasi Gaji Karyawan')

@section('content')
<div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Filter Periode</h3>
    </div>
    <div class="p-6">
        <form method="GET" action="{{ route('salaries.index') }}" class="flex items-end space-x-4">
            <div class="flex-1">
                <label class="block text-sm font-medium text-gray-700 mb-2">Tanggal Mulai</label>
                <input type="date" name="start_date" value="{{ $startDate }}"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            </div>
            <div class="flex-1">
                <label class="block text-sm font-medium text-gray-700 mb-2">Tanggal Akhir</label>
                <input type="date" name="end_date" value="{{ $endDate }}"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            </div>
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition">
                <i class="fas fa-filter mr-2"></i>Filter
            </button>
        </form>
    </div>
</div>

<div class="bg-white rounded-lg shadow-sm border border-gray-200">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Rekap Gaji Karyawan</h3>
        <p class="text-sm text-gray-600 mt-1">Periode: {{ \Carbon\Carbon::parse($startDate)->format('d M Y') }} - {{ \Carbon\Carbon::parse($endDate)->format('d M Y') }}</p>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nama Karyawan</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Produksi</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Gaji Produksi</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Packing</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Gaji Packing</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total Gaji</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @php $totalAllSalary = 0; @endphp
                @forelse($salaryData as $data)
                    @php $totalAllSalary += $data['total_salary']; @endphp
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4">
                            <p class="font-medium text-gray-800">{{ $data['employee']->name }}</p>
                            <p class="text-xs text-gray-500">
                                Tarif: Rp {{ number_format($data['employee']->production_rate, 0, ',', '.') }} / Rp {{ number_format($data['employee']->packing_rate, 0, ',', '.') }}
                            </p>
                        </td>
                        <td class="px-6 py-4 text-center text-sm text-gray-800">
                            {{ number_format($data['production_count']) }} unit
                        </td>
                        <td class="px-6 py-4 text-right text-sm font-semibold text-gray-800">
                            Rp {{ number_format($data['production_salary'], 0, ',', '.') }}
                        </td>
                        <td class="px-6 py-4 text-center text-sm text-gray-800">
                            {{ number_format($data['packing_count']) }} bungkus
                        </td>
                        <td class="px-6 py-4 text-right text-sm font-semibold text-gray-800">
                            Rp {{ number_format($data['packing_salary'], 0, ',', '.') }}
                        </td>
                        <td class="px-6 py-4 text-right text-lg font-bold text-blue-600">
                            Rp {{ number_format($data['total_salary'], 0, ',', '.') }}
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-6 py-8 text-center text-gray-500">
                            Tidak ada data gaji untuk periode ini
                        </td>
                    </tr>
                @endforelse
                @if(count($salaryData) > 0)
                    <tr class="bg-blue-50 font-bold">
                        <td colspan="5" class="px-6 py-4 text-right text-lg">TOTAL KESELURUHAN:</td>
                        <td class="px-6 py-4 text-right text-xl text-blue-600">
                            Rp {{ number_format($totalAllSalary, 0, ',', '.') }}
                        </td>
                    </tr>
                @endif
            </tbody>
        </table>
    </div>
</div>
@endsection
