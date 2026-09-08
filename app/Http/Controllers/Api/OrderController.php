<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\User;
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

        /*
         * TEMPORARY.
         *
         * After we implement Sanctum:
         *
         * $user = $request->user();
         */
        $user = User::findOrFail(
            $validated['user_id']
        );

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
