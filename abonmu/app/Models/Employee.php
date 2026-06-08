<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Employee extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'phone',
        'address',
        'production_rate',
        'packing_rate',
        'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'production_rate' => 'decimal:2',
        'packing_rate' => 'decimal:2'
    ];

    public function productions()
    {
        return $this->belongsToMany(Production::class, 'production_employees');
    }
}
