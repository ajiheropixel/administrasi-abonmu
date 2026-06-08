<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'category',
        'description',
        'price',
        'stock',
        'unit',
        'image',
    ];

    /**
     * URL gambar via endpoint API — agar Flutter Web (Chrome) tidak kena CORS
     * Path: /api/v1/image/products/xxx.jpg
     */
    public function getImageUrlAttribute(): ?string
    {
        if (!$this->image) return null;
        return url('api/v1/image/' . $this->image);
    }

    protected $appends = ['image_url'];

    public function productions()
    {
        return $this->hasMany(Production::class);
    }

    public function saleItems()
    {
        return $this->hasMany(SaleItem::class);
    }
}
