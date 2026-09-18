<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('phone_otps', function (Blueprint $table) {
            $table->id();

            $table->string('phone', 30)->index();

            // SHA-256 of the 6-digit code — never store the code itself.
            $table->string('code_hash', 64);

            $table->string('purpose', 30)->default('register');

            // The pending registration (name, email, phone, password, role)
            // encrypted at rest, since it briefly holds a plaintext password
            // until the code is verified and the real user account is made.
            $table->text('payload')->nullable();

            $table->unsignedTinyInteger('attempts')->default(0);

            $table->timestamp('expires_at');
            $table->timestamp('consumed_at')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('phone_otps');
    }
};
