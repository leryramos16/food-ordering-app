<?php

namespace App\Services;

use App\Models\PhoneOtp;
use Illuminate\Validation\ValidationException;

class PhoneOtpService
{
    private const CODE_LENGTH = 6;

    private const EXPIRES_IN_MINUTES = 5;

    private const MAX_ATTEMPTS = 5;

    private const RESEND_COOLDOWN_SECONDS = 60;

    public function __construct(private SemaphoreSmsService $sms)
    {
    }

    /**
     * Generates a code, stores it (hashed) alongside the pending
     * registration payload, and texts it to the phone. Throws a
     * ValidationException the same way the rest of the app reports
     * user-facing errors, so controllers don't need special-case handling.
     */
    public function issue(string $phone, string $purpose, array $payload): void
    {
        $recent = PhoneOtp::where('phone', $phone)
            ->where('purpose', $purpose)
            ->whereNull('consumed_at')
            ->latest()
            ->first();

        if ($recent && $recent->created_at->diffInSeconds(now()) < self::RESEND_COOLDOWN_SECONDS) {
            $wait = self::RESEND_COOLDOWN_SECONDS - $recent->created_at->diffInSeconds(now());

            throw ValidationException::withMessages([
                'phone' => ["Please wait {$wait}s before requesting another code."],
            ]);
        }

        $code = (string) random_int(10 ** (self::CODE_LENGTH - 1), (10 ** self::CODE_LENGTH) - 1);

        // Send first, persist only on success — otherwise a failed send
        // (bad credentials, network blip) would still start the resend
        // cooldown and lock the user out of retrying for no reason.
        $sent = $this->sms->send(
            $phone,
            "Your Food Ordering verification code is {$code}. It expires in ".self::EXPIRES_IN_MINUTES.' minutes.',
        );

        if (!$sent) {
            throw ValidationException::withMessages([
                'phone' => ['Could not send the verification code. Please try again.'],
            ]);
        }

        PhoneOtp::create([
            'phone' => $phone,
            'code_hash' => hash('sha256', $code),
            'purpose' => $purpose,
            'payload' => $payload,
            'expires_at' => now()->addMinutes(self::EXPIRES_IN_MINUTES),
        ]);
    }

    /**
     * Verifies the code and, if correct, returns the payload that was
     * stashed when the code was issued and marks it consumed so it can't
     * be replayed.
     */
    public function verify(string $phone, string $purpose, string $code): array
    {
        $otp = PhoneOtp::where('phone', $phone)
            ->where('purpose', $purpose)
            ->whereNull('consumed_at')
            ->latest()
            ->first();

        if (!$otp || $otp->expires_at->isPast()) {
            throw ValidationException::withMessages([
                'code' => ['This code has expired. Request a new one.'],
            ]);
        }

        if ($otp->attempts >= self::MAX_ATTEMPTS) {
            throw ValidationException::withMessages([
                'code' => ['Too many incorrect attempts. Request a new code.'],
            ]);
        }

        if (!hash_equals($otp->code_hash, hash('sha256', $code))) {
            $otp->increment('attempts');

            throw ValidationException::withMessages([
                'code' => ['Incorrect code.'],
            ]);
        }

        $otp->update(['consumed_at' => now()]);

        return $otp->payload ?? [];
    }
}
