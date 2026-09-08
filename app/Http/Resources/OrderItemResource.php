<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderItemResource extends JsonResource
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

            'menu_item_id' => $this->menu_item_id,

            'name' => $this->item_name,

            'unit_price' => (string) $this->unit_price,

            'quantity' => $this->quantity,

            'line_total' => (string) $this->line_total,

            'notes' => $this->notes,
        ];
    }
}
