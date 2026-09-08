<?php

use Illuminate\Http\Request;
use App\Http\Controllers\Api\RestaurantController;
use App\Http\Controllers\Api\OrderController;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

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

Route::post('/orders', [
    OrderController::class,
    'store',
]);
