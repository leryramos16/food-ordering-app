<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MenuItemResource extends JsonResource
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

            'name' => $this->name,

            'description' => $this->description,

            'price' => (string) $this->price,

            'image_url' => $this->image_url,

            'is_available' => $this->is_available,

            'preparation_time_minutes' =>
                $this->preparation_time_minutes,

            'is_preorder' => $this->is_preorder,

            'preorder_lead_days' => $this->preorder_lead_days,
        ];
    }
}
