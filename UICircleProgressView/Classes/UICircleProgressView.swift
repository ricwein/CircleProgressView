//
//  UICircleProgressView.swift
//  Created by Richard Weinhold on 01.02.19.
//

import UIKit

@IBDesignable
public class UICircleProgressView: UIView
{
    public enum DownloadStatus: String
    {
        case paused
        case waiting
        case downloading
        case success
        case canceled
    }

    public enum StyleType
    {
        case old
        case new
    }

    private let rotationAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        return animation
    }()

    private var backgroundCircle: CAShapeLayer = CAShapeLayer()
    private var progressCircle: CAShapeLayer = CAShapeLayer()

    /// keep track if our class is already fully setup
    /// if not, we don't have to adapt all property-changes directly
    private var hasInitFinished: Bool = false

    /// do we currently rotate-animate our background-circle?
    private var isRotating: Bool = false

    /// actual max squared size of our frame for a perfect circle
    private var maxFrameSize: CGFloat
    {
        return min(self.frame.height, self.frame.width)
    }

    /// which strokeWidth should be used?
    private var actualStrokeWidth: CGFloat
    {
        if !self.strokeDynamic
        {
            return self.strokeWidth
        }

        switch self.style {
            case .old: return max(1.0, self.maxFrameSize) / 8.0
            case .new: return max(1.0, self.maxFrameSize) / 12.0
        }
    }

    /// default initializer
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }

    /// required default initializer
    public required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.setup()
    }

    /// custom initializer with support for multiple default-properties
    public init(frame: CGRect, style: StyleType = .old, status: DownloadStatus = .paused, progress: Float = 0.0)
    {
        super.init(frame: frame)

        self.style = style
        self.status = status
        self.progress = max(min(progress, 1.0), 0.0)

        self.setup()
    }

    /// ensures correct interfacebuilder support with live-preview
    public override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        self.setup()
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
        didSet { if self.hasInitFinished { self.updateStatus() } }
    }

    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'type' instead.")
    @IBInspectable
    public var useNewStyle: Bool = false
    {
        willSet
        {
            self.style = newValue ? .new : .old
        }
    }

    /// set which UI-style should be used, old or new?
    public var style: StyleType = .old
    {
        didSet
        {
            if self.style == .old, self.isRotating
            {
                self.stopAnimating()
            }
            else if self.style == .new, self.status == .waiting, !self.isRotating
            {
                self.startAnimating()
            }

            if self.hasInitFinished { self.update() }
        }
    }

    /// set the current progress (between 0.0 and 1.0)
    @IBInspectable
    public var progress: Float = 0.0
    {
        willSet
        {
            self.progress = max(min(newValue, 1.0), 0.0)
        }
        didSet
        {
            if self.hasInitFinished { self.updateProgress() }
        }
    }

    /// ignore explicit setted strokeWidth and use a dynamically calculated instead?
    @IBInspectable
    public var strokeDynamic: Bool = true
    {
        didSet { if self.hasInitFinished { self.updateStrokeWidth() } }
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
            if self.hasInitFinished { self.updateStrokeWidth() }
        }
    }

    @IBInspectable
    public var colorSuccess: UIColor = UIColor.green
    {
        didSet { if self.hasInitFinished { self.updateStatus() } }
    }

    @IBInspectable
    public var colorPaused: UIColor = UIColor.lightGray
    {
        didSet { if self.hasInitFinished { self.updateStatus() } }
    }

    @IBInspectable
    public var colorCanceled: UIColor = UIColor.red
    {
        didSet { if self.hasInitFinished { self.updateStatus() } }
    }

    public override func tintColorDidChange()
    {
        if self.hasInitFinished { self.updateStatus() }
    }

    private func getCirclePath(for newStrokeWidth: CGFloat) -> CGPath
    {
        let strokeDiff: CGFloat = newStrokeWidth > 1.0 ? ((newStrokeWidth - 1.0) / 2.0) : 0.0
        let maxFrameSize = self.maxFrameSize - (2.0 * strokeDiff)
        let frame = CGRect(x: strokeDiff, y: strokeDiff, width: maxFrameSize, height: maxFrameSize)
        let circlePath = UIBezierPath(roundedRect: frame, cornerRadius: maxFrameSize > 0 ? (maxFrameSize / 2.0) : 0.0)
        return circlePath.cgPath
    }

    private func setup()
    {
        self.layer.addSublayer(self.backgroundCircle)
        self.layer.addSublayer(self.progressCircle)

        self.progressCircle.strokeStart = 0.0
        self.progressCircle.fillColor = nil

        self.backgroundCircle.strokeStart = 0.0
        self.backgroundCircle.strokeEnd = 1.0
        self.backgroundCircle.fillColor = nil

        self.update()
        self.hasInitFinished = true
    }

    public override func layoutSubviews()
    {
        super.layoutSubviews()
        self.update()
    }

    private func update()
    {
        self.progressCircle.strokeEnd = CGFloat(self.progress)

        self.progressCircle.frame = CGRect(x: 0, y: 0, width: self.maxFrameSize, height: self.maxFrameSize)
        self.backgroundCircle.frame = CGRect(x: 0, y: 0, width: self.maxFrameSize, height: self.maxFrameSize)

        self.updateStatus()
        self.updateProgress()
        self.updateStrokeWidth()
    }

    private func updateStrokeWidth()
    {
        switch self.style {
            case .old:
                self.progressCircle.path = self.getCirclePath(for: self.actualStrokeWidth)
                self.progressCircle.lineWidth = self.actualStrokeWidth

                let backgroundStrokeWidth = self.actualStrokeWidth > 0 ? ceil(self.actualStrokeWidth / 10.0) : 0.0
                self.backgroundCircle.path = self.getCirclePath(for: backgroundStrokeWidth)
                self.backgroundCircle.lineWidth = backgroundStrokeWidth

            case .new:
                self.progressCircle.path = self.getCirclePath(for: self.actualStrokeWidth)
                self.progressCircle.lineWidth = self.actualStrokeWidth

                self.backgroundCircle.path = self.getCirclePath(for: self.actualStrokeWidth)
                self.backgroundCircle.lineWidth = self.actualStrokeWidth
        }
    }

    private func updateProgress()
    {
        self.progressCircle.strokeEnd = CGFloat(self.progress)

        switch self.style {
            case .old: self.backgroundCircle.strokeStart = 0.0
            case .new: if !self.isRotating { self.backgroundCircle.strokeStart = CGFloat(self.progress) }
        }
    }

    private func updateStatus()
    {
        switch self.style {
            case .old: self.updateStatusOld()
            case .new: self.updateStatusNew()
        }
    }

    private func updateStatusOld()
    {
        switch self.status {
            case .paused, .waiting:
                self.progressCircle.strokeColor = self.colorPaused.cgColor
                self.backgroundCircle.strokeColor = self.colorPaused.cgColor

            case .downloading:
                self.progressCircle.strokeColor = self.tintColor.cgColor
                self.backgroundCircle.strokeColor = self.tintColor.cgColor

            case .success:
                self.progressCircle.strokeColor = self.colorSuccess.cgColor
                self.backgroundCircle.strokeColor = self.colorSuccess.cgColor

            case .canceled:
                self.progressCircle.strokeColor = self.colorCanceled.cgColor
                self.backgroundCircle.strokeColor = self.colorCanceled.cgColor
        }
    }

    private func updateStatusNew()
    {
        switch self.status {
            case .waiting:
                self.progressCircle.strokeColor = self.tintColor.cgColor
                self.backgroundCircle.strokeColor = self.colorPaused.cgColor
                self.startAnimating()

            case .downloading, .paused:
                self.progressCircle.strokeColor = self.tintColor.cgColor
                self.backgroundCircle.strokeColor = self.colorPaused.cgColor
                self.backgroundCircle.strokeStart = CGFloat(self.progress)
                self.stopAnimating()

            case .success:
                self.progressCircle.strokeColor = self.colorSuccess.cgColor
                self.backgroundCircle.strokeColor = self.colorSuccess.cgColor
                self.backgroundCircle.strokeStart = CGFloat(self.progress)
                self.stopAnimating()

            case .canceled:
                self.progressCircle.strokeColor = self.colorCanceled.cgColor
                self.backgroundCircle.strokeColor = self.colorCanceled.cgColor
                self.backgroundCircle.strokeStart = CGFloat(self.progress)
                self.stopAnimating()
        }
    }

    /// Tries to start the waiting-rotation-animation.
    /// This is normally automatically managed be the current status.
    public func startAnimating()
    {
        if !self.isRotating
        {
            self.backgroundCircle.strokeStart = 0.15
            self.backgroundCircle.add(self.rotationAnimation, forKey: "transform.rotation")
            self.isRotating = true
        }
    }

    /// Tries to stop the waiting-rotation-animation.
    /// This is normally automatically managed be the current status.
    public func stopAnimating()
    {
        if self.isRotating
        {
            self.backgroundCircle.removeAllAnimations()
            self.isRotating = false
        }
    }
}
