<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Laporan Rumah Produksi AbonMu</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        @page { margin: 2.5cm 2.5cm 2.5cm 2.5cm; }
        body { font-family: Arial, sans-serif; font-size: 10px; color: #333; line-height: 1.6; }
        
        /* Header */
        .header { border-bottom: 3px solid #1e40af; padding-bottom: 12px; margin-bottom: 20px; }
        .header-container { display: table; width: 100%; }
        .header-left { display: table-cell; width: 20%; vertical-align: top; padding-left: 15px; }
        .header-left img { height: 50px; }
        .header-center { display: table-cell; width: 60%; text-align: center; vertical-align: top; padding-top: 5px; }
        .header-center h1 { color: #1e40af; font-size: 18px; margin-bottom: 3px; font-weight: bold; }
        .header-center .address { color: #666; font-size: 9px; }
        .header-right { display: table-cell; width: 20%; text-align: right; vertical-align: top; padding-top: 5px; padding-right: 15px; }
        .header-right .date { color: #666; font-size: 9px; line-height: 1.4; }
        
        /* Info Section */
        .info-section { margin-bottom: 18px; padding-left: 25px; }
        .info-section h3 { font-size: 11px; margin-bottom: 8px; color: #1e40af; font-weight: bold; }
        .info-row { margin-bottom: 2px; font-size: 10px; line-height: 1.5; }
        .info-row .label { display: inline-block; width: 130px; color: #333; }
        
        /* Summary Cards */
        .summary-container { display: table; width: 100%; margin-bottom: 18px; border-collapse: collapse; padding: 0 15px; }
        .summary-box { display: table-cell; width: 25%; padding: 12px; text-align: center; border: 1px solid #ddd; background-color: #fafafa; vertical-align: top; }
        .summary-box .title { font-size: 9px; color: #666; margin-bottom: 6px; }
        .summary-box .value { font-size: 22px; font-weight: bold; margin-bottom: 2px; line-height: 1.2; }
        .summary-box .subtitle { font-size: 8px; color: #999; }
        .value-blue { color: #2563eb; }
        .value-green { color: #10b981; }
        .value-red { color: #ef4444; }
        .value-purple { color: #8b5cf6; }
        
        /* Section */
        .section { margin-bottom: 18px; page-break-inside: avoid; padding: 0 15px; }
        .section-header { background-color: #f3f4f6; padding: 7px 10px; font-size: 10px; font-weight: bold; margin-bottom: 8px; color: #1e40af; text-transform: uppercase; letter-spacing: 0.5px; }
        
        /* Table */
        table.detail-table { width: 100%; border-collapse: collapse; }
        table.detail-table thead { background-color: #f9fafb; }
        table.detail-table th { padding: 7px 8px; text-align: left; font-size: 8px; text-transform: uppercase; color: #666; border-bottom: 2px solid #ddd; font-weight: bold; }
        table.detail-table td { padding: 7px 8px; border-bottom: 1px solid #e5e7eb; font-size: 9px; vertical-align: top; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .empty-data { text-align: center; padding: 18px; color: #999; font-style: italic; font-size: 10px; }
        
        /* Footer */
        .footer { position: fixed; bottom: 2.5cm; left: 2.5cm; right: 2.5cm; text-align: center; font-size: 8px; color: #666; border-top: 1px solid #ddd; padding-top: 8px; }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header">
        <div class="header-container">
            <div class="header-left">
                @php
                    $logoPath = public_path('images/logo-abonmu.png');
                    if (file_exists($logoPath)) {
                        $logoData = base64_encode(file_get_contents($logoPath));
                        $logoBase64 = 'data:image/png;base64,' . $logoData;
                        echo '<img src="' . $logoBase64 . '">';
                    }
                @endphp
            </div>
            <div class="header-center">
                <h1>Laporan Rumah Produksi AbonMu</h1>
                <p class="address">Kp Bojong, Linggasirna, Kec. Sariwangi, Kabupaten Tasikmalaya.</p>
            </div>
            <div class="header-right">
                <div class="date">{{ now()->locale('id')->isoFormat('dddd, D MMMM YYYY') }}</div>
                <div class="date">{{ now()->format('H:i') }} WIB</div>
            </div>
        </div>
    </div>

    <!-- Informasi Laporan -->
    <div class="info-section">
        <h3>Informasi Laporan</h3>
        <div class="info-row">
            <span class="label">Periode</span>
            <span>: {{ \Carbon\Carbon::parse($startDate)->locale('id')->isoFormat('D MMMM YYYY') }} – {{ \Carbon\Carbon::parse($endDate)->locale('id')->isoFormat('D MMMM YYYY') }}</span>
        </div>
        <div class="info-row">
            <span class="label">Keterangan kategori</span>
            <span>: {{ request('category') ? request('category') : 'Semua Kategori' }}</span>
        </div>
        <div class="info-row">
            <span class="label">Jenis produksi</span>
            <span>: {{ request('type') ? ucfirst(request('type')) : 'Semua Jenis' }}</span>
        </div>
        <div class="info-row">
            <span class="label">Produk</span>
            <span>: {{ request('product_id') ? ($products->find(request('product_id'))->name ?? 'Semua Produk') : 'Semua Produk' }}</span>
        </div>
    </div>

    <!-- Ringkasan -->
    <table class="summary-container">
        <tr>
            <td class="summary-box">
                <div class="title">Total Produksi</div>
                <div class="value value-blue">{{ number_format($totalProduction, 0, ',', '.') }}</div>
                <div class="subtitle">bungkus</div>
            </td>
            <td class="summary-box">
                <div class="title">Total Penjualan</div>
                <div class="value value-green">Rp {{ number_format($totalSales, 0, ',', '.') }}</div>
                <div class="subtitle">{{ number_format($sales->count(), 0, ',', '.') }} transaksi</div>
            </td>
            <td class="summary-box">
                <div class="title">Total Pengeluaran</div>
                <div class="value value-red">Rp {{ number_format($totalExpenses, 0, ',', '.') }}</div>
                <div class="subtitle">biaya produksi</div>
            </td>
            <td class="summary-box">
                <div class="title">Laba Bersih</div>
                <div class="value value-purple" style="color: {{ $netProfit >= 0 ? '#8b5cf6' : '#ef4444' }};">Rp {{ number_format($netProfit, 0, ',', '.') }}</div>
                <div class="subtitle">periode ini</div>
            </td>
        </tr>
    </table>

    <!-- DETAIL PRODUKSI -->
    <div class="section">
        <div class="section-header">Detail Produksi</div>
        @if($allProductions->count() > 0)
        <table class="detail-table">
            <thead>
                <tr>
                    <th>Tanggal</th>
                    <th>Produk</th>
                    <th>Kategori</th>
                    <th>Jumlah</th>
                    <th>Jenis</th>
                    <th>Catatan</th>
                </tr>
            </thead>
            <tbody>
                @foreach($allProductions as $production)
                <tr>
                    <td>{{ $production->production_date->format('d/m/Y') }}</td>
                    <td>{{ $production->product->name }}</td>
                    <td>{{ $production->category ?? '-' }}</td>
                    <td>{{ number_format($production->quantity, 0, ',', '.') }} {{ $production->product->unit }}</td>
                    <td>{{ ucfirst($production->type) }}</td>
                    <td>{{ $production->notes ?? '-' }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
        @else
        <div class="empty-data">— Tidak ada data pada periode ini —</div>
        @endif
    </div>

    <!-- DETAIL PENGELUARAN -->
    <div class="section">
        <div class="section-header">Detail Pengeluaran</div>
        @if($expenses->count() > 0)
        <table class="detail-table">
            <thead>
                <tr>
                    <th>Tanggal</th>
                    <th>Produk Terkait</th>
                    <th class="text-right">Jumlah</th>
                    <th>Keterangan</th>
                </tr>
            </thead>
            <tbody>
                @foreach($expenses as $expense)
                <tr>
                    <td>{{ $expense->expense_date->format('d/m/Y') }}</td>
                    <td>{{ $expense->production ? $expense->production->product->name : '-' }}</td>
                    <td class="text-right" style="color: #ef4444; font-weight: bold;">Rp {{ number_format($expense->amount, 0, ',', '.') }}</td>
                    <td>{{ $expense->description ?? '-' }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
        @else
        <div class="empty-data">— Tidak ada data pada periode ini —</div>
        @endif
    </div>

    <!-- DETAIL PENJUALAN -->
    <div class="section">
        <div class="section-header">Detail Penjualan</div>
        @if($sales->count() > 0)
        <table class="detail-table">
            <thead>
                <tr>
                    <th>Tanggal</th>
                    <th>Nomor Invoice</th>
                    <th>Pelanggan</th>
                    <th class="text-right">Total</th>
                </tr>
            </thead>
            <tbody>
                @foreach($sales as $sale)
                <tr>
                    <td>{{ $sale->sale_date->format('d/m/Y') }}</td>
                    <td>{{ $sale->invoice_number }}</td>
                    <td>{{ $sale->customer ? $sale->customer->name : 'Umum' }}</td>
                    <td class="text-right" style="color: #10b981; font-weight: bold;">Rp {{ number_format($sale->total_amount, 0, ',', '.') }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
        @else
        <div class="empty-data">— Tidak ada data pada periode ini —</div>
        @endif
    </div>

    <!-- Footer -->
    <div class="footer">
        <p>Dicetak oleh: Sistem Administrasi Rumah Produksi AbonMu</p>
    </div>
</body>
</html>
