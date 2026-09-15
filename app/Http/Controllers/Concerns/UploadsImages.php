<?php

namespace App\Http\Controllers\Concerns;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

trait UploadsImages
{
    /**
     * Store the uploaded "image" file under the given storage folder and
     * return an absolute URL built from the current request's host, so it
     * works no matter which address (localhost, LAN IP, hotspot IP) the
     * client used to reach the API.
     */
    private function storeUploadedImage(Request $request, string $folder): string
    {
        $request->validate([
            'image' => ['required', 'image', 'max:5120'],
        ]);

        $path = $request->file('image')->store($folder, 'public');

        return $request->getSchemeAndHttpHost().'/storage/'.$path;
    }

    /**
     * Best-effort delete of a previously uploaded image, given the full URL
     * that was stored on the model. Ignores anything that isn't one of our
     * own "/storage/..." uploads (e.g. an external URL).
     */
    private function forgetStoredImage(?string $url): void
    {
        if (!$url) {
            return;
        }

        $path = parse_url($url, PHP_URL_PATH);

        if (!$path || !str_starts_with($path, '/storage/')) {
            return;
        }

        Storage::disk('public')->delete(substr($path, strlen('/storage/')));
    }
}
