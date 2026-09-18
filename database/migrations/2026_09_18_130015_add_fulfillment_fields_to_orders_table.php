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
            $table->time('requested_time')->nullable()->after('requested_date');

            // 'delivery' or 'pickup' — only meaningful when is_preorder is
            // true; a regular (non-preorder) order is always delivery.
            $table->string('fulfillment_type', 20)->default('delivery')->after('requested_time');

            // Who to reach about a pre-order — bound from the customer's
            // account by default but editable, since the account holder
            // isn't always the right person to contact (e.g. gifting).
            $table->string('contact_name', 150)->nullable()->after('fulfillment_type');
            $table->string('contact_phone', 30)->nullable()->after('contact_name');

            // A pickup pre-order has no delivery address at all, so these
            // can no longer be guaranteed non-null.
            $table->string('delivery_recipient_name', 150)->nullable()->change();
            $table->string('delivery_phone', 30)->nullable()->change();
            $table->string('delivery_address_line', 255)->nullable()->change();
            $table->string('delivery_city', 120)->nullable()->change();
            $table->string('delivery_province', 120)->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'requested_time',
                'fulfillment_type',
                'contact_name',
                'contact_phone',
            ]);

            $table->string('delivery_recipient_name', 150)->nullable(false)->change();
            $table->string('delivery_phone', 30)->nullable(false)->change();
            $table->string('delivery_address_line', 255)->nullable(false)->change();
            $table->string('delivery_city', 120)->nullable(false)->change();
            $table->string('delivery_province', 120)->nullable(false)->change();
        });
    }
};
