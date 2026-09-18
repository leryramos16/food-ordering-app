<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            // Required now — SMS OTP verification needs a real number to
            // text the code to. PH mobile format: 09XXXXXXXXX (11 digits).
            'phone' => [
                'required',
                'string',
                'regex:/^09\d{9}$/',
                'unique:users,phone',
            ],
            'password' => ['required', 'confirmed', Password::min(8)],
            'role' => ['nullable', Rule::in(['customer', 'restaurant_owner'])],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }
}
