//
//  GatePayFloatingBall.swift
//  SampleApp
//
//  Created by Komi on 2025/9/25.
//

import UIKit

class GTOPDFloatingBall: UIButton {

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// 初始化视图和属性
    private func setupView() {
        // 设置背景色和圆角
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        layer.cornerRadius = frame.width / 2
        
        // 设置按钮标题
        setTitle("Env", for: .normal)
        
        // 添加点击事件
        addTarget(self, action: #selector(showEnvironmentMenu), for: .touchUpInside)
        
        // 添加拖动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - Action Handlers
    
    /// 显示环境选择菜单
    @objc private func showEnvironmentMenu() {
        let envManager = GTOPDEnvCacheManager.shared
        let currentEnv = envManager.currentEnvironment
        let title = currentEnv["name"] ?? "Unknown"
        
        let alertController = UIAlertController(
            title: "ENV:\(title)",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        // 遍历所有环境，添加选择按钮
        for (index, env) in envManager.envArray.enumerated() {
            let envTitle = env["name"] ?? "Env \(index)"
            let action = UIAlertAction(title: envTitle, style: .default) { _ in
                envManager.saveEnvironment(index)
            }
            alertController.addAction(action)
        }
        
        // 添加取消按钮
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 获取当前的顶层视图控制器并弹出菜单
        if let topController = UIApplication.shared.keyWindow?.rootViewController?.topmostViewController {
            // 在 iPad 上，必须设置 popoverPresentationController 的 sourceView 和 sourceRect
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self
                popoverController.sourceRect = self.bounds
            }
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// 处理拖动手势，实现悬浮球移动
    @objc private func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        
        let translation = panGesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        panGesture.setTranslation(.zero, in: superview)
    }
    
    // 为了防止按钮在拖动时被高亮，可以覆盖这个方法
    override var isHighlighted: Bool {
        get { return false }
        set {}
    }
}

// MARK: - UIViewController Extension

/// 一个方便的扩展，用于获取最顶层的视图控制器
extension UIViewController {
    var topmostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topmostViewController
        }
        // 处理 UINavigationController, UITabBarController 等容器视图控制器
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topmostViewController ?? navigation
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topmostViewController ?? tab
        }
        return self
    }
}
