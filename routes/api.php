<?php

use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OwnerCategoryController;
use App\Http\Controllers\Api\OwnerMenuItemController;
use App\Http\Controllers\Api\OwnerOrderController;
use App\Http\Controllers\Api\OwnerRestaurantController;
use App\Http\Controllers\Api\RestaurantController;
use App\Http\Controllers\Api\OrderController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

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

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/orders', [OrderController::class, 'store']);

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
    });
