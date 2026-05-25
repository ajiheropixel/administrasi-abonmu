<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faktur {{ $sale->invoice_number }}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; padding: 40px; color: #333; }
        .invoice-container { max-width: 800px; margin: 0 auto; }
        .header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 30px; border-bottom: 3px solid #2563eb; padding-bottom: 20px; }
        .header-left { display: flex; align-items: center; }
        .logo { max-width: 100px; max-height: 100px; margin-right: 20px; }
        .company-info { flex: 1; }
        .company-info h1 { color: #1e40af; font-size: 28px; margin-bottom: 5px; }
        .company-info p { color: #666; font-size: 14px; }
        .invoice-info { display: flex; justify-content: space-between; margin-bottom: 30px; }
        .invoice-info div { flex: 1; }
        .invoice-info h3 { font-size: 14px; color: #666; margin-bottom: 10px; }
        .invoice-info p { font-size: 14px; line-height: 1.6; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        thead { background-color: #f3f4f6; }
        th { padding: 12px; text-align: left; font-size: 12px; text-transform: uppercase; color: #666; border-bottom: 2px solid #e5e7eb; }
        td { padding: 12px; border-bottom: 1px solid #e5e7eb; font-size: 14px; }
        .text-right { text-align: right; }
        .total-section { margin-top: 20px; text-align: right; }
        .total-row { display: flex; justify-content: flex-end; margin-bottom: 10px; }
        .total-row span:first-child { margin-right: 40px; font-weight: 600; }
        .grand-total { font-size: 18px; color: #1e40af; font-weight: bold; padding-top: 10px; border-top: 2px solid #2563eb; }
        .footer { margin-top: 50px; text-align: center; color: #666; font-size: 12px; }
        .watermark { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); opacity: 0.05; z-index: -1; }
        .watermark img { width: 400px; }
        @media print {
            body { padding: 20px; }
            .no-print { display: none; }
        }
    </style>
</head>
<body>


    <div class="invoice-container">
        <div class="header">
            <div class="header-left">


                <div class="company-info">
                    <h1>RUMAH PRODUKSI ABON</h1>
                    <p>Sistem Administrasi Penjualan</p>
                    <p style="margin-top: 5px; font-size: 12px;">Alamat: Jl. Contoh No. 123, Kota</p>
                    <p style="font-size: 12px;">Telp: (021) 1234-5678 | Email: info@abon.com</p>
                </div>
            </div>
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
                    <th>No</th>
                    <th>Produk</th>
                    <th class="text-right">Jumlah</th>
                    <th class="text-right">Harga</th>
                    <th class="text-right">Subtotal</th>
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
                <span>TOTAL:</span>
                <span>Rp {{ number_format($sale->total_amount, 0, ',', '.') }}</span>
            </div>
        </div>

        @if($sale->notes)
            <div style="margin-top: 30px; padding: 15px; background-color: #f9fafb; border-left: 4px solid #2563eb;">
                <strong>Catatan:</strong><br>
                {{ $sale->notes }}
            </div>
        @endif

        <div class="footer">
            <p>Terima kasih atas kepercayaan Anda</p>
            <p style="margin-top: 10px;">Dicetak pada: {{ now()->format('d F Y H:i') }}</p>
            <p style="margin-top: 5px; font-size: 10px;">Faktur ini sah dan diproses oleh komputer</p>
        </div>

        <div class="no-print" style="text-align: center; margin-top: 30px;">
            <button onclick="downloadPDF()" style="background-color: #2563eb; color: white; padding: 12px 24px; border: none; border-radius: 8px; cursor: pointer; font-size: 14px;">
                <i class="fas fa-download"></i> Download Faktur
            </button>
            <button onclick="window.close()" style="background-color: #6b7280; color: white; padding: 12px 24px; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; margin-left: 10px;">
                Tutup
            </button>
        </div>
    </div>

    <script>
        function downloadPDF() {
            // Sembunyikan tombol sebelum print
            const buttons = document.querySelector('.no-print');
            buttons.style.display = 'none';
            
            // Trigger print dialog (user bisa pilih "Save as PDF")
            window.print();
            
            // Tampilkan kembali tombol setelah print dialog ditutup
            setTimeout(() => {
                buttons.style.display = 'block';
            }, 100);
        }
    </script>
    </div>
</body>
</html>
