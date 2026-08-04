# Mencari network adapter utama yang terhubung ke internet (punya default gateway)
$route = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object RouteMetric | Select-Object -First 1
$ip = (Get-NetIPAddress -InterfaceIndex $route.InterfaceIndex -AddressFamily IPv4).IPAddress

if (-not $ip) {
    Write-Host "❌ Gagal menemukan IP. Pastikan Anda terhubung ke jaringan Wi-Fi atau LAN." -ForegroundColor Red
    exit
}

# Membuat isi file .env baru (jangan lupa ganti port-nya kalau backend Anda jalan di port lain)
$envContent = "BASE_URL=http://${ip}:8000/api/v1"

# Menimpa file xploria_app/.env dengan IP terbaru
Set-Content -Path ".\xploria_app\.env" -Value $envContent
Write-Host "✅ Sukses! IP di xploria_app/.env sudah diupdate ke: $ip" -ForegroundColor Green
