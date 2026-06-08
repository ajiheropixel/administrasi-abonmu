<?php

namespace App\Http\Controllers;

use App\Models\Employee;
use App\Models\Production;
use App\Models\Sale;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SalaryController extends Controller
{
    public function index(Request $request)
    {
        $startDate = $request->input('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->endOfMonth()->format('Y-m-d'));

        $employees = Employee::where('is_active', true)->get();
        
        $salaryData = [];
        
        foreach ($employees as $employee) {
            $productionCount = DB::table('production_employees')
                ->join('productions', 'production_employees.production_id', '=', 'productions.id')
                ->where('production_employees.employee_id', $employee->id)
                ->whereBetween('productions.production_date', [$startDate, $endDate])
                ->sum('productions.quantity');

            $packingCount = DB::table('sale_items')
                ->join('sales', 'sale_items.sale_id', '=', 'sales.id')
                ->whereBetween('sales.sale_date', [$startDate, $endDate])
                ->sum('sale_items.quantity');

            $productionSalary = $productionCount * $employee->production_rate;
            $packingSalary = $packingCount * $employee->packing_rate;
            $totalSalary = $productionSalary + $packingSalary;

            $salaryData[] = [
                'employee' => $employee,
                'production_count' => $productionCount,
                'packing_count' => $packingCount,
                'production_salary' => $productionSalary,
                'packing_salary' => $packingSalary,
                'total_salary' => $totalSalary
            ];
        }

        return view('salaries.index', compact('salaryData', 'startDate', 'endDate'));
    }
}
