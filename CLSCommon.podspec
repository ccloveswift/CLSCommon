
Pod::Spec.new do |s|

  s.name         = "CLSCommon"
  s.version      = "0.0.1"
  s.summary      = "A short description of CLSCommon."
  s.description  = <<-DESC
                    Cc
                   DESC

  s.homepage     = "https://github.com/ccloveswift/CLSCommon"
  
  s.license      = { :type => 'Copyright', :text =>
        <<-LICENSE
        Copyright 2010-2015 CenterC Inc.
        LICENSE
    }
  
  s.author          = { "TT" => "654974034@qq.com" }
  
  s.source          = { :git => "https://github.com/ccloveswift/CLSCommon.git", :tag => "#{s.version}" }

  s.platform        = :ios, '12.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.frameworks          = "UIKit"
    ss.source_files        = "Classes/Core/**/*.{swift}"
  end
  s.subspec 'UI' do |ss|
    ss.dependency       'CLSCommon/Core'
    ss.source_files        = "Classes/UI/**/*.{swift}"
  end
  s.subspec 'VideoCoder' do |ss|
    ss.dependency       'CLSCommon/Core'
    ss.source_files        = "Classes/VideoCoder/**/*.{swift}"
  end
end
