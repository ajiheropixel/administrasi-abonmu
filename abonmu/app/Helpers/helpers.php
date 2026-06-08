<?php

if (!function_exists('formatRupiah')) {
    function formatRupiah($amount)
    {
        return 'Rp ' . number_format($amount, 0, ',', '.');
    }
}

if (!function_exists('formatNumber')) {
    function formatNumber($number)
    {
        return number_format($number, 0, ',', '.');
    }
}

if (!function_exists('formatDate')) {
    function formatDate($date, $format = 'd M Y')
    {
        return \Carbon\Carbon::parse($date)->format($format);
    }
}

if (!function_exists('getMonthName')) {
    function getMonthName($month)
    {
        $months = [
            1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April',
            5 => 'Mei', 6 => 'Juni', 7 => 'Juli', 8 => 'Agustus',
            9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember'
        ];
        return $months[$month] ?? '';
    }
}

if (!function_exists('stockStatus')) {
    function stockStatus($stock)
    {
        if ($stock < 20) {
            return ['class' => 'bg-red-100 text-red-700', 'label' => 'Kritis'];
        } elseif ($stock < 50) {
            return ['class' => 'bg-yellow-100 text-yellow-700', 'label' => 'Rendah'];
        } else {
            return ['class' => 'bg-green-100 text-green-700', 'label' => 'Aman'];
        }
    }
}
