//
//  OrderCheckoutResponse.swift
//  SampleApp
//
//  Created by Komi on 2025/9/26.
//

import Foundation

// MARK: - OrderCheckoutResponse

/// 订单支付预创建（Checkout）的完整响应模型
struct OrderCheckoutResponse: Codable {
    /// 响应状态码，"000000" 表示成功
    let code: String?
    /// 核心业务数据，仅在成功时非空
    let data: OrderCheckoutData?
    /// 响应状态，"SUCCESS" 表示成功
    let status: String?
    /// 错误信息，仅在失败时非空
    let errorMessage: String?
    /// 信息
    let label: String?
    /// 消息
    let message: String?
}

// MARK: - OrderCheckoutData

/// 订单支付预创建响应中的核心业务数据
struct OrderCheckoutData: Codable {
    /// 预支付ID，支付流程的唯一标识
    let prepayId: String?
    /// 终端类型，标识请求来源
    let terminalType: String?
    /// 过期时间戳（毫秒）
    let expireTime: TimeInterval?
    /// 二维码内容，可用于生成支付二维码
    let qrContent: String?
    /// 支付页面URL，可用于网页跳转
    let location: String?
    /// 支付货币类型，如 "USDT"
    let payCurrency: String?
    /// 支付金额（字符串形式，避免精度问题）
    let payAmount: String?
    /// 链信息，仅在链上支付时提供
    let chain: ChainInfo?
    /// 应用名称
    let appName: String?
    /// 应用Logo URL
    let appLogo: String?
    /// 商品名称
    let goodsName: String?
    /// 以USDT计价的金额
    let inUsdt: String?
}

// MARK: - ChainInfo

/// 链上支付相关的信息
struct ChainInfo: Codable {
    /// 收款地址
    let address: String?
    /// 完整的货币类型，如 "USDT_ETH"
    let fullCurrType: String?
    /// 链类型，如 "ETH"
    let chainType: String?
    
    // JSON中的key是 "chain_type"，而Swift中推荐使用驼峰命名法 "chainType"
    // CodingKeys枚举用于映射JSON key和Swift属性名
    enum CodingKeys: String, CodingKey {
        case address
        case fullCurrType
        case chainType = "chain_type"
    }
}
