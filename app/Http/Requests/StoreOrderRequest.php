<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreOrderRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'restaurant_id' => [
                'required',
                'integer',
                'exists:restaurants,id',
            ],

             'address_id' => [
                // Not required for a pre-order being picked up — otherwise
                // (a regular order, or a pre-order being delivered) it is.
                Rule::requiredIf(fn () => $this->input('fulfillment_type') !== 'pickup'),
                'nullable',
                'integer',
                'exists:addresses,id',
            ],

            'payment_method' => [
                'required',
                Rule::in([
                    'cash_on_delivery',
                    'gcash',
                ]),
            ],

            'notes' => [
                'nullable',
                'string',
                'max:500',
            ],

            // Only actually required when the cart has a pre-order item —
            // OrderService checks that against each item's lead time, since
            // that depends on which menu items were ordered.
            'requested_date' => [
                'nullable',
                'date',
                'after_or_equal:today',
            ],

            'requested_time' => [
                'nullable',
                'date_format:H:i',
            ],

            'fulfillment_type' => [
                'nullable',
                Rule::in(['delivery', 'pickup']),
            ],

            // Only actually required for a pre-order — OrderService checks
            // that, same reasoning as requested_date above.
            'contact_name' => [
                'nullable',
                'string',
                'max:150',
            ],

            'contact_phone' => [
                'nullable',
                'string',
                'regex:/^09\d{9}$/',
            ],

            'items' => [
                'required',
                'array',
                'min:1',
            ],

            'items.*.menu_item_id' => [
                'required',
                'integer',
                'distinct',
                'exists:menu_items,id',
            ],

            'items.*.quantity' => [
                'required',
                'integer',
                'min:1',
                'max:99',
            ],
        ];
    }
}
