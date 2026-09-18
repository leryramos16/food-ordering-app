<?php

namespace App\Services;

use App\Models\Order;

class DragonpayService
{
    /**
     * Build the URL to redirect the customer to in order to pay via
     * Dragonpay. `procid=GCSH` sends them straight into the GCash flow,
     * skipping Dragonpay's channel-selection page.
     */
    public function buildGcashPaymentUrl(Order $order, string $email): string
    {
        $params = [
            'merchantid' => config('dragonpay.merchant_id'),
            'txnid' => $order->order_number,
            'amount' => number_format((float) $order->total_amount, 2, '.', ''),
            'ccy' => 'PHP',
            'description' => "Order {$order->order_number}",
            'email' => $email,
        ];

        $params['digest'] = $this->buildRequestDigest($params);

        return config('dragonpay.base_uri').'/Pay.aspx?'.http_build_query($params).'&procid=GCSH';
    }

    /**
     * Verify a postback's digest matches what Dragonpay would have
     * generated with our shared secret — proof the postback really came
     * from Dragonpay and wasn't spoofed by a third party.
     */
    public function verifyPostbackDigest(string $txnId, string $refNo, string $status, string $message, string $digest): bool
    {
        $expected = sha1(implode(':', [
            $txnId,
            $refNo,
            $status,
            $message,
            config('dragonpay.merchant_password'),
        ]));

        return hash_equals($expected, $digest);
    }

    private function buildRequestDigest(array $params): string
    {
        $message = implode(':', [
            $params['merchantid'],
            $params['txnid'],
            $params['amount'],
            $params['ccy'],
            $params['description'],
            $params['email'],
            config('dragonpay.merchant_password'),
        ]);

        return sha1($message);
    }
}
