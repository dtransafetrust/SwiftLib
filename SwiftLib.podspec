
Pod::Spec.new do |s|

  s.name         = "SwiftLib"
  s.version      = "0.1.2"
  s.summary      = "A CocoaPods library written in Swift"

  s.description  = "This CocoaPods library helps you perform calculation."

  s.homepage     = "https://github.com/dtransafetrust/SwiftLib"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "dtran" => "dtran@safetrust.com" }

  s.ios.deployment_target = "14.0"
  s.swift_version = "5.0"

  # s.source        = { :git => "https://github.com", :tag => "#{s.version}" }

  # s.vendored_frameworks = "distributions/#{s.version}/SwiftLib.framework"

  # s.source           = { :http => "https://github.com/dtransafetrust/SwiftLib/blob/master/distributions/0.1.2/SwiftLib.framework.zip" }
  s.source           = { :http => "https://github.com/dtransafetrust/SwiftLib/SwiftLib.zip" }
  
  # s.vendored_frameworks = "SwiftLib.framework"

  s.prepare_command = "unzip SwiftLib.zip"

end

