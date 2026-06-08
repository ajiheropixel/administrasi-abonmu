<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use Illuminate\Http\Request;

class EmployeeApiController extends Controller
{
    /**
     * Get all employees
     */
    public function index(Request $request)
    {
        $query = Employee::query();
        
        // Search by name
        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }
        
        // Filter by position
        if ($request->filled('position')) {
            $query->where('position', $request->position);
        }
        
        // Pagination
        $perPage = $request->input('per_page', 15);
        $employees = $query->latest()->paginate($perPage);
        
        return response()->json([
            'success' => true,
            'data' => $employees->items(),
            'pagination' => [
                'current_page' => $employees->currentPage(),
                'last_page' => $employees->lastPage(),
                'per_page' => $employees->perPage(),
                'total' => $employees->total(),
            ]
        ]);
    }

    /**
     * Get single employee
     */
    public function show($id)
    {
        $employee = Employee::find($id);
        
        if (!$employee) {
            return response()->json([
                'success' => false,
                'message' => 'Karyawan tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'data' => $employee
        ]);
    }

    /**
     * Create new employee (Admin only)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'position' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'salary' => 'required|numeric|min:0'
        ]);

        $employee = Employee::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Karyawan berhasil ditambahkan',
            'data' => $employee
        ], 201);
    }

    /**
     * Update employee (Admin only)
     */
    public function update(Request $request, $id)
    {
        $employee = Employee::find($id);
        
        if (!$employee) {
            return response()->json([
                'success' => false,
                'message' => 'Karyawan tidak ditemukan'
            ], 404);
        }
        
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'position' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'salary' => 'required|numeric|min:0'
        ]);

        $employee->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Karyawan berhasil diperbarui',
            'data' => $employee
        ]);
    }

    /**
     * Delete employee (Admin only)
     */
    public function destroy($id)
    {
        $employee = Employee::find($id);
        
        if (!$employee) {
            return response()->json([
                'success' => false,
                'message' => 'Karyawan tidak ditemukan'
            ], 404);
        }
        
        $employee->delete();

        return response()->json([
            'success' => true,
            'message' => 'Karyawan berhasil dihapus'
        ]);
    }
}
