#
# Be sure to run `pod lib lint CircleProgressView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CircleProgressView'
  s.version          = '0.1.0'
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
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Richard Weinhold' => 'git@ricwein.com' }
  s.source           = { :git => 'https://github.com/ricwein/CircleProgressView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version         = '4.2'

  s.source_files = 'CircleProgressView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CircleProgressView' => ['CircleProgressView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
