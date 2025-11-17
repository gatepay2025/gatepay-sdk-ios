//
//  SigResponse.swift
//  SampleApp
//
//  Created by Komi on 2025/9/25.
//

import Foundation

class SigResponseObject: Codable {
    var code: Int?
    var msg: String?
    var data: SigResponse?
    var pageCount: Int?
    var totalCount: Int?
    var message: String?
    var success: Bool?
    var label: String?
    var page: Int?
}


class SigResponse: Codable {
    var bizData: SigModel?
    var bizCode: String?
    var bizMessage: String?
    
}

class SigModel: Codable {
    var prepayId: String?
    var ts: TimeInterval?
    var nonce: String?
    var signature: String?
}
