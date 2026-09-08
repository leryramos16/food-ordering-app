<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\MenuItem;
use App\Models\Restaurant;
use App\Models\User;
use App\Models\Address;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class FoodOrderingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $owner = User::firstOrCreate(
            [
                'email' => 'leryramos16@example.com',
            ],
            [
                'name' => 'Ler Restaurant',
                'phone' => '09167965382',
                'password' => Hash::make('leryjrdev16'),
                'role' => 'restaurant_owner',
                'is_active' => true,
            ]
        );

        $customer = User::firstOrCreate(
            [
                'email' => 'caius7@gmail.com',
            ],
            [
                'name' => 'Caius Matthew',
                'phone' => '09509028833',
                'password' => Hash::make('caius7'),
                'role' => 'customer',
                'is_active' => true,
            ]
        );

        $restaurant = Restaurant::firstOrCreate(
            [
                'owner_id' => $owner->id,
                'name'     => "Ler Restaurant",
            ],
            [
                'description' => 'Lomi and other Silog Meals, Available here!',
                'phone' => '09167965382',
                'address' => 'Mabini, Batangas',
                'delivery_fee' => 50.00,
                'minimum_order' => 100.00,
                'is_open' => true,
                'is_active' => true,
            ]
        );

        $silog = Category::firstOrCreate(
            [
                'restaurant_id' => $restaurant->id,
                'name' => 'Silog Meals',
            ],
            [
                'sort_order' => 1,
                'is_active' => true,
            ]
        );

        $lomi = Category::firstOrCreate(
            [
                'restaurant_id' => $restaurant->id,
                'name' => 'Lomi',
            ],
            [
                'sort_order' => 2,
                'is_active' => true,
            ]
        );

        $drinks = Category::firstOrCreate(
            [
                'restaurant_id' => $restaurant->id,
                'name' => 'Drinks',
            ],
            [
                'sort_order' => 3,
                'is_active' => true,
            ]
        );

        MenuItem::firstOrCreate(
            [
                'category_id' => $silog->id,
                'name' => 'Tapsilog',
            ],
            [
                'description' => 'Delicious tapa, egg with fried rice.',
                'price' => 120.00,
                'is_available' => true,
                'preparation_time_minutes' => 20,
            ],
        );

         MenuItem::firstOrCreate(
            [
                'category_id' => $lomi->id,
                'name' => 'Overload Lomi',
            ],
            [
                'description' => 'Overload toppings lomi',
                'price' => 95.00,
                'is_available' => true,
                'preparation_time_minutes' => 10,
            ]
        );

        MenuItem::firstOrCreate(
            [
                'category_id' => $drinks->id,
                'name' => 'Coke',
            ],
            [
                'description' => 'Cold soft drink.',
                'price' => 35.00,
                'is_available' => true,
                'preparation_time_minutes' => 2,
            ]
        );

        MenuItem::firstOrCreate(
            [
                'category_id' => $drinks->id,
                'name' => 'Mountain Dew',
            ],
            [
                'description' => 'Cold soft drink.',
                'price' => 35.00,
                'is_available' => true,
                'preparation_time_minutes' => 2,
            ]
        );

        Address::firstOrCreate(
            [
                'user_id' => $customer->id,
                'label' => 'Home',
            ],
            [
                'recipient_name' => $customer->name,
                'phone' => $customer->phone,
                'address_line' => 'Tabliyahan',
                'barangay' => 'P.Niogan',
                'city' => 'Mabini',
                'province' => 'Batangas',
                'postal_code' => null,
                'is_default' => true,
            ]
        );
    }
}
