Pod::Spec.new do |s|
  s.name         = "MMMUpperNotificationView"
  s.version      = "0.0.1"
  s.summary      = ""
  s.license      = 'MIT'
  s.homepage     = "https://github.com/muukii0803/UpperNotificationView"
  s.author       = { "Muukii" => "muukii.muukii@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/muukii0803/UpperNotificationView.git", :tag => "0.2.0" }
  s.source_files = 'MMMUpperNotificationView/*'
  s.resource     = 'Resources/*.png'
  s.requires_arc = true
end
