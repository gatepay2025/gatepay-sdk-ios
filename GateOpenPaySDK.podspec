Pod::Spec.new do |s|
  s.name         = "GateOpenPaySDK"
  s.version      = "2.0.0"
  s.summary      = "GateOpenPaySDK XCFramework"
  s.homepage     = "https://github.com/gatepay2025/gatepay-sdk-ios"
  s.license      = { :type => "MIT" }
  s.author       = { "Gate" => "gatepay@gate.com" }
  
  s.platform     = :ios
  s.ios.deployment_target = "13.0"
  
  s.source       = { 
    :http => "https://github.com/gatepay2025/gatepay-sdk-ios/releases/download/2.0.0/GateOpenPaySDK-2.0.0.xcframework.zip",
    :sha256 => "53806338bcd6a2f0de71a45bfc49fc7a3efeb9c84d868cf2b9d250216a59bad8"
  }
  
  s.vendored_frameworks = "GateOpenPaySDK.xcframework"
end
