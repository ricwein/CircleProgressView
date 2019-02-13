#
# Be sure to run `pod lib lint UICircleProgressView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UICircleProgressView'
  s.version          = '0.4.5'
  s.summary          = 'An AppStore like download-progress circle-indicator view.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An Apple AppStore like download-progress indicator.
Shows a progress-circle which changes according to the current status and progress into a full circle.
                       DESC

  s.homepage         = 'https://github.com/ricwein/CircleProgressView'
  s.screenshots      = 'https://raw.githubusercontent.com/ricwein/CircleProgressView/master/images/old/downloading.png', 'https://raw.githubusercontent.com/ricwein/CircleProgressView/master/images/old/success.png', 'https://raw.githubusercontent.com/ricwein/CircleProgressView/master/images/new/downloading.png', 'https://raw.githubusercontent.com/ricwein/CircleProgressView/master/images/new/waiting.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Richard Weinhold' => 'git@ricwein.com' }
  s.source           = { :git => 'https://github.com/ricwein/CircleProgressView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version         = '4.2'

  s.source_files = 'UICircleProgressView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'UICircleProgressView' => ['UICircleProgressView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
