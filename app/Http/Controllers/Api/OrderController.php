<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreOrderRequest;
use App\Http\Resources\OrderResource;
use App\Services\OrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
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
}
