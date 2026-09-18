<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Dragonpay Merchant Credentials
    |--------------------------------------------------------------------------
    |
    | Sign up for a merchant account at https://www.dragonpay.ph to get
    | these. Their sandbox/test environment does not process real money,
    | so you can build and try this whole flow before Dragonpay approves
    | you for production (which is a separate, business-verification step).
    |
    */

    'merchant_id' => env('DRAGONPAY_MERCHANT_ID'),

    'merchant_password' => env('DRAGONPAY_MERCHANT_PASSWORD'),

    'testing' => env('DRAGONPAY_TESTING', true),

    'base_uri' => env('DRAGONPAY_TESTING', true)
        ? 'http://test.dragonpay.ph'
        : 'https://gw.dragonpay.ph',
];
