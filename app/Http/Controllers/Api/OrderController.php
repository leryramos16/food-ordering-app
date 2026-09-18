<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Services\OrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class OrderController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $orders = $request->user()
            ->orders()
            ->with(['items', 'restaurant:id,name'])
            ->latest('placed_at')
            ->paginate(20);

        return OrderResource::collection($orders)
            ->additional(['success' => true]);
    }

    public function store(
        StoreOrderRequest $request,
        OrderService $orderService
    ): JsonResponse {

        $validated = $request->validated();

        $user = $request->user();

        $order = $orderService->place(
            $user,
            $validated
        );

        return (new OrderResource($order))
            ->additional([
                'success' => true,
                'message' => 'Order placed successfully.',
            ])
            ->response()
            ->setStatusCode(201);
    }

    public function show(Request $request, Order $order): JsonResponse
    {
        abort_unless($order->user_id === $request->user()->id, 403);

        $order->load(['items', 'restaurant:id,name']);

        return (new OrderResource($order))
            ->additional(['success' => true])
            ->response();
    }
}
