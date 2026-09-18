<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\PhoneOtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Step 1 of registration: validate the form, then text a verification
     * code to the phone. No account exists yet — a dummy sign-up that
     * never verifies simply never becomes a user.
     */
    public function requestRegistrationOtp(RegisterRequest $request, PhoneOtpService $otpService): JsonResponse
    {
        $data = $request->validated();

        $otpService->issue($data['phone'], 'register', [
            'name' => $data['name'],
            'email' => strtolower($data['email']),
            'phone' => $data['phone'],
            'password' => $data['password'],
            'role' => $data['role'] ?? 'customer',
            'device_name' => $data['device_name'] ?? 'flutter-app',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'A verification code was sent to your phone.',
        ]);
    }

    /**
     * Step 2: check the code, then create the account from the payload
     * that was stashed when the code was issued, and log them straight in.
     */
    public function verifyRegistrationOtp(Request $request, PhoneOtpService $otpService): JsonResponse
    {
        $validated = $request->validate([
            'phone' => ['required', 'string'],
            'code' => ['required', 'string', 'size:6'],
        ]);

        $payload = $otpService->verify($validated['phone'], 'register', $validated['code']);

        if (User::where('phone', $payload['phone'])->exists() || User::where('email', $payload['email'])->exists()) {
            throw ValidationException::withMessages([
                'phone' => ['This account was already created. Try logging in instead.'],
            ]);
        }

        $user = User::create([
            'name' => $payload['name'],
            'email' => $payload['email'],
            'phone' => $payload['phone'],
            'password' => $payload['password'],
            'role' => $payload['role'],
            'is_active' => true,
        ]);

        return $this->authenticatedResponse(
            $user,
            $payload['device_name'] ?? 'flutter-app',
            'Account created successfully.',
            201,
        );
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $data = $request->validated();
        $user = User::where('email', strtolower($data['email']))->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if (!$user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['This account is inactive.'],
            ]);
        }

        return $this->authenticatedResponse(
            $user,
            $data['device_name'] ?? 'flutter-app',
            'Logged in successfully.',
        );
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => ['user' => new UserResource($request->user())],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully.',
        ]);
    }

    private function authenticatedResponse(
        User $user,
        string $deviceName,
        string $message,
        int $status = 200,
    ): JsonResponse {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => [
                'user' => new UserResource($user),
                'token' => $user->createToken($deviceName)->plainTextToken,
                'token_type' => 'Bearer',
            ],
        ], $status);
    }
}
