<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    protected $fillable = [
        'order_number',
        'user_id',
        'restaurant_id',
        'address_id',

        'delivery_recipient_name',
        'delivery_phone',
        'delivery_address_line',
        'delivery_barangay',
        'delivery_city',
        'delivery_province',
        'delivery_postal_code',

        'status',
        'is_preorder',
        'requested_date',
        'requested_time',
        'fulfillment_type',
        'contact_name',
        'contact_phone',

        'subtotal',
        'delivery_fee',
        'discount_amount',
        'total_amount',

        'payment_method',
        'payment_status',
        'dragonpay_refno',

        'notes',
        'placed_at',
    ];

    protected function casts(): array
    {
        return [
            'subtotal' => 'decimal:2',
            'delivery_fee' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
            'placed_at' => 'datetime',
            'is_preorder' => 'boolean',
            'requested_date' => 'date',
        ];
    }

     public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function restaurant(): BelongsTo
    {
        return $this->belongsTo(Restaurant::class);
    }

    public function address(): BelongsTo
    {
        return $this->belongsTo(Address::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }
}
