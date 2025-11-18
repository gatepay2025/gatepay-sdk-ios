
## 概述

GateOpenPaySDK 是一个为 iOS 应用提供加密货币支付功能的 SDK。它支持多种支付方式，包括Gate支付、钱包连接、扫码支付，并提供了完整的支付流程管理。

## 前置条件

需要到Gate开发者中心申请对应的ClientId、Scheme等 [官方开发者中心] (https://www.gate.com/docs/gatepay/common/)

> 💡 **Demo 参考**：完整接入示例请参考 [GitHub Demo 工程](https://github.com/gatepay2025/gatepay-sdk-ios/tree/main/Example/SampleApp)


## 系统要求

- iOS 13.0 或更高版本
- Swift 5.9 或更高版本
- Xcode 12.0 或更高版本

## 安装方式

### 方式一：CocoaPods

1. 在项目的 `Podfile` 中添加：

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'GateOpenPaySDK', :git => 'https://github.com/gatepay2025/gatepay-sdk-ios', :tag => '2.0.0'
end
```

ps: 最好指定版本
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

2. 执行安装命令：

```bash
pod install
```

### 方式二：Swift Package Manager (SPM)

1. 在 Xcode 中，选择 `File` > `Add Packages...`
2. 输入仓库地址：`https://github.com/gatepay2025/gatepay-sdk-ios`
3. 选择版本或分支
4. 点击 `Add Package`

或者在 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/gatepay2025/gatepay-sdk-ios", from: "2.0.0")
]
```

### 方式三：直接下载解压

 1. 解压之后将`GateOpenPaySDK.xcframework`直接拖到项目之中

## 配置项目

### 1. Info.plist 配置

在项目的 `Info.plist` 文件中添加以下配置：

#### 1.1 URL Schemes 配置

添加自定义 URL Scheme 用于支付回调，示例：gatepay73967e614a9fd5e3

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gatepay[您的ClientID转义]</string>
        </array>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
    </dict>
</array>
```

#### 1.2 白名单配置

添加需要查询的第三方应用(如下示例，添加你希望用来支付的钱包) URL Schemes：
**"gatePay"是打开Gate App支付的必要设置**

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>metamask</string>
    <string>trust</string>
    <string>uniswap</string>
    <string>gatepay</string>
    <string>okxwallet</string>
</array>
```

#### 1.3 权限控制

在Info.plist文件添加必要的网络许可

#### 1.4 增加配置

1. 在 Build Settings 中添加 OTHER_LDFLAGS = "-ObjC"
2. 在 General中标记包为 `Embed & Sign`

### 2. 导入 SDK

在需要使用 SDK 的文件中导入：

```swift
import GateOpenPaySDK
```

## 快速开始

### 1. SDK 初始化

在应用启动时（通常在 `AppDelegate` 或首次使用前）注册 SDK：

```swift
import GateOpenPaySDK

// 在 AppDelegate 的 didFinishLaunchingWithOptions 中
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 注册 SDK
    GatePaySDK.shared.regist(isDebug: true, clientId: "您的ClientID")
    
    // 设置主题和语言
    GatePaySDK.shared.setCurrentMode(isDarkMode: false, language: "zh-Hans")
    
    return true
}
```

参数说明：
- `isDebug`: 是否为调试模式，生产环境请设置为 `false`
- `clientId`: Gate.io 提供的商户 ID

### 2. 创建支付订单

在发起支付前，需要先通过您的后端服务创建支付订单：

```swift
// 订单参数
let amount = "9.9"          // 支付金额
let currency = "USDT"       // 币种
let chain = "ETH"           // 支付链
let payCurrency = "USDT"    // 支付币种

// 调用您的后端接口创建订单
// 这里需要您自己实现与后端的通信
createOrder(amount: amount, currency: currency, chain: chain, payCurrency: payCurrency) { prepayId in
    // 获取到 prepayId 后进行下一步
    self.generateSignature(prepayId: prepayId)
}
```

### 3. 生成签名

> 📖 **服务端对接**：服务端如何生成签名及对接 API，请参考 [GatePay 服务端文档](https://www.gate.com/docs/gatepay/common/en/)

获取订单 ID 后，需要通过您的后端服务生成支付签名：

```swift
func generateSignature(prepayId: String) {
    // 调用您的后端接口生成签名
    // 后端需要返回以下参数：
    // - timestamp: 时间戳
    // - nonce: 随机字符串
    // - signature: 签名
    
    requestSignature(prepayId: prepayId) { timestamp, nonce, signature in
        self.startPayment(
            prepayId: prepayId,
            timestamp: timestamp,
            nonce: nonce,
            signature: signature
        )
    }
}
```

### 4. 发起支付

获取签名后，调用 SDK 发起支付：

```swift
func startPayment(prepayId: String, timestamp: String, nonce: String, signature: String) {
    // 构建支付参数
    let payParams = GatePaySDKParams(
        apiKey: "您的ClientID",
        prepayId: prepayId,
        timestamp: timestamp,
        nonce: nonce,
        signature: signature,
        returnUri: "gatepay[您的ClientID转义]"
    )
    
    // 发起支付
    guard let navigationController = self.navigationController else { return }
    
    GatePaySDK.shared.pushGateOpenPay(navigationController, payModel: payParams) { result in
        // 支付结果回调
        if result.isSuccess {
            print("支付成功: \(result.message)")
            // 处理支付成功逻辑
        } else {
            print("支付失败: \(result.message)")
            // 处理支付失败逻辑
        }
    }
}
```

## 主题和语言配置

### 设置主题模式

SDK 支持明亮模式和暗黑模式：

```swift
// 设置为暗黑模式
GatePaySDK.shared.setCurrentMode(isDarkMode: true, language: .en)

// 设置为明亮模式
GatePaySDK.shared.setCurrentMode(isDarkMode: false, language: .en)
```

### 设置语言

SDK 支持中文/英文/其他小语种：

```swift
// 设置为中文
GatePaySDK.shared.setCurrentMode(isDarkMode: false, language: .cn)

// 设置为英文
GatePaySDK.shared.setCurrentMode(isDarkMode: false, language: .en)
```

| 代码 | 语言 | 代码 | 语言 |
|------|------|------|------|
| `zh-Hans` | 简体中文 | `ja` | 日语 |
| `tw` | 繁体中文 | `ko` | 韩语 |
| `en` | 英语 | `vi` | 越南语 |
| `in` | 印尼语 | `th` | 泰语 |
| `es` | 西班牙语 | `fr` | 法语 |
| `de` | 德语 | `it` | 意大利语 |
| `pt` | 葡萄牙语 | `br` | 巴西葡萄牙语 |
| `ru` | 俄语 | `ar` | 阿拉伯语 |
| `tr` | 土耳其语 | `uk` | 乌克兰语 |

### 自定义颜色

SDK 支持自定义界面颜色，包括文字颜色、按钮颜色等：

```swift
// 定义明亮和暗黑模式下的颜色（特定的一些文案颜色如“Gate”、“Gate APP”）
let textColor: GatePayColorTuple = (
    lightColor: .black,
    darkColor: .white
)

let button1Color: [GatePayColorTuple] = [
    (lightColor: .white, darkColor: .black),  // 文字颜色
    (lightColor: .blue, darkColor: .darkGray) // 背景颜色
]

let button2Color: [GatePayColorTuple] = [
    (lightColor: .blue, darkColor: .white),   // 文字颜色
    (lightColor: .white, darkColor: .gray)    // 背景颜色
]

// 应用自定义颜色
GatePaySDK.shared.setCurrentMode(
    isDarkMode: false,
    language: "zh-Hans",
    textColor: textColor,
    topButtonColor: button1Color,
    botButtonColor: button2Color
)
GatePaySDK.shared.topButtonColor = button1Color
GatePaySDK.shared.botButtonColor = button2Color
```

也可以单独设置某个颜色：

```swift
// 设置推荐标识颜色
GatePaySDK.shared.recommondColor = (
    lightColor: .systemBlue,
    darkColor: .systemIndigo
)

// 设置特定文案颜色
GatePaySDK.shared.textColor = (
    lightColor: .black,
    darkColor: .white
)

// 设置进度图标颜色
GatePaySDK.shared.iconColor = (
    lightColor: .gray,
    darkColor: .lightGray
)
```

## 钱包连接功能

SDK 提供了钱包连接功能，支持通过 WalletConnect 协议连接第三方钱包。

### 配置 WalletConnect

在使用钱包连接功能前，需要先配置 WalletConnect 参数：

```swift
GatePaySDK.shared.setWalletConnect(
    groupId: "group.com.yourapp.shared",
    projectName: "您的应用名称",
    projectIcon: "https://gate.io/favicon.ico" #您的应用icon
)
```

#### 参数说明

- **groupId** (String, 必填)
  - 说明：App Group 标识符
  - 用途：用于在主应用和扩展之间共享数据
  - 格式：`group.com.yourcompany.yourapp.shared`
  - 示例：`"group.com.example.myapp.shared"`
  - 注意：需要在 Xcode 的 Capabilities 中启用 App Groups 并配置相同的标识符

- **projectName** (String, 必填)
  - 说明：您的应用名称
  - 用途：在钱包连接时显示给用户
  - 示例：`"我的支付应用"`

- **projectIcon** (String, 可选)
  - 说明：应用的Icon，如果不传展示默认图标
  - 用途：用于钱包链接的显示
  - 格式：url
  - 示例：`"https://gate.io/favicon.ico"`


#### 配置示例

```swift
import GateOpenPaySDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 1. 注册 SDK
        GatePaySDK.shared.regist(isDebug: true, clientId: "您的ClientID")
        
        // 2. 配置 WalletConnect
        GatePaySDK.shared.setWalletConnect(
            groupId: "group.com.example.myapp.shared",    // 您的 App Group ID
            projectName: "我的应用",                    // 您的应用名称
            projectIcon: ""                         // 您的 URL Scheme
        )
        
        // 3. 设置主题和语言
        GatePaySDK.shared.setCurrentMode(isDarkMode: false, language: "zh-Hans")
        
        return true
    }
}
```

### 注意事项

1. **App Groups 配置**：
   - 在 Xcode 中，选择项目 Target
   - 进入 Signing & Capabilities
   - 添加 App Groups capability
   - 配置与代码中相同的 Group ID

2. **URL Scheme 配置**：
   - 确保 `nativeUri` 参数与 Info.plist 中的 URL Scheme 配置一致
   - 建议使用唯一的 URL Scheme，避免与其他应用冲突


3. **初始化时机**：
   - 建议在应用启动时（`didFinishLaunchingWithOptions`）就配置 WalletConnect
   - 确保在使用钱包连接功能前完成配置


## API 参考

### GatePaySDK

主要的 SDK 开放属性

#### 属性

- `shared`: 单例实例
- `isDarkMode`: 当前是否为暗黑模式
- `language`: 当前语言设置
- `textColor`: 特定文字颜色
- `recommondColor`: 推荐标识颜色
- `iconColor`: 图标颜色
- `topButtonColor`: 顶部按钮颜色（文字和背景）
- `botButtonColor`: 底部按钮颜色（文字和背景）
- `isWalletConnected`: 钱包是否已连接
- `currentWalletAccount`: 当前连接的钱包账户
- `orderEndAction`: 订单完成按钮点击回调
- `orderDetailAction`: 订单详情按钮点击回调
- `contactAction`: 联系客服按钮点击回调

#### 方法

##### regist(isDebug:clientId:)

注册 SDK。

```swift
func regist(isDebug: Bool, clientId: String)
```

参数：
- `isDebug`: 是否为调试模式
- `clientId`: 商户 ID

##### setCurrentMode(isDarkMode:language:textColor:topButtonColor:botButtonColor:)

##### pushGateOpenPay(_:payModel:completion:)

打开支付收银台。

```swift
func pushGateOpenPay(
    _ nav: UINavigationController,
    payModel: GatePaySDKParams,
    completion: @escaping GatePayResultBlock
)
```

参数：
- `nav`: 导航控制器
- `payModel`: 支付参数
- `completion`: 支付结果回调

### GatePaySDKParams

支付参数模型。

```swift
public struct GatePaySDKParams {
    let apiKey: String          // 商户 API Key
    let prepayId: String        // 预订单 ID
    let orderDetailUrl: String? // 订单详情 URL（可选）
    let orderUrlEnd: String?    // 订单完成 URL（可选）
    let contactUrl: String?     // 联系客服 URL（可选）
    let returnUri: String?      // 返回 App 的 URL Scheme（可选）
    let timestamp: String       // 时间戳
    let nonce: String          // 随机字符串
    let signature: String      // 签名
}
```

#### 参数详细说明

##### 必填参数

- **apiKey** (String)
  - 说明：Gate.io 提供的商户 API Key / Client ID
  - 用途：用于身份验证和订单关联
  - 示例：`"mZ96D37oKk-xxxx"`

- **prepayId** (String)
  - 说明：预订单 ID，由您的后端服务调用 Gate.io API 创建订单后返回
  - 用途：唯一标识本次支付订单
  - 示例：`"35519171252060239"`

- **timestamp** (String)
  - 说明：签名时使用的时间戳（秒级）
  - 用途：用于签名验证，防止重放攻击
  - 示例：`"1704067200456"`
  - 注意：必须与后端生成签名时使用的时间戳一致

- **nonce** (String)
  - 说明：随机字符串
  - 用途：用于签名验证，增加签名的唯一性
  - 示例：`"abc123def456"`
  - 注意：必须与后端生成签名时使用的 nonce 一致

- **signature** (String)
  - 说明：后端生成的签名字符串
  - 用途：验证请求的合法性和完整性
  - 示例：`"a1b2c3d4e5f6..."`
  - 注意：签名必须在服务端生成，不要在客户端生成

##### 可选参数

- **orderDetailUrl** (String?, 可选)
  - 说明：订单详情页的 Deep Link URL
  - 用途：当用户在支付页面点击"查看订单详情"时，SDK 会尝试打开此 URL
  - 示例：`"yourapp://order/detail?orderId=123456"`
  - 默认行为：如果不设置此参数，且未设置 `GateOpenPaySDK.shared.orderDetailAction`，点击"查看订单详情"按钮将直接返回到入口页面

- **orderUrlEnd** (String?, 可选)
  - 说明：订单完成后的 Deep Link URL
  - 用途：当支付完成后，用户点击"完成"按钮时，SDK 会尝试打开此 URL
  - 示例：`"yourapp://order/complete?orderId=123456"`
  - 默认行为：如果不设置此参数，且未设置 `GateOpenPaySDK.shared.orderEndAction`，点击"完成"按钮将直接返回到入口页面

- **contactUrl** (String?, 可选)
  - 说明：联系客服页面的 Deep Link URL
  - 用途：当用户在支付页面点击"联系客服"时，SDK 会尝试打开此 URL
  - 示例：`"yourapp://customer/service"` 或 `"yourapp://support?from=payment"`
  - 默认行为：如果不设置此参数，且未设置 `GateOpenPaySDK.shared.contactAction`，点击"联系客服"按钮将直接返回到入口页面

- **returnUri** (String?, 可选)
  - 说明：支付完成后返回 App 的 URL Scheme
  - 用途：用于从第三方钱包应用返回到您的 App
  - 示例：`"gatepay73967e614a9fd5e3"` 或 `"yourapp://"`
  - 格式：通常使用 `gatepay[您的ClientID转义]` 格式
  - 注意：必须与 Info.plist 中配置的 CFBundleURLSchemes 一致

#### URL 参数与 Action 回调的关系

SDK 提供了两种方式来处理用户在支付流程中的操作：

1. **通过 URL 参数**：在创建 `GatePaySDKParams` 时传入 Deep Link URL
2. **通过 Action 回调**：在 `GateOpenPaySDK.shared` 中设置回调闭包

优先级：URL 参数 > Action 回调 > 默认行为（返回入口页）

##### 订单详情处理

```swift
// 方式一：使用 URL 参数
let params = GatePaySDKParams(
    apiKey: "your_api_key",
    prepayId: "order_123",
    timestamp: "1704067200",
    nonce: "abc123",
    signature: "signature_string",
    orderDetailUrl: "yourapp://order/detail?orderId=123"  // 设置订单详情 URL
)

// 方式二：使用 Action 回调
GatePaySDK.shared.orderDetailAction = {
    // 自定义处理逻辑
    print("用户点击了查看订单详情")
    // 跳转到订单详情页
    // navigationController?.pushViewController(orderDetailVC, animated: true)
}

// 如果两者都不设置，点击"查看订单详情"将返回入口页
```

##### 订单完成处理

```swift
// 方式一：使用 URL 参数
let params = GatePaySDKParams(
    apiKey: "your_api_key",
    prepayId: "order_123",
    timestamp: "1704067200",
    nonce: "abc123",
    signature: "signature_string",
    orderUrlEnd: "yourapp://order/complete?orderId=123"  // 设置订单完成 URL
)

// 方式二：使用 Action 回调
GatePaySDK.shared.orderEndAction = {
    // 自定义处理逻辑
    print("用户点击了完成按钮")
    // 跳转到订单完成页或首页
    // navigationController?.popToRootViewController(animated: true)
}

// 如果两者都不设置，点击"完成"将返回入口页
```

##### 联系客服处理

```swift
// 方式一：使用 URL 参数
let params = GatePaySDKParams(
    apiKey: "your_api_key",
    prepayId: "order_123",
    timestamp: "1704067200",
    nonce: "abc123",
    signature: "signature_string",
    contactUrl: "yourapp://customer/service"  // 设置客服 URL
)

// 方式二：使用 Action 回调
GatePaySDK.shared.contactAction = {
    // 自定义处理逻辑
    print("用户点击了联系客服")
    // 打开客服页面或拨打客服电话
    // openCustomerService()
}

// 如果两者都不设置，点击"联系客服"将返回入口页
```

#### 使用建议

1. **推荐使用 Action 回调**：更灵活，可以在运行时动态修改行为
2. **URL 参数适用于固定跳转**：如果跳转目标是固定的页面，使用 URL 参数更简洁
3. **混合使用**：可以同时设置 URL 参数和 Action 回调，URL 参数会优先生效
4. **清理 Action**：在不需要时记得清空 Action 回调，避免内存泄漏

```swift
// 清理 Action 回调
GatePaySDK.shared.orderDetailAction = nil
GatePaySDK.shared.orderEndAction = nil
GatePaySDK.shared.contactAction = nil
```

### GatePayResponseModel

支付结果模型。

```swift
public struct GatePayResponseModel {
    public let isSuccess: Bool  // 是否支付成功
    public let message: String  // 结果消息
}
```

### GatePayColorTuple

颜色元组类型，用于定义明亮和暗黑模式下的颜色。

```swift
public typealias GatePayColorTuple = (lightColor: UIColor, darkColor: UIColor)
```

## 注意事项

1. **URL Scheme**：
   - 确保 `returnUri` 与 Info.plist 中配置的 URL Scheme 一致
   - URL Scheme 格式：`gatepay[您的ClientID转义]`

2. **错误处理**：
   - 始终处理支付回调中的错误情况
   - 建议在支付前检查网络连接状态

## 常见问题

### Q: 如何获取 clientId？
A: 请到 Gate官网申请，或者请联系 Gate 商务团队申请商户账号，获取 clientId 和相关配置信息。

### Q: 支付回调不执行怎么办？
A: 检查以下几点：
1. Info.plist 中的 URL Scheme 配置是否正确
2. `returnUri` 参数是否与 URL Scheme 一致
3. 是否正确实现了 URL Scheme 的处理逻辑

### Q: 支持哪些支付方式？
A: SDK 支持钱包连接支付、扫码支付等多种方式，具体支持的支付方式取决于您的商户配置。

## 技术支持

如有问题，请联系：
- 邮箱：gatepay@gate.com

## 更新日志

### v2.0.0
- 支持钱包连接
- 支持扫码转账
- 支持主题和语言切换
- 支持自定义颜色配置

### v1.0.0
- 初始版本发布
- 支持基础支付功能

