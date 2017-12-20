Pod::Spec.new do |s|
  s.name             = 'FYSwitch'
  s.version          = '0.1.0'
  s.summary          = 'Custom Switch'

  s.description      = "various animation and UI style for Switch"
  s.homepage         = 'https://github.com/svenfy/FYSwitch'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jedark' => '792896878@qq.com' }
  s.source           = { :git => 'https://github.com/svenfy/FYSwitch.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'FYSwitch/Classes/**/**/**/**/*.{swift}'
  s.resources    = 'FYSwitch/Assets/**/*.{png}'

  s.frameworks = 'UIKit'
  s.dependency 'pop'
  s.dependency 'AHEasing'
  s.dependency 'ReactiveCocoa'
end
