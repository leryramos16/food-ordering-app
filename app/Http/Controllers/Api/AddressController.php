<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreAddressRequest;
use App\Http\Requests\UpdateAddressRequest;
use App\Http\Resources\AddressResource;
use App\Models\Address;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;

class AddressController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $addresses = $request->user()
            ->addresses()
            ->orderByDesc('is_default')
            ->latest()
            ->get();

        return AddressResource::collection($addresses)
            ->additional(['success' => true]);
    }

    public function store(StoreAddressRequest $request): JsonResponse
    {
        $data = $request->validated();
        $user = $request->user();

        $address = DB::transaction(function () use ($data, $user) {
            if ($data['is_default'] ?? false) {
                $user->addresses()->update(['is_default' => false]);
            }

            return $user->addresses()->create($data);
        });

        return (new AddressResource($address))
            ->additional([
                'success' => true,
                'message' => 'Address added successfully.',
            ])
            ->response()
            ->setStatusCode(201);
    }

    public function update(UpdateAddressRequest $request, Address $address): JsonResponse
    {
        abort_unless($address->user_id === $request->user()->id, 403);

        $data = $request->validated();

        DB::transaction(function () use ($data, $address) {
            if ($data['is_default'] ?? false) {
                $address->user->addresses()
                    ->where('id', '!=', $address->id)
                    ->update(['is_default' => false]);
            }

            $address->update($data);
        });

        return (new AddressResource($address->fresh()))
            ->additional([
                'success' => true,
                'message' => 'Address updated successfully.',
            ])
            ->response();
    }

    public function destroy(Request $request, Address $address): JsonResponse
    {
        abort_unless($address->user_id === $request->user()->id, 403);

        $address->delete();

        return response()->json([
            'success' => true,
            'message' => 'Address removed successfully.',
        ]);
    }
}
