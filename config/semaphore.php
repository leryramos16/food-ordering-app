<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Semaphore SMS Credentials
    |--------------------------------------------------------------------------
    |
    | Sign up at https://semaphore.co to get an API key — no business
    | registration needed to create an account and buy a small starter
    | credit balance. Each OTP text costs 1 SMS credit.
    |
    */

    'api_key' => env('SEMAPHORE_API_KEY'),

    // Optional — falls back to your account's approved default sender name
    // if left blank. A custom sender name needs Semaphore's approval first.
    'sender_name' => env('SEMAPHORE_SENDER_NAME'),
];
