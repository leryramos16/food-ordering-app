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
        Schema::table('menu_items', function (Blueprint $table) {
            $table->boolean('is_preorder')->default(false)->after('is_available');

            // How many days' notice this item needs — e.g. a custom cake
            // might need 2 days. Only meaningful when is_preorder is true.
            $table->unsignedTinyInteger('preorder_lead_days')
                ->nullable()
                ->after('is_preorder');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('menu_items', function (Blueprint $table) {
            $table->dropColumn(['is_preorder', 'preorder_lead_days']);
        });
    }
};
