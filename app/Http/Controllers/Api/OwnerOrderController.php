<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class OwnerOrderController extends Controller
{
    /**
     * Which fulfillment statuses an order can move to next. Anything not
     * listed here (including jumping straight to "delivered", or touching
     * an order that's already "delivered"/"cancelled") is rejected — this
     * keeps the status a reliable timeline instead of a free-for-all field.
     */
    private const STATUS_TRANSITIONS = [
        'pending' => ['preparing', 'cancelled'],
        'preparing' => ['ready', 'cancelled'],
        'ready' => ['delivered'],
        'delivered' => [],
        'cancelled' => [],
    ];

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
        $this->authorizeOrder($request, $order);

        $order->load(['items', 'restaurant:id,name']);

        return (new OrderResource($order))
            ->additional(['success' => true])
            ->response();
    }

    public function updateStatus(Request $request, Order $order): JsonResponse
    {
        $this->authorizeOrder($request, $order);

        $data = $request->validate([
            'status' => [
                'required',
                Rule::in(['preparing', 'ready', 'delivered', 'cancelled']),
            ],
        ]);

        $allowed = self::STATUS_TRANSITIONS[$order->status] ?? [];

        if (!in_array($data['status'], $allowed, true)) {
            throw ValidationException::withMessages([
                'status' => [
                    "Cannot move an order from \"{$order->status}\" to \"{$data['status']}\".",
                ],
            ]);
        }

        $order->update(['status' => $data['status']]);

        return (new OrderResource($order->fresh(['items', 'restaurant:id,name'])))
            ->additional([
                'success' => true,
                'message' => 'Order status updated.',
            ])
            ->response();
    }

    public function markPaid(Request $request, Order $order): JsonResponse
    {
        $this->authorizeOrder($request, $order);

        if ($order->payment_method !== 'cash_on_delivery') {
            throw ValidationException::withMessages([
                'payment_status' => [
                    'Only cash-on-delivery orders can be marked paid manually — other payment methods confirm automatically.',
                ],
            ]);
        }

        if ($order->payment_status === 'paid') {
            throw ValidationException::withMessages([
                'payment_status' => ['This order is already marked paid.'],
            ]);
        }

        $order->update(['payment_status' => 'paid']);

        return (new OrderResource($order->fresh(['items', 'restaurant:id,name'])))
            ->additional([
                'success' => true,
                'message' => 'Order marked as paid.',
            ])
            ->response();
    }

    private function authorizeOrder(Request $request, Order $order): void
    {
        $restaurant = $request->user()->restaurants()->first();

        abort_unless($restaurant && $order->restaurant_id === $restaurant->id, 403);
    }
}
