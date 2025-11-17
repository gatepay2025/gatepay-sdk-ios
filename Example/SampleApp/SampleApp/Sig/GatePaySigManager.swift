//
//  GatePaySigManager.swift
//  SampleApp
//
//  Created by Komi on 2025/9/25.
//

import Foundation
import GateOpenPaySDK

class GatePaySigManager {
    static func sigWith(prepayid: String, completion: @escaping (_ response: SigResponseObject) -> Void) {
        let request = SigRequest(baseUrl: Self.baseUrl(), prepayId: prepayid)
        let sessionDelegate = GTOPDSessionDelegate()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: OperationQueue.main)
        guard let urlRequest = request.getUrlRequest() else {
            return
        }
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if error != nil || data == nil {
                let response = SigResponseObject()
                response.code = 0
                completion(response)
            }
            guard let data = data else {
                let response = SigResponseObject()
                response.code = 0
                completion(response)
                return
            }
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(SigResponseObject.self, from: data)
                print("\(model.data?.bizData?.prepayId ?? "")")
                print("\(model.data?.bizData?.ts ?? 0)")
                print("\(model.data?.bizData?.signature ?? "")")
                print("\(model.data?.bizData?.nonce ?? "")")
                
                completion(model)
            } catch let error {
                let response = SigResponseObject()
                response.code = 0
                completion(response)
                print("\(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    static func baseUrl() -> String {
        let env = GTOPDEnvCacheManager.shared.currentEnvironment
        return env["url"] ?? ""
    }
}
