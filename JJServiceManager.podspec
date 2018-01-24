Pod::Spec.new do |s|

  s.name         = 'JJServiceManager'
  s.version      = '0.0.1'
  s.summary      = 'iOS Service Framework'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/hamilyjing/JJServiceManager'
  s.author       = { 'JJ' => 'gongjian_001@126.com' }
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/hamilyjing/JJServiceManager.git", :tag => s.version }
  
  s.source_files = "JJServiceManager", "JJServiceManager/**/*.{h,m}"

  s.framework = "Foundation"
  s.framework = "UIKit"
  s.framework = "Security"

  s.dependency 'YTKNetwork', '~> 2.0.4'
  s.dependency 'YYModel', '~> 1.0.4'

end
