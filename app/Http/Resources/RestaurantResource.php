<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RestaurantResource extends JsonResource
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

            'phone' => $this->phone,

            'address' => $this->address,

            'latitude' => $this->latitude,

            'longitude' => $this->longitude,

            'delivery_fee' => (string) $this->delivery_fee,

            'minimum_order' => (string) $this->minimum_order,

            'image_url' => $this->image_url,

            'is_open' => $this->is_open,

            'categories' => CategoryResource::collection(
                $this->whenLoaded('categories')
            ),
        ];
    }
}
