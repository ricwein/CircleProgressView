//
//  UICircleProgressButton.swift
//  UICircleProgressView
//
//  Created by Richard Weinhold on 22.02.19.
//

import UIKit

@IBDesignable
public class UICircleProgressButton: UIButton
{
    public typealias DownloadStatus = UICircleProgressView.DownloadStatus
    public typealias StyleType = UICircleProgressView.StyleType

    var progressView: UICircleProgressView

    /// keep track if our class is already fully setup
    /// if not, we don't have to adapt all property-changes directly
    private var hasInitFinished: Bool = false

    /// default initializer
    public override init(frame: CGRect)
    {
        self.progressView = UICircleProgressView(frame: frame)
        super.init(frame: frame)
        self.setup()
    }

    /// required default initializer
    public required init?(coder: NSCoder)
    {
        guard let progressView = UICircleProgressView(coder: coder) else
        {
            return nil
        }
        self.progressView = progressView
        super.init(coder: coder)
        self.setup()
    }

    /// custom initializer with support for multiple default-properties
    public init(frame: CGRect, style: StyleType = .old, status: DownloadStatus = .paused, progress: Float = 0.0)
    {
        self.progressView = UICircleProgressView(frame: frame, style: style, status: status, progress: progress)
        super.init(frame: frame)
        self.setup()
    }

    /// ensures correct interfacebuilder support with live-preview
    public override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        self.progressView.prepareForInterfaceBuilder()
    }

    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'status' instead.")
    @IBInspectable
    public var statusType: String? = DownloadStatus.paused.rawValue
    {
        willSet
        {
            if
                let typeName = newValue,
                let newStatus = DownloadStatus(rawValue: typeName.lowercased())
            {
                self.status = newStatus
            }
        }
    }

    /// set the current download-state
    public var status: DownloadStatus = .paused
    {
        didSet
        {
            self.progressView.status = self.status
            self.updateStatus()
        }
    }

    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'type' instead.")
    @IBInspectable
    public var useNewStyle: Bool = false
    {
        willSet { self.style = newValue ? .new : .old }
    }

    /// set which UI-style should be used, old or new?
    public var style: StyleType = .old
    {
        didSet { self.progressView.style = self.style }
    }

    /// set the current progress (between 0.0 and 1.0)
    @IBInspectable
    public var progress: Float = 0.0
    {
        willSet { self.progress = max(min(newValue, 1.0), 0.0) }
        didSet { self.progressView.progress = self.progress }
    }

    /// ignore explicit setted strokeWidth and use a dynamically calculated instead?
    @IBInspectable
    public var strokeDynamic: Bool = true
    {
        didSet { self.progressView.strokeDynamic = self.strokeDynamic }
    }

    /// set an explicit strokeWidth
    @IBInspectable
    public var strokeWidth: CGFloat = 3.0
    {
        willSet
        {
            self.strokeWidth = max(min(newValue, self.frame.height / 2.0, self.frame.width / 2.0), 0.0)
        }

        didSet
        {
            self.strokeDynamic = false
            self.progressView.strokeWidth = self.strokeWidth
        }
    }

    @IBInspectable
    public var colorSuccess: UIColor = UIColor.green
    {
        didSet { self.progressView.colorSuccess = self.colorSuccess }
    }

    @IBInspectable
    public var colorPaused: UIColor = UIColor.lightGray
    {
        didSet { self.progressView.colorPaused = self.colorPaused }
    }

    @IBInspectable
    public var colorCanceled: UIColor = UIColor.red
    {
        didSet { self.progressView.colorCanceled = self.colorCanceled }
    }

    public override func tintColorDidChange()
    {
        self.progressView.tintColor = self.tintColor
    }

    @IBInspectable
    public var stopImage: UIImage?
    {
        didSet { if self.hasInitFinished { self.updateStatus() } }
    }

    @IBInspectable
    public var startImage: UIImage?
    {
        didSet { if self.hasInitFinished { self.updateStatus() } }
    }

    public func setup()
    {
        self.progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.progressView.isUserInteractionEnabled = false
        self.progressView.isExclusiveTouch = false

        self.addSubview(self.progressView)

        self.update()
        self.hasInitFinished = true
    }

    public override func layoutSubviews()
    {
        super.layoutSubviews()
        self.progressView.layoutSubviews()
        self.update()
    }

    private func update()
    {
        self.progressView.frame = self.bounds
        self.updateStatus()
    }

    private func updateStatus()
    {
        switch self.status {
            case .paused, .waiting:
                self.imageView?.image = self.startImage

            case .downloading:
                self.imageView?.image = self.stopImage

            default: ()
        }
    }
}
