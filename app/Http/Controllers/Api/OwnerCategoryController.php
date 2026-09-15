<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCategoryRequest;
use App\Http\Requests\UpdateCategoryRequest;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use App\Models\Restaurant;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Validation\ValidationException;

class OwnerCategoryController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $categories = $this->restaurant($request)
            ->categories()
            ->with('menuItems')
            ->orderBy('sort_order')
            ->get();

        return CategoryResource::collection($categories)
            ->additional(['success' => true]);
    }

    public function store(StoreCategoryRequest $request): JsonResponse
    {
        $restaurant = $this->restaurant($request);
        $data = $request->validated();

        if ($restaurant->categories()->where('name', $data['name'])->exists()) {
            throw ValidationException::withMessages([
                'name' => ['You already have a category with this name.'],
            ]);
        }

        $category = $restaurant->categories()->create($data);

        return (new CategoryResource($category))
            ->additional([
                'success' => true,
                'message' => 'Category created successfully.',
            ])
            ->response()
            ->setStatusCode(201);
    }

    public function update(UpdateCategoryRequest $request, Category $category): JsonResponse
    {
        $this->authorizeCategory($request, $category);

        $data = $request->validated();

        if (
            $category->restaurant->categories()
                ->where('name', $data['name'])
                ->where('id', '!=', $category->id)
                ->exists()
        ) {
            throw ValidationException::withMessages([
                'name' => ['You already have a category with this name.'],
            ]);
        }

        $category->update($data);

        return (new CategoryResource($category->fresh()))
            ->additional([
                'success' => true,
                'message' => 'Category updated successfully.',
            ])
            ->response();
    }

    public function destroy(Request $request, Category $category): JsonResponse
    {
        $this->authorizeCategory($request, $category);

        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Category deleted successfully.',
        ]);
    }

    private function restaurant(Request $request): Restaurant
    {
        $restaurant = $request->user()->restaurants()->first();

        if (!$restaurant) {
            throw ValidationException::withMessages([
                'restaurant' => ['Create your restaurant first.'],
            ]);
        }

        return $restaurant;
    }

    private function authorizeCategory(Request $request, Category $category): void
    {
        abort_unless(
            $category->restaurant_id === $this->restaurant($request)->id,
            403,
        );
    }
}
