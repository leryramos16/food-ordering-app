<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_register_and_receive_a_token(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Ana Cruz',
            'email' => 'ana@example.com',
            'phone' => '09123456789',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'device_name' => 'test-phone',
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.email', 'ana@example.com')
            ->assertJsonStructure(['data' => ['user', 'token', 'token_type']]);

        $this->assertDatabaseHas('users', [
            'email' => 'ana@example.com',
            'role' => 'customer',
        ]);
    }

    public function test_customer_can_login_view_profile_and_logout(): void
    {
        $user = User::factory()->create([
            'password' => 'password123',
            'is_active' => true,
        ]);

        $login = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
        ])->assertOk();

        $token = $login->json('data.token');

        $this->withToken($token)
            ->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('data.user.id', $user->id);

        $this->withToken($token)
            ->postJson('/api/auth/logout')
            ->assertOk();

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_login_rejects_bad_credentials(): void
    {
        User::factory()->create(['email' => 'ana@example.com']);

        $this->postJson('/api/auth/login', [
            'email' => 'ana@example.com',
            'password' => 'wrong-password',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('email');
    }

    public function test_orders_require_authentication(): void
    {
        $this->postJson('/api/orders', [])->assertUnauthorized();
    }
}
