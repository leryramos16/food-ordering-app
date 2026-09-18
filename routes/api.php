<?php

use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OwnerCategoryController;
use App\Http\Controllers\Api\OwnerMenuItemController;
use App\Http\Controllers\Api\OwnerOrderController;
use App\Http\Controllers\Api\OwnerRestaurantController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\RestaurantController;
use App\Http\Controllers\Api\OrderController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    // throttle:5,1 — these trigger a paid SMS send, so cap attempts per IP.
    Route::post('/register/request-otp', [AuthController::class, 'requestRegistrationOtp'])
        ->middleware('throttle:5,1');
    Route::post('/register/verify-otp', [AuthController::class, 'verifyRegistrationOtp'])
        ->middleware('throttle:10,1');

    // throttle:login — 5 attempts/min per (email, IP), see AppServiceProvider.
    Route::post('/login', [AuthController::class, 'login'])
        ->middleware('throttle:login');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::get('/restaurants', [
    RestaurantController::class, 
    'index',
]);

Route::get('/restaurants/{restaurant}', [
    RestaurantController::class,
    'show',
]);

Route::get('/restaurants/{restaurant}/menu', [
    RestaurantController::class,
    'menu',
]);

// Dragonpay calls these directly — not authenticated app requests, since
// Dragonpay's servers (not a logged-in user) are the caller. Living under
// /api keeps them in the stateless "api" middleware group, with no CSRF
// check to trip up a server-to-server webhook.
Route::any('/payments/dragonpay/postback', [PaymentController::class, 'postback']);
Route::get('/payments/dragonpay/return', [PaymentController::class, 'returnUrl']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::post('/orders/{order}/payment', [PaymentController::class, 'initiate']);

    Route::get('/addresses', [AddressController::class, 'index']);
    Route::post('/addresses', [AddressController::class, 'store']);
    Route::put('/addresses/{address}', [AddressController::class, 'update']);
    Route::delete('/addresses/{address}', [AddressController::class, 'destroy']);
});

Route::middleware(['auth:sanctum', 'role:restaurant_owner'])
    ->prefix('owner')
    ->group(function () {
        Route::get('/restaurant', [OwnerRestaurantController::class, 'show']);
        Route::post('/restaurant', [OwnerRestaurantController::class, 'store']);
        Route::put('/restaurant', [OwnerRestaurantController::class, 'update']);
        Route::post('/restaurant/image', [OwnerRestaurantController::class, 'uploadImage']);

        Route::get('/categories', [OwnerCategoryController::class, 'index']);
        Route::post('/categories', [OwnerCategoryController::class, 'store']);
        Route::put('/categories/{category}', [OwnerCategoryController::class, 'update']);
        Route::delete('/categories/{category}', [OwnerCategoryController::class, 'destroy']);

        Route::post(
            '/categories/{category}/menu-items',
            [OwnerMenuItemController::class, 'store'],
        );
        Route::put('/menu-items/{menuItem}', [OwnerMenuItemController::class, 'update']);
        Route::delete('/menu-items/{menuItem}', [OwnerMenuItemController::class, 'destroy']);
        Route::post(
            '/menu-items/{menuItem}/image',
            [OwnerMenuItemController::class, 'uploadImage'],
        );

        Route::get('/orders', [OwnerOrderController::class, 'index']);
        Route::get('/orders/{order}', [OwnerOrderController::class, 'show']);
        Route::patch('/orders/{order}/status', [OwnerOrderController::class, 'updateStatus']);
        Route::patch('/orders/{order}/mark-paid', [OwnerOrderController::class, 'markPaid']);
    });
