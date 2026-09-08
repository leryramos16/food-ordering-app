<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RestaurantResource;
use App\Models\Restaurant;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Request;

class RestaurantController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        $restaurants = Restaurant::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->paginate(10);

        return RestaurantResource::collection($restaurants)
            ->additional([
                'success' => true,
            ]);
    }

    public function show(Restaurant $restaurant): RestaurantResource
    {
        abort_unless($restaurant->is_active, 404);

        return (new RestaurantResource($restaurant))
            ->additional([
                'success' => true,
            ]);
    }

    public function menu(Restaurant $restaurant): RestaurantResource
    {
        abort_unless($restaurant->is_active, 404);

        $restaurant->load([
            'categories' => function ($query) {
                $query
                    ->where('is_active', true)
                    ->orderBy('sort_order');
            },

            'categories.menuItems' => function ($query) {
                $query
                    ->where('is_available', true)
                    ->orderBy('name');
            },
        ]);

        return (new RestaurantResource($restaurant))
            ->additional([
                'success' => true,
            ]);
    }
}
