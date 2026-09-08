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
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number', 30)->unique();
            $table->foreignId('user_id')
                ->constrained('users')
                ->restrictOnDelete();
            $table->foreignId('restaurant_id')
                ->constrained('restaurants')
                ->restrictOnDelete();
            $table->foreignId('address_id')
                ->nullable()
                ->constrained('addresses');
            
            // DELIVERY ADDRESS SNAPSHOT
             $table->string('delivery_recipient_name', 150);

            $table->string('delivery_phone', 30);

            $table->string('delivery_address_line', 255);

            $table->string('delivery_barangay', 120)->nullable();

            $table->string('delivery_city', 120);

            $table->string('delivery_province', 120);

            $table->string('delivery_postal_code', 20)->nullable();

            // ORDER STATE
            $table->string('status', 30)
                ->default('pending');

            /*
             * MONEY
             */
            $table->decimal('subtotal', 12, 2);

            $table->decimal('delivery_fee', 12, 2)
                ->default(0);

            $table->decimal('discount_amount', 12, 2)
                ->default(0);

            $table->decimal('total_amount', 12, 2);

             $table->string('payment_method', 30)
                ->default('cash_on_delivery');

            $table->string('payment_status', 30)
                ->default('unpaid');

            $table->text('notes')->nullable();

            $table->timestamp('placed_at')->nullable();

            $table->timestamps();
            
            $table->index([
                'restaurant_id',
                'status',
            ]);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
