# Script: deploy-flutter-web.ps1
# Jalankan setelah flutter build web selesai
# Usage: .\deploy-flutter-web.ps1

$source = "mobile\build\web"
$dest   = "public\app"

if (-not (Test-Path $source)) {
    Write-Host "ERROR: Folder $source tidak ditemukan. Jalankan 'flutter build web' dulu." -ForegroundColor Red
    exit 1
}

# Hapus folder lama
if (Test-Path $dest) {
    Remove-Item -Recurse -Force $dest
    Write-Host "Folder lama dihapus." -ForegroundColor Yellow
}

# Copy hasil build
Copy-Item -Recurse $source $dest
Write-Host "Flutter web berhasil di-deploy ke $dest" -ForegroundColor Green
Write-Host "Buka: http://localhost:8000/app" -ForegroundColor Cyan
