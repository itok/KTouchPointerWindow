Pod::Spec.new do |s|
  s.name         = "KTouchPointerWindow"
  s.version      = "0.1.0"
  s.summary      = "Display pointers of the touches on the screen."
  s.homepage     = "https://github.com/itok/KTouchPointerWindow"
  s.license      = 'MIT'
  s.author       = { "itok" => "i@itok.jp" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/itok/KTouchPointerWindow.git", :tag => "v0.1.0" }
  s.source_files  = 'KTouchPointerWindow/*.{m,h}'
end