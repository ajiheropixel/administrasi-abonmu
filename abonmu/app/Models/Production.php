<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Production extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'production_date',
        'quantity',
        'type',
        'category',
        'notes',
        'created_by',
        'updated_by',
    ];

    protected $casts = [
        'production_date' => 'date'
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function employees()
    {
        return $this->belongsToMany(Employee::class, 'production_employees');
    }

    public function expenses()
    {
        return $this->hasMany(Expense::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(\App\Models\User::class, 'created_by');
    }

    public function updatedBy()
    {
        return $this->belongsTo(\App\Models\User::class, 'updated_by');
    }

    protected static function booted()
    {
        static::created(function ($production) {
            $production->product->increment('stock', $production->quantity);
        });

        static::deleted(function ($production) {
            $production->product->decrement('stock', $production->quantity);
        });
    }
}
