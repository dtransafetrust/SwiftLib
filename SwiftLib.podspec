
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

  s.dependency 'SQLCipher', '~> 4.0'
  s.dependency 'Reachability', '~> 3.2'
  s.dependency 'SSZipArchive'
  s.dependency 'sqlite3'
  # s.dependency 'OpenSSL-Universal'

  s.source        = { :git => "https://github.com/dtransafetrust/SwiftLib" }
  s.source_files = "distributions/#{s.version}/*.zip"

  s.vendored_frameworks = "distributions/#{s.version}/SwiftLib.zip"

  s.prepare_command         = <<-CMD
    FRAMEWORK_PATH=distributions/#{s.version}/
    
    unzip -o $FRAMEWORK_PATH/SwiftLib.zip -d $FRAMEWORK_PATH/
                            CMD

end

