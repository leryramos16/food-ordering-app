<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SemaphoreSmsService
{
    /**
     * Sends a single SMS via Semaphore. Returns false (never throws) on
     * failure so the caller can decide how to react — the failure is still
     * logged with the response body for debugging.
     */
    public function send(string $phoneNumber, string $message): bool
    {
        $response = Http::asForm()->post('https://api.semaphore.co/api/v4/messages', [
            'apikey' => config('semaphore.api_key'),
            'number' => $phoneNumber,
            'message' => $message,
            'sendername' => config('semaphore.sender_name'),
        ]);

        $decoded = $response->json();

        // Semaphore returns HTTP 200 even for validation/auth errors — a
        // real success is a JSON *array* of message objects. An error
        // instead comes back as an object keyed by field name, e.g.
        // {"apikey": ["The apikey field is required."]} — so the HTTP
        // status alone can't tell success from failure here.
        $succeeded = $response->successful()
            && is_array($decoded)
            && array_is_list($decoded)
            && !empty($decoded);

        if (!$succeeded) {
            Log::warning('Semaphore SMS send failed', [
                'phone' => $phoneNumber,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
        }

        return $succeeded;
    }
}
