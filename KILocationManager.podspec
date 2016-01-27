Pod::Spec.new do |s|
  s.name         = "KILocationManager"
  s.version      = "0.0.1"
  s.summary      = "KILocationManager"
  s.description  = <<-DESC
                  KILocationManager.
                   DESC

  s.homepage     = "https://github.com/smartwalle/KILocationManager"
  s.license      = "MIT"
  s.author       = { "SmartWalle" => "smartwalle@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/smartwalle/KILocationManager.git", :branch => "master" }
  s.source_files = "KILocationManager/KILocationManager/*.{h,m}"
  s.framework    = "CoreLocation"
  s.requires_arc = true
end
