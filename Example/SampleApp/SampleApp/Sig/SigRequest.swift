//
//  SigRequest.swift
//  SampleApp
//
//  Created by Komi on 2025/9/25.
//

import Foundation

struct SigRequest {
    let baseUrl: String
    let prepayId: String
    var urlRequest: URLRequest?
    
    /// 这个api只用于gate内部测试，商户需要参考后端开发文档，拿到正确的签名校验
    func getUrlRequest() -> URLRequest? {
        // 1. 构建完整的URL
        guard let baseUrl = URL(string: baseUrl) else {
            print("错误：无效的Base URL")
            return nil
        }
        // 去服务器拿签名的地址
        let url = baseUrl.appendingPathComponent("your/sign")

        // 2. 创建URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 3. 添加自定义Header
        let apiKey = GTOPDEnvCacheManager.shared.clientId
        request.setValue(apiKey, forHTTPHeaderField: "X-GatePay-Certificate-SN")

        let jsonString = "{\"prepayid\":\"\(prepayId)\",\"package_ext\":\"GatePay\"}"

        request.httpBody = jsonString.data(using: .utf8)

        return request
    }
}
