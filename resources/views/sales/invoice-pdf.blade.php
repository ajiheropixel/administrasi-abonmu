<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Faktur {{ $sale->invoice_number }}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; padding: 40px; color: #333; }
        .invoice-container { max-width: 800px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 30px; border-bottom: 3px solid #2563eb; padding-bottom: 20px; }
        .header h1 { color: #1e40af; font-size: 28px; margin-bottom: 5px; }
        .header p { color: #666; font-size: 14px; }
        .invoice-info { display: table; width: 100%; margin-bottom: 30px; }
        .invoice-info > div { display: table-cell; width: 50%; vertical-align: top; }
        .invoice-info h3 { font-size: 14px; color: #666; margin-bottom: 10px; }
        .invoice-info p { font-size: 14px; line-height: 1.6; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        thead { background-color: #f3f4f6; }
        th { padding: 12px; text-align: left; font-size: 12px; text-transform: uppercase; color: #666; border-bottom: 2px solid #e5e7eb; }
        td { padding: 12px; border-bottom: 1px solid #e5e7eb; font-size: 14px; }
        .text-right { text-align: right; }
        .total-section { margin-top: 20px; text-align: right; }
        .total-row { margin-bottom: 10px; }
        .grand-total { font-size: 18px; color: #1e40af; font-weight: bold; padding-top: 10px; border-top: 2px solid #2563eb; }
        .footer { margin-top: 50px; text-align: center; color: #666; font-size: 12px; }
        .notes-box { margin-top: 30px; padding: 15px; background-color: #f9fafb; border-left: 4px solid #2563eb; }
    </style>
</head>
<body>
    <div class="invoice-container">
        <div class="header">
            <h1>RUMAH PRODUKSI ABON</h1>
            <p>Sistem Administrasi Penjualan</p>
        </div>

        <div class="invoice-info">
            <div>
                <h3>FAKTUR</h3>
                <p><strong>{{ $sale->invoice_number }}</strong></p>
                <p>Tanggal: {{ $sale->sale_date->format('d F Y') }}</p>
                <p>Jenis: {{ ucfirst($sale->type) }}</p>
            </div>
            <div>
                <h3>PELANGGAN</h3>
                @if($sale->customer)
                    <p><strong>{{ $sale->customer->name }}</strong></p>
                    @if($sale->customer->phone)
                        <p>Telp: {{ $sale->customer->phone }}</p>
                    @endif
                    @if($sale->customer->address)
                        <p>{{ $sale->customer->address }}</p>
                    @endif
                @else
                    <p><strong>Umum</strong></p>
                @endif
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th style="width: 5%;">No</th>
                    <th style="width: 40%;">Produk</th>
                    <th class="text-right" style="width: 15%;">Jumlah</th>
                    <th class="text-right" style="width: 20%;">Harga</th>
                    <th class="text-right" style="width: 20%;">Subtotal</th>
                </tr>
            </thead>
            <tbody>
                @foreach($sale->items as $index => $item)
                    <tr>
                        <td>{{ $index + 1 }}</td>
                        <td>{{ $item->product->name }}</td>
                        <td class="text-right">{{ number_format($item->quantity) }} {{ $item->product->unit }}</td>
                        <td class="text-right">Rp {{ number_format($item->price, 0, ',', '.') }}</td>
                        <td class="text-right">Rp {{ number_format($item->subtotal, 0, ',', '.') }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>

        <div class="total-section">
            <div class="total-row grand-total">
                <strong>TOTAL: Rp {{ number_format($sale->total_amount, 0, ',', '.') }}</strong>
            </div>
        </div>

        @if($sale->notes)
            <div class="notes-box">
                <strong>Catatan:</strong><br>
                {{ $sale->notes }}
            </div>
        @endif

        <div class="footer">
            <p>Terima kasih atas kepercayaan Anda</p>
            <p style="margin-top: 10px;">Dicetak pada: {{ now()->format('d F Y H:i') }}</p>
        </div>
    </div>
</body>
</html>