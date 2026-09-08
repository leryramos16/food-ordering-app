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
             // TEMPORARY.
            // Authentication will replace this later.
            'user_id' => [
                'required',
                'integer',
                'exists:users,id',
            ],

            'restaurant_id' => [
                'required',
                'integer',
                'exists:restaurants,id',
            ],

             'address_id' => [
                'required',
                'integer',
                'exists:addresses,id',
            ],

            'payment_method' => [
                'required',
                Rule::in([
                    'cash_on_delivery',
                ]),
            ],

            'notes' => [
                'nullable',
                'string',
                'max:500',
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
