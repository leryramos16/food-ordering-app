<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreRestaurantRequest;
use App\Http\Requests\UpdateRestaurantRequest;
use App\Http\Resources\RestaurantResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class OwnerRestaurantController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $restaurant = $request->user()->restaurants()->first();

        return response()->json([
            'success' => true,
            'data' => $restaurant ? new RestaurantResource($restaurant) : null,
        ]);
    }

    public function store(StoreRestaurantRequest $request): JsonResponse
    {
        $user = $request->user();

        if ($user->restaurants()->exists()) {
            throw ValidationException::withMessages([
                'restaurant' => ['You already have a restaurant registered.'],
            ]);
        }

        $restaurant = $user->restaurants()->create([
            ...$request->validated(),
            'is_active' => true,
        ]);

        return (new RestaurantResource($restaurant))
            ->additional([
                'success' => true,
                'message' => 'Restaurant created successfully.',
            ])
            ->response()
            ->setStatusCode(201);
    }

    public function update(UpdateRestaurantRequest $request): JsonResponse
    {
        $restaurant = $request->user()->restaurants()->first();

        abort_unless($restaurant, 404, 'You do not have a restaurant yet.');

        $restaurant->update($request->validated());

        return (new RestaurantResource($restaurant->fresh()))
            ->additional([
                'success' => true,
                'message' => 'Restaurant updated successfully.',
            ])
            ->response();
    }
}
