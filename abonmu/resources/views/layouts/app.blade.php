<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Sistem Administrasi Rumah Produksi Abon')</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
        @media print { .no-print { display: none !important; } }
    </style>
</head>
<body class="bg-gray-50">
    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar - Desktop -->
        <aside class="hidden lg:block w-64 bg-gradient-to-b from-slate-800 to-slate-900 text-white flex-shrink-0 no-print">
            <div class="p-4 border-b border-slate-700">
                <div class="flex justify-start">
                    <img
                        src="{{ asset('images/logo-abonmu.png') }}"
                        alt="Logo AbonMu"
                        class="h-16 w-auto object-contain -ml-2"
                    >
                </div>
                <h1 class="text-lg font-bold mt-3 leading-tight">Rumah Produksi Abon</h1>
                <p class="text-xs text-slate-400 mt-1">Sistem Administrasi</p>
            </div>
            
            <nav class="p-4 space-y-1">
                <a href="{{ route('dashboard') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('dashboard') ? 'bg-slate-700' : '' }}">
                    <i class="fas fa-home w-5"></i>
                    <span class="ml-3">Dashboard</span>
                </a>
                
                @if(auth()->user()->isAdmin())
                <a href="{{ route('productions.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('productions.*') ? 'bg-slate-700' : '' }}">
                    <i class="fas fa-industry w-5"></i>
                    <span class="ml-3">Produksi</span>
                </a>
                
                <a href="{{ route('products.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('products.*') ? 'bg-slate-700' : '' }}">
                    <i class="fas fa-box w-5"></i>
                    <span class="ml-3">Produk dan Stok</span>
                </a>
                
                <a href="{{ route('customers.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('customers.*') ? 'bg-slate-700' : '' }}">
                    <i class="fas fa-users w-5"></i>
                    <span class="ml-3">Pelanggan</span>
                </a>
                
                <a href="{{ route('expenses.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('expenses.*') ? 'bg-slate-700' : '' }}">
                    <i class="fas fa-receipt w-5"></i>
                    <span class="ml-3">Pengeluaran Produksi</span>
                </a>
                
                <a href="{{ route('sales.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('sales.*') ? 'bg-slate-700' : '' }}">
                    <i class="fas fa-shopping-cart w-5"></i>
                    <span class="ml-3">Penjualan</span>
                </a>
                @endif
                
                <a href="{{ route('reports.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('reports.*') ? 'bg-slate-700' : '' }}">
                    <i class="fas fa-chart-bar w-5"></i>
                    <span class="ml-3">Laporan</span>
                </a>

                <div class="pt-4 mt-4 border-t border-slate-700">
                    <div class="px-4 py-2 mb-2">
                        <p class="text-xs text-slate-400">Login sebagai:</p>
                        <p class="text-sm font-semibold">{{ auth()->user()->name }}</p>
                        <p class="text-xs text-slate-400">{{ ucfirst(auth()->user()->role) }}</p>
                    </div>
                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button type="submit" class="flex items-center px-4 py-3 rounded-lg hover:bg-red-600 transition w-full text-left">
                            <i class="fas fa-sign-out-alt w-5"></i>
                            <span class="ml-3">Logout</span>
                        </button>
                    </form>
                </div>
            </nav>
        </aside>

        <!-- Main Content -->
        <div class="flex-1 flex flex-col overflow-hidden">
            <!-- Mobile Header -->
            <header class="bg-white shadow-sm border-b border-gray-200 no-print">
                <div class="px-4 lg:px-6 py-4 flex items-center justify-between">
                    <!-- Mobile Menu Button -->
                    <button onclick="toggleMobileMenu()" class="lg:hidden text-gray-600 hover:text-gray-800">
                        <i class="fas fa-bars text-xl"></i>
                    </button>
                    
                    <h2 class="text-xl lg:text-2xl font-semibold text-gray-800">@yield('page-title', 'Dashboard')</h2>
                    
                    <div class="text-right">
                        <div class="text-xs lg:text-sm font-semibold text-gray-800" id="current-date"></div>
                        <div class="text-xs text-gray-500" id="current-time"></div>
                    </div>
                </div>
            </header>

            <!-- Mobile Sidebar Overlay -->
            <div id="mobile-menu-overlay" class="fixed inset-0 bg-black bg-opacity-50 z-40 hidden lg:hidden" onclick="toggleMobileMenu()"></div>
            
            <!-- Mobile Sidebar -->
            <aside id="mobile-menu" class="fixed top-0 left-0 w-64 h-full bg-gradient-to-b from-slate-800 to-slate-900 text-white z-50 transform -translate-x-full transition-transform duration-300 lg:hidden">
                <div class="p-4 border-b border-slate-700 flex justify-between items-center">
                    <div>
                        <h1 class="text-lg font-bold leading-tight">Rumah Produksi Abon</h1>
                        <p class="text-xs text-slate-400 mt-1">Sistem Administrasi</p>
                    </div>
                    <button onclick="toggleMobileMenu()" class="text-white">
                        <i class="fas fa-times text-xl"></i>
                    </button>
                </div>
                
                <nav class="p-4 space-y-1">
                    <a href="{{ route('dashboard') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('dashboard') ? 'bg-slate-700' : '' }}">
                        <i class="fas fa-home w-5"></i>
                        <span class="ml-3">Dashboard</span>
                    </a>
                    
                    @if(auth()->user()->isAdmin())
                    <a href="{{ route('productions.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('productions.*') ? 'bg-slate-700' : '' }}">
                        <i class="fas fa-industry w-5"></i>
                        <span class="ml-3">Produksi</span>
                    </a>
                    
                    <a href="{{ route('products.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('products.*') ? 'bg-slate-700' : '' }}">
                        <i class="fas fa-box w-5"></i>
                        <span class="ml-3">Produk dan Stok</span>
                    </a>
                    
                    <a href="{{ route('customers.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('customers.*') ? 'bg-slate-700' : '' }}">
                        <i class="fas fa-users w-5"></i>
                        <span class="ml-3">Pelanggan</span>
                    </a>
                    
                    <a href="{{ route('expenses.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('expenses.*') ? 'bg-slate-700' : '' }}">
                        <i class="fas fa-receipt w-5"></i>
                        <span class="ml-3">Pengeluaran Produksi</span>
                    </a>
                    
                    <a href="{{ route('sales.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('sales.*') ? 'bg-slate-700' : '' }}">
                        <i class="fas fa-shopping-cart w-5"></i>
                        <span class="ml-3">Penjualan</span>
                    </a>
                    @endif
                    
                    <a href="{{ route('reports.index') }}" class="flex items-center px-4 py-3 rounded-lg hover:bg-slate-700 transition {{ request()->routeIs('reports.*') ? 'bg-slate-700' : '' }}">
                        <i class="fas fa-chart-bar w-5"></i>
                        <span class="ml-3">Laporan</span>
                    </a>

                    <div class="pt-4 mt-4 border-t border-slate-700">
                        <div class="px-4 py-2 mb-2">
                            <p class="text-xs text-slate-400">Login sebagai:</p>
                            <p class="text-sm font-semibold">{{ auth()->user()->name }}</p>
                            <p class="text-xs text-slate-400">{{ ucfirst(auth()->user()->role) }}</p>
                        </div>
                        <form method="POST" action="{{ route('logout') }}">
                            @csrf
                            <button type="submit" class="flex items-center px-4 py-3 rounded-lg hover:bg-red-600 transition w-full text-left">
                                <i class="fas fa-sign-out-alt w-5"></i>
                                <span class="ml-3">Logout</span>
                            </button>
                        </form>
                    </div>
                </nav>
            </aside>

            <!-- Content Area -->
            <main class="flex-1 overflow-y-auto p-4 lg:p-6">
                @if(session('success'))
                    <div class="mb-4 bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-lg">
                        {{ session('success') }}
                    </div>
                @endif

                @if(session('error'))
                    <div class="mb-4 bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg">
                        {{ session('error') }}
                    </div>
                @endif

                @yield('content')
            </main>
        </div>
    </div>

    @stack('scripts')
    
    <script>
        // Toggle Mobile Menu
        function toggleMobileMenu() {
            const menu = document.getElementById('mobile-menu');
            const overlay = document.getElementById('mobile-menu-overlay');
            
            menu.classList.toggle('-translate-x-full');
            overlay.classList.toggle('hidden');
        }

        // Update tanggal dan waktu real-time
        function updateDateTime() {
            const now = new Date();
            
            // Format tanggal Indonesia
            const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
            const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
            
            const dayName = days[now.getDay()];
            const day = now.getDate();
            const month = months[now.getMonth()];
            const year = now.getFullYear();
            
            // Format waktu
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const seconds = String(now.getSeconds()).padStart(2, '0');
            
            // Update DOM
            const dateElement = document.getElementById('current-date');
            const timeElement = document.getElementById('current-time');
            
            if (dateElement) {
                dateElement.textContent = `${dayName}, ${day} ${month} ${year}`;
            }
            
            if (timeElement) {
                timeElement.textContent = `${hours}:${minutes}:${seconds} WIB`;
            }
        }
        
        // Update setiap detik
        updateDateTime();
        setInterval(updateDateTime, 1000);
    </script>
</body>
</html>
