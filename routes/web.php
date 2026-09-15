<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

Route::get('/', function () {
    return view('welcome');
});

// Serves files from the "public" disk directly, without depending on the
// storage:link symlink — `php artisan storage:link` needs elevated
// permissions on Windows (Developer Mode or admin), so this keeps uploaded
// photos working in local dev either way.
Route::get('/storage/{path}', function (string $path) {
    abort_unless(Storage::disk('public')->exists($path), 404);

    return Storage::disk('public')->response($path);
})->where('path', '.*');
