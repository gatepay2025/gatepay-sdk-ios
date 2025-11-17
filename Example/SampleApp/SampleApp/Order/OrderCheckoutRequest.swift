//
//  OrderCheckoutRequest.swift
//  SampleApp
//
//  Created by Komi on 2025/9/25.
//

import Foundation
import GateOpenPaySDK

class OrderCheckoutRequest {
    
    /// 模拟订单检出，商户需要自行根据后端开发文档构建订单检出流程
    func getUrlRequest(_ orderAmount: String = "9.9", _ currency: String = "USDT", _ chain: String = "ETH", _ payCurrency: String = "USDT", _ fulltype: String) -> URLRequest? {
        guard let baseUrl = URL(string: "https://example.com/") else {
            print("错误：无效的Base URL")
            return nil
        }

        let url = baseUrl.appendingPathComponent("checkout/order")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let apiKey = GTOPDEnvCacheManager.shared.clientId
        request.setValue(apiKey, forHTTPHeaderField: "X-GatePay-Certificate-ClientId")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        /// 根据商户后台SDK说明进行构建
        let body: [String: Codable] = [
            "merchantTradeNo": "bournetest-\(Int(Date.now.timeIntervalSince1970))",
            "currency": currency,
            "orderAmount": orderAmount,
            "payCurrency": payCurrency,
            "env": [
                "terminalType": "1234"
            ],
            "goods": [
                "goodsName": "autocheckout loragoodsName",
                "goodsDetail": "autocheckout loragoodsDetail"
            ],
            "returnUrl": "https://www.baidu.com",
            "cancelUrl": "www.baidu.com",
            "merchantUserId": 10002,
            "chain": chain,
            "fullCurrType": "\(fulltype)"
        ]

        /// 签名规则根据商户后台SDK说明
        let sign = GatePaySignatureGenerator().generateSignatureFromDictionary(secretKey: GTOPDEnvCacheManager.shared.signature, parameters: body)
        request.setValue("\(sign.timestamp)", forHTTPHeaderField: "X-GatePay-Timestamp")
        request.setValue("\(sign.nonce)", forHTTPHeaderField: "X-GatePay-Nonce")
        request.setValue(sign.signature, forHTTPHeaderField: "X-GatePay-Signature")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.sortedKeys, .withoutEscapingSlashes])
        } catch {
            print("错误：无法将请求体编码为JSON: \(error)")
            return nil
        }

        return request
    }
}
