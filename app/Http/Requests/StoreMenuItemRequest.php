<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreMenuItemRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'numeric', 'min:0'],
            'image_url' => ['nullable', 'string', 'max:255'],
            'is_available' => ['nullable', 'boolean'],
            'preparation_time_minutes' => ['nullable', 'integer', 'min:0'],
            'is_preorder' => ['nullable', 'boolean'],
            'preorder_lead_days' => [
                'nullable',
                'integer',
                'min:1',
                'max:60',
                Rule::requiredIf($this->boolean('is_preorder')),
            ],
        ];
    }
}
