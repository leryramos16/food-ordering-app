<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Str;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Same pattern Laravel's own Breeze/Fortify starter kits use: key
        // the limit on (email, IP) together, not just IP. Keying on IP
        // alone would let an attacker spread guesses for one account across
        // many IPs unthrottled; keying on email alone would let someone
        // lock a real user out just by spamming wrong passwords for their
        // address from anywhere.
        RateLimiter::for('login', function (Request $request) {
            $key = Str::lower((string) $request->input('email')).'|'.$request->ip();

            return Limit::perMinute(5)->by($key);
        });
    }
}
