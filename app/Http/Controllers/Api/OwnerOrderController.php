<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class OwnerOrderController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $restaurant = $request->user()->restaurants()->first();

        abort_unless($restaurant, 404, 'You do not have a restaurant yet.');

        $orders = $restaurant->orders()
            ->with(['items', 'restaurant:id,name'])
            ->latest('placed_at')
            ->paginate(20);

        return OrderResource::collection($orders)
            ->additional(['success' => true]);
    }

    public function show(Request $request, Order $order): JsonResponse
    {
        $restaurant = $request->user()->restaurants()->first();

        abort_unless($restaurant && $order->restaurant_id === $restaurant->id, 403);

        $order->load(['items', 'restaurant:id,name']);

        return (new OrderResource($order))
            ->additional(['success' => true])
            ->response();
    }
}
