//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Komi on 2025/9/12.
//

import UIKit
import GateOpenPaySDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 在appdelegate注册，或者使用之前注册
        GatePaySDK.shared.regist(isDebug: false, clientId: GTOPDEnvCacheManager.shared.clientId)
        GatePaySDK.shared.setCurrentMode(isDarkMode: false, language: .cn)
        // 按照文档进行设置，groupId需要设置正确，否则会Crash。
        GatePaySDK.shared.setWalletConnect(groupId: "group.com.Komi.SampleApp", projectName: "SampleApp", projectIcon: "https://yourApp.png", appUrl: "www.gate.com")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

