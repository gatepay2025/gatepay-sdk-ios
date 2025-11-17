//
//  GatePayEnvCacheManager.swift
//  SampleApp
//
//  Created by Komi on 2025/9/25.
//

import Foundation

class GTOPDEnvCacheManager: NSObject {
    // MARK: - 单例 (Singleton)

    /// 共享的单例实例
    @objc static let shared = GTOPDEnvCacheManager()
    
    /// 只能用于测试，商户需要更新到注册的clientid
    var clientId: String = ""
    var signature: String = ""

    // 防止外部通过 init 创建实例，保证单例的唯一性
    override private init() {
        super.init()
        setupDefaultEnvironments()
    }

    // MARK: - 环境数据

    /// 存储所有环境配置的数组
    var envArray: [[String: String]] = []

    /// 当前选中的环境配置
    @objc var currentEnvironment: [String: String] {
        let envIndex = readEnvironment()
        if envArray.count > envIndex {
            return envArray[envIndex]
        }
        return [:]
    }

    // MARK: - 初始化

    /// 设置默认的环境数据
    private func setupDefaultEnvironments() {
        envArray = [
            [
                "name": "生产",
                "url": "https://your.service.com/",
                "client_id": ""
            ]
        ]
    }

    // MARK: - UserDefaults 操作

    /// 从 UserDefaults 读取当前选中的环境索引
    @objc func readEnvironment() -> Int {
        return UserDefaults.standard.integer(forKey: "SelectedEnvironment")
    }

    /// 将选中的环境索引保存到 UserDefaults
    @objc func saveEnvironment(_ environment: Int) {
        UserDefaults.standard.set(environment, forKey: "SelectedEnvironment")
        UserDefaults.standard.synchronize()
    }
}
