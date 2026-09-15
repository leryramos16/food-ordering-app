<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Concerns\UploadsImages;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreMenuItemRequest;
use App\Http\Requests\UpdateMenuItemRequest;
use App\Http\Resources\MenuItemResource;
use App\Models\Category;
use App\Models\MenuItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OwnerMenuItemController extends Controller
{
    use UploadsImages;

    public function store(StoreMenuItemRequest $request, Category $category): JsonResponse
    {
        $this->authorizeCategory($request, $category);

        $menuItem = $category->menuItems()->create($request->validated());

        return (new MenuItemResource($menuItem))
            ->additional([
                'success' => true,
                'message' => 'Menu item added successfully.',
            ])
            ->response()
            ->setStatusCode(201);
    }

    public function update(UpdateMenuItemRequest $request, MenuItem $menuItem): JsonResponse
    {
        $this->authorizeMenuItem($request, $menuItem);

        $menuItem->update($request->validated());

        return (new MenuItemResource($menuItem->fresh()))
            ->additional([
                'success' => true,
                'message' => 'Menu item updated successfully.',
            ])
            ->response();
    }

    public function destroy(Request $request, MenuItem $menuItem): JsonResponse
    {
        $this->authorizeMenuItem($request, $menuItem);

        $menuItem->delete();

        return response()->json([
            'success' => true,
            'message' => 'Menu item deleted successfully.',
        ]);
    }

    public function uploadImage(Request $request, MenuItem $menuItem): JsonResponse
    {
        $this->authorizeMenuItem($request, $menuItem);

        $this->forgetStoredImage($menuItem->image_url);

        $menuItem->update([
            'image_url' => $this->storeUploadedImage($request, 'menu-items'),
        ]);

        return (new MenuItemResource($menuItem->fresh()))
            ->additional([
                'success' => true,
                'message' => 'Photo updated successfully.',
            ])
            ->response();
    }

    private function restaurantId(Request $request): ?int
    {
        return $request->user()->restaurants()->first()?->id;
    }

    private function authorizeCategory(Request $request, Category $category): void
    {
        abort_unless($category->restaurant_id === $this->restaurantId($request), 403);
    }

    private function authorizeMenuItem(Request $request, MenuItem $menuItem): void
    {
        abort_unless(
            $menuItem->category->restaurant_id === $this->restaurantId($request),
            403,
        );
    }
}
