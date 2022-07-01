
Pod::Spec.new do |spec|

  spec.name         = "SwiftLib"
  spec.version      = "0.0.1"
  spec.summary      = "A CocoaPods library written in Swift"

  spec.description  = "This CocoaPods library helps you perform calculation."

  spec.homepage     = "https://github.com/dtransafetrust/SwiftLib"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "dtran" => "dtran@safetrust.com" }

  spec.ios.deployment_target = "14.0"
  spec.swift_version = "5.0"

  spec.source        = { :git => "https://github.com/dtransafetrust/SwiftLib.git", :tag => "#{spec.version}" }
  spec.source_files  = "SwiftLib/**/*.{h,m,swift}"

end