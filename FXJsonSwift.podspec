Pod::Spec.new do |s|
  s.name         = "FXJsonSwift"
  s.version      = "1.0.0"
  s.summary      = "Json解析框架"

  s.homepage     = "https://github.com/zqw87699/FXJsonSwift"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = {"zhangdazong" => "929013100@qq.com"}

  s.source       = { :git => "https://github.com/zqw87699/FXJsonSwift.git", :tag => "#{s.version}"}

  s.platform     = :ios, "8.0"

  s.frameworks = "Foundation", "UIKit"

  s.module_name = 'FXJsonSwift'

  s.requires_arc = true

  s.source_files  = "Classes/*.{swift}"

end
