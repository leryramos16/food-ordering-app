<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;


class MenuItem extends Model
{
    protected $fillable = [
        'category_id',
        'name',
        'description',
        'price',
        'image_url',
        'is_available',
        'preparation_time_minutes',
        'is_preorder',
        'preorder_lead_days',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'is_available' => 'boolean',
            'preparation_time_minutes' => 'integer',
            'is_preorder' => 'boolean',
            'preorder_lead_days' => 'integer',
        ];
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
