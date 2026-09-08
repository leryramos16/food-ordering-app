<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
       return [
            'id' => $this->id,

            'order_number' => $this->order_number,

            'status' => $this->status,

            'restaurant' => $this->whenLoaded(
                'restaurant',
                function () {
                    return [
                        'id' => $this->restaurant->id,
                        'name' => $this->restaurant->name,
                    ];
                }
            ),

            'delivery_address' => [
                'recipient_name' =>
                    $this->delivery_recipient_name,

                'phone' =>
                    $this->delivery_phone,

                'address_line' =>
                    $this->delivery_address_line,

                'barangay' =>
                    $this->delivery_barangay,

                'city' =>
                    $this->delivery_city,

                'province' =>
                    $this->delivery_province,

                'postal_code' =>
                    $this->delivery_postal_code,
            ],

            'subtotal' =>
                (string) $this->subtotal,

            'delivery_fee' =>
                (string) $this->delivery_fee,

            'discount_amount' =>
                (string) $this->discount_amount,

            'total_amount' =>
                (string) $this->total_amount,

            'payment_method' =>
                $this->payment_method,

            'payment_status' =>
                $this->payment_status,

            'notes' =>
                $this->notes,

            'placed_at' =>
                $this->placed_at?->toISOString(),

            'items' =>
                OrderItemResource::collection(
                    $this->whenLoaded('items')
                ),
        ];
    }
}
