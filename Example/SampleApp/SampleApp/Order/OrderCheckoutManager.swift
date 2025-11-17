//
//  OrderCheckoutManager.swift
//  SampleApp
//
//  Created by Komi on 2025/9/25.
//

import Foundation
import GateOpenPaySDK

class OrderCheckoutManager {
    static func checkoutOrder(amount: String, currency: String, chain: String, payCurrency: String, fulltype: String, completion: @escaping (_ response: OrderCheckoutResponse) -> Void) {
        let request = OrderCheckoutRequest()
        let sessionDelegate = GTOPDSessionDelegate()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: OperationQueue.main)
        guard let urlRequest = request.getUrlRequest(amount, currency, chain, payCurrency, fulltype) else {
            return
        }
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                print("❌----订单检出错误：\(error?.localizedDescription ?? "")")
                return
            }
            
            do {
                let model = try JSONDecoder().decode(OrderCheckoutResponse.self, from: data)
                completion(model)
            } catch let error {
                print("❌----订单解析错误：\(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
}

class GTOPDSessionDelegate: NSObject, URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                return
            }
            let credential = URLCredential.init(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
}
