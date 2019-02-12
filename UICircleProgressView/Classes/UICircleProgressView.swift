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

    private func newCircleLayer() -> CAShapeLayer
    {
        let shape = CAShapeLayer()
        self.layer.addSublayer(shape)
        return shape
    }

    private let rotationAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 1.0
        animation.repeatCount = .infinity
        return animation
    }()

    private lazy var backgroundCircle: CAShapeLayer = self.newCircleLayer()
    private lazy var progressCircle: CAShapeLayer = self.newCircleLayer()

    private var maxFrameSize: CGFloat
    {
        return min(self.frame.height, self.frame.width)
    }

    private var actualStrokeWidth: CGFloat
    {
        if !self.strokeDynamic
        {
            return self.strokeWidth
        }

        switch self.type {
            case .old: return max(1.0, self.maxFrameSize) / 8.0
            case .new: return max(1.0, self.maxFrameSize) / 12.0
        }
    }

    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }

    public convenience init(frame: CGRect, style: StyleType = .old)
    {
        self.init(frame: frame)
        self.type = style
    }

    public required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.setup()
    }

    private var isRotating: Bool = false

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

    public var status: DownloadStatus = .paused
    {
        didSet { self.updateStatus() }
    }

    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'type' instead.")
    @IBInspectable
    public var oldStyleType: Bool = true
    {
        willSet
        {
            self.type = newValue ? .old : .new
        }
    }

    public var type: StyleType = .old
    {
        didSet { self.update() }
    }

    @IBInspectable
    public var progress: Float = 0.0
    {
        willSet
        {
            self.progress = max(min(newValue, 1.0), 0.0)
        }
        didSet
        {
            self.updateProgress()
        }
    }

    @IBInspectable
    public var strokeDynamic: Bool = true
    {
        didSet
        {
            self.updateStrokeWidth()
        }
    }

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
            self.updateStrokeWidth()
        }
    }

    @IBInspectable
    public var colorSuccess: UIColor = UIColor.green
    {
        didSet { self.updateStatus() }
    }

    @IBInspectable
    public var colorPaused: UIColor = UIColor.lightGray
    {
        didSet { self.updateStatus() }
    }

    @IBInspectable
    public var colorCanceled: UIColor = UIColor.red
    {
        didSet { self.updateStatus() }
    }

    public override func tintColorDidChange()
    {
        self.updateStatus()
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
        self.progressCircle.strokeStart = 0.0
        self.progressCircle.fillColor = nil

        self.backgroundCircle.strokeStart = 0.0
        self.backgroundCircle.strokeEnd = 1.0
        self.backgroundCircle.fillColor = nil

        self.update()
    }

    public override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        self.setup()
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
        self.updateStrokeWidth()
    }

    private func updateStrokeWidth()
    {
        switch self.type {
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

        switch self.type {
            case .old: self.backgroundCircle.strokeStart = 0.0
            case .new: if !self.isRotating { self.backgroundCircle.strokeStart = CGFloat(self.progress) }
        }
    }

    private func updateStatus()
    {
        switch self.type {
            case .old:
                self.updateStatusOld()
            case .new:
                self.updateStatusNew()
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

                if !self.isRotating
                {
                    self.backgroundCircle.strokeStart = 0.15
                    self.backgroundCircle.add(self.rotationAnimation, forKey: "transform.rotation")
                    self.isRotating = true
                }

            case .downloading, .paused:
                self.progressCircle.strokeColor = self.tintColor.cgColor
                self.backgroundCircle.strokeColor = self.colorPaused.cgColor
                self.backgroundCircle.strokeStart = CGFloat(self.progress)
                if self.isRotating
                {
                    self.backgroundCircle.removeAllAnimations()
                    self.isRotating = false
                }

            case .success:
                self.progressCircle.strokeColor = self.colorSuccess.cgColor
                self.backgroundCircle.strokeColor = self.colorSuccess.cgColor
                self.backgroundCircle.strokeStart = CGFloat(self.progress)
                if self.isRotating
                {
                    self.backgroundCircle.removeAllAnimations()
                    self.isRotating = false
                }

            case .canceled:
                self.progressCircle.strokeColor = self.colorCanceled.cgColor
                self.backgroundCircle.strokeColor = self.colorCanceled.cgColor
                self.backgroundCircle.strokeStart = CGFloat(self.progress)
                if self.isRotating
                {
                    self.backgroundCircle.removeAllAnimations()
                    self.isRotating = false
                }
        }
    }
}
