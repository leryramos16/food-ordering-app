<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\DragonpayService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    public function initiate(Request $request, Order $order, DragonpayService $dragonpay): JsonResponse
    {
        abort_unless($order->user_id === $request->user()->id, 403);
        abort_if($order->payment_status === 'paid', 422, 'This order is already paid.');

        $order->update(['payment_method' => 'gcash']);

        $redirectUrl = $dragonpay->buildGcashPaymentUrl($order, $request->user()->email);

        return response()->json([
            'success' => true,
            'data' => ['redirect_url' => $redirectUrl],
        ]);
    }

    /**
     * Dragonpay calls this server-to-server once the customer finishes (or
     * abandons) the GCash payment. It expects a plain "result=OK" body back
     * to acknowledge receipt — anything else and it will retry.
     */
    public function postback(Request $request, DragonpayService $dragonpay)
    {
        $txnId = (string) $request->input('txnid');
        $refNo = (string) $request->input('refno');
        $status = (string) $request->input('status');
        $message = (string) $request->input('message');
        $digest = (string) $request->input('digest');

        $order = Order::where('order_number', $txnId)->first();

        if (!$order) {
            Log::warning('Dragonpay postback for unknown order', ['txnid' => $txnId]);

            return response('result=OK', 200)->header('Content-Type', 'text/plain');
        }

        if (!$dragonpay->verifyPostbackDigest($txnId, $refNo, $status, $message, $digest)) {
            Log::warning('Dragonpay postback failed digest check', ['txnid' => $txnId]);

            return response('result=OK', 200)->header('Content-Type', 'text/plain');
        }

        $order->update([
            'dragonpay_refno' => $refNo,
            'payment_status' => match ($status) {
                'S' => 'paid',
                'F', 'V' => 'failed',
                'P', 'U' => 'pending',
                default => $order->payment_status,
            },
        ]);

        return response('result=OK', 200)->header('Content-Type', 'text/plain');
    }

    /**
     * The customer's browser lands here after paying (or cancelling). The
     * mobile app's WebView watches for this URL to know the payment attempt
     * is over, then closes itself and re-checks the order's status — the
     * actual payment_status update already happened via postback() above,
     * since postback is server-to-server and not dependent on the customer
     * successfully returning to the app.
     */
    public function returnUrl(Request $request)
    {
        return response(
            '<!doctype html><html><body style="font-family: sans-serif; text-align: center; padding: 48px 16px;">'
            .'<h2>Thanks!</h2><p>You can return to the app now.</p>'
            .'</body></html>',
        )->header('Content-Type', 'text/html');
    }
}
