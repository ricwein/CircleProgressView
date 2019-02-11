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
        case remote
        case downloading
        case paused
        case resumed
        case success
        case waiting
        case canceled
    }

    private func newCircleLayer() -> CAShapeLayer
    {
        let shape = CAShapeLayer()
        self.layer.addSublayer(shape)
        return shape
    }

    private lazy var progressCircle: CAShapeLayer = self.newCircleLayer()
    private lazy var backgroundCircle: CAShapeLayer = self.newCircleLayer()

    private var maxFrameSize: CGFloat
    {
        return min(self.frame.height, self.frame.width)
    }

    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.setup()
    }

    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'status' instead.")
    @IBInspectable
    public var statusType: String? = "downloading"
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

    public var status: DownloadStatus = .remote
    {
        didSet { self.updateStatusColor() }
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
            self.progressCircle.strokeEnd = CGFloat(self.progress)
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
        didSet { self.updateStatusColor() }
    }

    @IBInspectable
    public var colorPaused: UIColor = UIColor.lightGray
    {
        didSet { self.updateStatusColor() }
    }

    @IBInspectable
    public var colorCanceled: UIColor = UIColor.red
    {
        didSet { self.updateStatusColor() }
    }

    public override func tintColorDidChange()
    {
        self.updateStatusColor()
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
        self.progressCircle.strokeStart = 0
        self.progressCircle.fillColor = nil

        self.backgroundCircle.strokeStart = 0
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

        self.updateStatusColor()
        self.updateStrokeWidth()
    }

    private func updateStrokeWidth()
    {
        let actualStrokeWidth = self.strokeDynamic ? (max(1.0, self.maxFrameSize) / 8.0) : self.strokeWidth

        self.progressCircle.path = self.getCirclePath(for: actualStrokeWidth)
        self.progressCircle.lineWidth = actualStrokeWidth

        let backgroundStrokeWidth = actualStrokeWidth > 0 ? ceil(actualStrokeWidth / 10.0) : 0.0
        self.backgroundCircle.path = self.getCirclePath(for: backgroundStrokeWidth)
        self.backgroundCircle.lineWidth = backgroundStrokeWidth
    }

    private func updateStatusColor()
    {
        switch self.status {
            case .remote:
                self.progressCircle.strokeColor = self.colorPaused.cgColor
                self.backgroundCircle.strokeColor = self.tintColor.cgColor

            case .downloading, .resumed:
                self.progressCircle.strokeColor = self.tintColor.cgColor
                self.backgroundCircle.strokeColor = self.tintColor.cgColor

            case .success:
                self.progressCircle.strokeColor = self.colorSuccess.cgColor
                self.backgroundCircle.strokeColor = self.colorSuccess.cgColor

            case .paused, .waiting:
                self.progressCircle.strokeColor = self.colorPaused.cgColor
                self.backgroundCircle.strokeColor = self.colorPaused.cgColor

            case .canceled:
                self.progressCircle.strokeColor = self.colorCanceled.cgColor
                self.backgroundCircle.strokeColor = self.colorCanceled.cgColor
        }
    }
}
