<?php

namespace App\Services;

use App\Models\Address;
use App\Models\Category;
use App\Models\MenuItem;
use App\Models\Order;
use App\Models\Restaurant;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class OrderService
{
    public function place(User $user, array $data): Order
    {
        if(!$user->is_active) {
            throw ValidationException::withMessages([
                'account' => [
                    'This user account is not active'
                ],
            ]);
        }

        return DB::transaction(function () use ($user, $data) {
            // GET and Validate Restaurant
            $restaurant = Restaurant::query()
                ->whereKey($data['restaurant_id'])
                ->where('is_active', true)
                ->first();

            if (!$restaurant) {
                throw ValidationException::withMessages([
                    'restaurant_id' => [
                        'The selected restaurant is not available.'
                    ],
                ]);
            }

            if (!$restaurant->is_open) {
                throw ValidationException::withMessages([
                    'restaurant_id' => [
                        'The restaurant is currently closed.'
                    ],
                ]);
            }

            // Load requested menu items
            $requestedItems = collect($data['items']);

            $menuItemIds = $requestedItems
                ->pluck('menu_item_id')
                ->all();

            $menuItems = MenuItem::query()
                ->with('category:id,restaurant_id')
                ->whereIn('id', $menuItemIds)
                ->get()
                ->keyBy('id');

            // BUILD TRUSTED ORDER LINES
            $subtotalCents = 0;

            $orderLines = [];

            // The longest lead time among any pre-order item in this cart —
            // 0 means nothing here needs advance notice.
            $requiredLeadDays = 0;

            foreach ($requestedItems as $requestedItem) {
                
                $menuItemId = (int) $requestedItem['menu_item_id'];

                $quantity   = (int) $requestedItem['quantity'];

                $menuItem   = $menuItems->get($menuItemId);

                if (!$menuItem) {
                    throw ValidationException::withMessages([
                        'items' => [
                            "Menu item {$menuItemId} was not found.",
                        ],
                    ]);
                }

                if (!$menuItem->is_available) {
                    throw ValidationException::withMessages([
                        'items' => [
                            "{$menuItem->name} is currently unavailable.",
                        ],
                    ]);
                }

                // *menu_items -> category -> restaurant
                if ((int) $menuItem->category->restaurant_id !== (int) $restaurant->id) {
                    throw ValidationException::withMessages([
                        'items' => [
                            "{$menuItem->name} does not belong to the selected restaurant.",
                        ],
                    ]);
                }

                // IMPORTANT!: The price comes from database, not in Flutter
                $unitPriceCents = $this->moneyToCents($menuItem->price);

                $lineTotalCents = $unitPriceCents * $quantity;

                $subtotalCents += $lineTotalCents;

                if ($menuItem->is_preorder) {
                    $requiredLeadDays = max($requiredLeadDays, $menuItem->preorder_lead_days ?? 1);
                }

                $orderLines[] = [
                    'menu_item_id' => $menuItem->id,
                    'item_name'    => $menuItem->name,
                    'unit_price'   => $this->centsToMoney($unitPriceCents),
                    'quantity'     => $quantity,
                    'line_total'   => $this->centsToMoney($lineTotalCents),
                ];
            }

                // Check restaurant minimum order
                $minimumOrderCents =  $this->moneyToCents($restaurant->minimum_order);

                if ($subtotalCents < $minimumOrderCents) {
                    throw ValidationException::withMessages([
                        'items' => [
                            'The order does not meet the restaurant minimum order amount.',
                        ],
                    ]);
                }

                // If anything in the cart needs advance notice, a valid
                // requested_date meeting the longest lead time is mandatory,
                // along with a time, a fulfillment choice, and someone to
                // contact about it. A regular (non-preorder) order skips
                // all of this and behaves exactly as before.
                $isPreorder = $requiredLeadDays > 0;
                $requestedDate = null;
                $requestedTime = null;
                $fulfillmentType = 'delivery';
                $contactName = null;
                $contactPhone = null;

                if ($isPreorder) {
                    if (empty($data['requested_date'])) {
                        throw ValidationException::withMessages([
                            'requested_date' => [
                                "This order includes a pre-order item — pick a date at least {$requiredLeadDays} day(s) from now.",
                            ],
                        ]);
                    }

                    $requestedDate = Carbon::parse($data['requested_date'])->startOfDay();
                    $earliestDate = now()->addDays($requiredLeadDays)->startOfDay();

                    if ($requestedDate->lt($earliestDate)) {
                        throw ValidationException::withMessages([
                            'requested_date' => [
                                "The earliest available date for this order is {$earliestDate->toDateString()}.",
                            ],
                        ]);
                    }

                    if (empty($data['requested_time'])) {
                        throw ValidationException::withMessages([
                            'requested_time' => ['Pick a time for this order.'],
                        ]);
                    }

                    $requestedTime = $data['requested_time'];
                    $fulfillmentType = $data['fulfillment_type'] ?? 'delivery';

                    if (empty($data['contact_name']) || empty($data['contact_phone'])) {
                        throw ValidationException::withMessages([
                            'contact_name' => ['A contact name and phone number are required for a pre-order.'],
                        ]);
                    }

                    $contactName = $data['contact_name'];
                    $contactPhone = $data['contact_phone'];
                }

                // Delivery details: a real Address record unless this is a
                // pre-order being picked up, in which case there is none.
                $address = null;

                if ($fulfillmentType !== 'pickup') {
                    $address = Address::query()
                        ->whereKey($data['address_id'] ?? null)
                        ->where('user_id', $user->id)
                        ->first();

                    if (!$address) {
                        throw ValidationException::withMessages([
                            'address_id' => [
                                'The selected address does not belong to this user.',
                            ],
                        ]);
                    }
                }

                // Calculate authoritative totals. No delivery fee when the
                // customer is picking the order up themselves.
                $deliveryFeeCents = $fulfillmentType === 'pickup'
                    ? 0
                    : $this->moneyToCents($restaurant->delivery_fee);

                // Promotions implement soon.
                $discountCents = 0;

                $totalCents = $subtotalCents + $deliveryFeeCents - $discountCents;

                // CREATE ORDER
                $order = Order::create([
                    'order_number' =>
                        'ORD-' . (string) Str::ulid(),

                    'user_id' => $user->id,

                    'restaurant_id' => $restaurant->id,

                    'address_id' => $address?->id,

                    /*
                    * Delivery snapshot — from the chosen Address, or from
                    * the pre-order's contact info when there's no address
                    * at all (a pickup order).
                    */
                    'delivery_recipient_name' =>
                        $address?->recipient_name ?? $contactName,

                    'delivery_phone' =>
                        $address?->phone ?? $contactPhone,

                    'delivery_address_line' =>
                        $address?->address_line,

                    'delivery_barangay' =>
                        $address?->barangay,

                    'delivery_city' =>
                        $address?->city,

                    'delivery_province' =>
                        $address?->province,

                    'delivery_postal_code' =>
                        $address?->postal_code,

                    'status' => 'pending',

                    'is_preorder' => $isPreorder,
                    'requested_date' => $requestedDate,
                    'requested_time' => $requestedTime,
                    'fulfillment_type' => $fulfillmentType,
                    'contact_name' => $contactName,
                    'contact_phone' => $contactPhone,

                    'subtotal' =>
                        $this->centsToMoney($subtotalCents),

                    'delivery_fee' =>
                        $this->centsToMoney($deliveryFeeCents),

                    'discount_amount' =>
                        $this->centsToMoney($discountCents),

                    'total_amount' =>
                        $this->centsToMoney($totalCents),

                    'payment_method' =>
                        $data['payment_method'],

                    'payment_status' => 'unpaid',
                    
                    'notes' =>
                        $data['notes'] ?? null,

                    'placed_at' => now(),
                ]);

                //  Create order item snapshots.
                foreach ($orderLines as $orderLine) {
                    $order->items()->create($orderLine);
                }

                return $order->load([
                    'restaurant:id,name',
                    'items',
                ]);
            });
    }

    private function moneyToCents(string|int $amount): int
    {
        $amount = (string) $amount;

        [$whole, $fraction] = array_pad(
            explode('.', $amount, 2),
            2,
            ''
        );

        $fraction = substr(
            str_pad($fraction, 2, '0'),
            0,
            2
        );

        return ((int) $whole * 100)
            + (int) $fraction;
    }

    private function centsToMoney(int $cents): string
    {
        return sprintf(
            '%d.%02d',
            intdiv($cents, 100),
            $cents % 100
        );
    }


}
