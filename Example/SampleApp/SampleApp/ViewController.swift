//
//  ViewController.swift
//  SampleApp
//
//  Created by Komi on 2025/9/12.
//

/// 自行采用合理的方式引入SDK进行调试
import GateOpenPaySDK
import UIKit

class ViewController: UIViewController {

    let orderIdTextField = UITextField()

    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // 当前语言状态
    var currentLanguage: LanguageCode = .cn
    
    // 支持的语言列表
    let supportedLanguages: [(code: LanguageCode, name: String)] = [
        (.en, "English"),
        (.cn, "简体中文"),
        (.cntw, "繁體中文"),
        (.ar, "العربية"),
        (.de, "Deutsch"),
        (.es, "Español"),
        (.fr, "Français"),
        (.id, "Bahasa Indonesia"),
        (.it, "Italiano"),
        (.ja, "日本語"),
        (.br, "Português (Brasil)"),
        (.pt, "Português (Portugal)"),
        (.ru, "Русский"),
        (.tr, "Türkçe"),
        (.uk, "Українська"),
        (.vi, "Tiếng Việt")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "PaySDK Test"

        configureTextField(orderIdTextField, placeholder: "请输入订单ID")
        let orderIdGroup = createInputGroup(title: "订单ID", textField: orderIdTextField)

        // 开始支付按钮
        let startPaymentBtn = UIButton(type: .system)
        startPaymentBtn.setTitle("开始支付", for: .normal)
        startPaymentBtn.backgroundColor = .systemPurple
        startPaymentBtn.setTitleColor(.white, for: .normal)
        startPaymentBtn.layer.cornerRadius = 8
        startPaymentBtn.translatesAutoresizingMaskIntoConstraints = false
        startPaymentBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startPaymentBtn.addTarget(self, action: #selector(startPayment), for: .touchUpInside)

        // 创建按钮组
        let buttonGroup = UIStackView(arrangedSubviews: [startPaymentBtn])
        buttonGroup.axis = .horizontal
        buttonGroup.spacing = 12
        buttonGroup.distribution = .fillEqually
        buttonGroup.translatesAutoresizingMaskIntoConstraints = false

        // 切换主题颜色按钮
        let themeToggleBtn = UIButton(type: .system)
        themeToggleBtn.setTitle("切换主题颜色", for: .normal)
        themeToggleBtn.backgroundColor = .systemGreen
        themeToggleBtn.setTitleColor(.white, for: .normal)
        themeToggleBtn.layer.cornerRadius = 8
        themeToggleBtn.translatesAutoresizingMaskIntoConstraints = false
        themeToggleBtn.addTarget(self, action: #selector(toggleTheme), for: .touchUpInside)

        // 语言选择按钮
        let languageToggleBtn = UIButton(type: .system)
        languageToggleBtn.setTitle("选择语言", for: .normal)
        languageToggleBtn.backgroundColor = .systemOrange
        languageToggleBtn.setTitleColor(.white, for: .normal)
        languageToggleBtn.layer.cornerRadius = 8
        languageToggleBtn.translatesAutoresizingMaskIntoConstraints = false
        languageToggleBtn.addTarget(self, action: #selector(selectLanguage), for: .touchUpInside)
                
        // 创建垂直 StackView
        let stackView = UIStackView(arrangedSubviews: [orderIdGroup, startPaymentBtn, themeToggleBtn, languageToggleBtn])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 创建 ScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        // 设置 ScrollView 约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // StackView 约束
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 200),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -80),
            
            buttonGroup.heightAnchor.constraint(equalToConstant: 50),
            themeToggleBtn.heightAnchor.constraint(equalToConstant: 50),
            languageToggleBtn.heightAnchor.constraint(equalToConstant: 50),
        ])

        // 添加 Loading 指示器
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // 添加浮动球
        let ball = GTOPDFloatingBall(frame: .init(x: 20, y: view.frame.height - 200, width: 60, height: 60))
        ball.isHidden = true
        view.addSubview(ball)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTap)))
    }

    func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createInputGroup(title: String, textField: UITextField) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let groupStack = UIStackView(arrangedSubviews: [titleLabel, textField])
        groupStack.axis = .horizontal
        groupStack.spacing = 12
        groupStack.alignment = .center
        groupStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 80),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return groupStack
    }

    /// 商户创建订单，类似这样处理，具体根据商户后台SDK说明进行
    func checkoutOrder(amount: String, currency: String, chain: String, payCurrency: String) {
        // 显示 loading，禁用按钮
        setLoading(true)

        OrderCheckoutManager.checkoutOrder(amount: "", currency: "", chain: "", payCurrency: "", fulltype: "") { [weak self] response in
            guard let self else {
                return
            }

            guard let prepayId = response.data?.prepayId else {
                let msg = response.errorMessage ?? response.message
                let alert = UIAlertController(title: "提示", message: "创建订单失败：\(msg ?? "")", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(alert, animated: true)
                // 隐藏 loading，启用按钮
                self.setLoading(false)
                return
            }
            self.orderIdTextField.text = prepayId
            self.setLoading(false)
        }
    }

    /// 设置 Loading 状态
    func setLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            // 处理按钮状态控制等
        }
    }

    /// 验证签名
    func testSign(prepayId: String) {
        setLoading(true)
        GatePaySigManager.sigWith(prepayid: prepayId) { [weak self] response in
            guard let self else {
                return
            }
            guard response.success == true else {
                let alert = UIAlertController(title: "提示", message: "签名验证失败", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                present(alert, animated: true)
                self.setLoading(false)
                return
            }
            guard !GTOPDEnvCacheManager.shared.clientId.isEmpty else {
                let alert = UIAlertController(title: "提示", message: "缺少: client_id", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                present(alert, animated: true)
                self.setLoading(false)
                return
            }
            guard let signModel = response.data?.bizData,
                  let nonce = signModel.nonce,
                  let signature = signModel.signature else {
                let alert = UIAlertController(title: "提示", message: "缺少: 签名数据", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                present(alert, animated: true)
                self.setLoading(false)
                return
            }
            let ts = Int(signModel.ts ?? 0)
            let payRequest = GatePaySDKParams(apiKey: GTOPDEnvCacheManager.shared.clientId, prepayId: prepayId, timestamp: "\(ts)", nonce: nonce, signature: signature, returnUri: "gatepaya52b435513cf5d87")
            guard let nav = navigationController else {
                return
            }
            GatePaySDK.shared.pushGateOpenPay(nav, payModel: payRequest) { _ in
                
            }
            self.setLoading(false)
        }
    }

    @objc private func viewTap() {
        view.endEditing(true)
    }

    @objc func toggleTheme() {
        // 切换暗黑模式状态
        let currentMode = GatePaySDK.shared.isDarkMode
        let newMode = !currentMode

        // 设置新的主题模式
        GatePaySDK.shared.setCurrentMode(isDarkMode: newMode, language: currentLanguage)

        // 显示提示
        let modeText = newMode ? "暗黑模式" : "明亮模式"
        let alert = UIAlertController(title: "主题已切换", message: "当前模式：\(modeText)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    @objc func selectLanguage() {
        let alert = UIAlertController(title: "选择语言", message: "请选择一个语言", preferredStyle: .actionSheet)
        
        // 为每种语言添加选项
        for language in supportedLanguages {
            let action = UIAlertAction(title: language.name, style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                // 更新当前语言
                self.currentLanguage = language.code
                
                // 获取当前主题模式
                let currentMode = GatePaySDK.shared.isDarkMode
                
                // 设置新的语言
                GatePaySDK.shared.setCurrentMode(isDarkMode: currentMode, language: language.code)
                
                // 显示提示
                let alert = UIAlertController(
                    title: "语言已切换",
                    message: "当前语言：\(language.name)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(alert, animated: true)
            }
            
            // 如果是当前语言，添加勾选标记
            if language.code == currentLanguage {
                action.setValue(true, forKey: "checked")
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad 支持
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    @objc func startPayment() {
        view.endEditing(true)
        guard let prepayid = orderIdTextField.text, !prepayid.isEmpty else {
            let alert = UIAlertController(title: "提示", message: "订单id不能为空", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        self.testSign(prepayId: prepayid)
    }
}
