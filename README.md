# CircleProgressView

[![Version](https://img.shields.io/cocoapods/v/UICircleProgressView.svg?style=flat)](https://cocoapods.org/pods/UICircleProgressView)
[![License](https://img.shields.io/cocoapods/l/UICircleProgressView.svg?style=flat)](https://cocoapods.org/pods/UICircleProgressView)
[![Platform](https://img.shields.io/cocoapods/p/UICircleProgressView.svg?style=flat)](https://cocoapods.org/pods/UICircleProgressView)

An AppStore like download-progress circle-indicator view.

## Installation

UICircleProgressView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UICircleProgressView'
```

## Usage

Use either:
- the Interface-Builder to create a `UIView` and set it's base-class to `UICircleProgressView`
- create a UICircleProgressView in source:

```Swift
import UICircleProgressView

let progressView = UICircleProgressView(frame: CGRect(x: 20, y: 20, width: 24, height: 24))
progressView.tintColor = .blue
progressView.strokeWidth = 4.0
progressView.status = .remote
progressView.progress = 0.0

// starting download...
progressView.status = .downloading

for progress in stride(from: 0.0, to: 1.0, by: 0.01) {
    progressView.progress = progress
}
```

## License

CircleProgressView is available under the MIT license. See the LICENSE file for more info.
