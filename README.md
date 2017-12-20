# FYSwitch

[![CI Status](http://img.shields.io/travis/Jedark/FYSwitch.svg?style=flat)](https://travis-ci.org/Jedark/FYSwitch)
[![Version](https://img.shields.io/cocoapods/v/FYSwitch.svg?style=flat)](http://cocoapods.org/pods/FYSwitch)
[![License](https://img.shields.io/cocoapods/l/FYSwitch.svg?style=flat)](http://cocoapods.org/pods/FYSwitch)
[![Platform](https://img.shields.io/cocoapods/p/FYSwitch.svg?style=flat)](http://cocoapods.org/pods/FYSwitch)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

将Switch背景和边框抽象出来复用，并提供IB实时预览；可使用以下预定义的效果，也可参照示例自行扩充。<br />
![IB](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/IBDesignable.png)


SwitchBackground
- FYBgPure - 纯色背景；不变换
- FYBgLinearChange - 纯色背景；提供线性变换
- FYBgGradientChange - 渐变背景；提供线性变换
- FYBgPointScale - 从一点扩张&收缩到一点

SwitchBorder
- FYBorderPure - 纯色边框；不变换
- FYBorderLinearChange - 纯色边框；提供线性变换
- FYBorderLineStroke - 纯色边框；线条动画
- FYBorderLineStrokeSpring - 纯色边框；线条动画

FYImageTextSwitch => 支持纯文字或图像Knob的IBInspectable


### Demo中效果的简要说明
#### FYImageTextSwitch + FYBgPure + FYBorderPure + FY2DRotateKnob
![01](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_010.gif)

#### FYSwitch + FYBgPure + FYBorderPure + FY3DSpringRotateKnob
![02](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_020.gif)

#### FYSwitch + FYBgPure + FYBorderPure + FY3DBlinkRotateKnob
![03](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_030.gif)

#### FYSwitch + FYBgPure + FYBorderPure + FYLineStrokeKnob
![04](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_040.gif)

#### FYSwitch + FYDayNightBg1 + FYBorderLinearChange + FYDayNightKnob1
![05](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_050.gif)

#### FYSwitch + FYDayNightBg2 + FYBorderLineStroke + FYDayNightKnob2
![06](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_060.gif)

#### FYSwitch + FYBorderLineStrokeSpring + FYDayNightKnob3
![07](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_070.gif)

#### FYImageTextSwitch + FYBgGradientChange + FYBorderLinearChange + FYScaleKnob
![08](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_080.gif)

#### FYSwitch + FYPushKnobBg + FYPushKnob
![09](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_090.gif)

#### FYSwitch + FYBgPure + FYCapsuleKnob
![10](https://github.com/svenfy/FYSwitch/blob/master/ScreenShots/done_100.gif)

## Requirements

```ruby
iOS 9.0+
Swift 4.0
```

## Installation

FYSwitch is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
platform :ios, '9.0'
use_frameworks!

pod 'FYSwitch'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
        end
    end
end
```

## Author

Jedark, 792896878@qq.com

## License

FYSwitch is available under the MIT license. See the LICENSE file for more info.
