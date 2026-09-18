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
        Schema::table('orders', function (Blueprint $table) {
            $table->boolean('is_preorder')->default(false)->after('status');

            // The date the customer wants this order fulfilled on — set
            // whenever the order contains at least one pre-order item.
            $table->date('requested_date')->nullable()->after('is_preorder');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['is_preorder', 'requested_date']);
        });
    }
};
