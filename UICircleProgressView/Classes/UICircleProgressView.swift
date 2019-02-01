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
    }

    private var progressCircle = CAShapeLayer()
    private var backgroundCircle = CAShapeLayer()

    public required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.drawCircle()
    }

    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.drawCircle()
    }

    @IBInspectable
    public var strokeWidth: CGFloat = 3.0 {
        willSet
        {
            self.strokeWidth = max(min(newValue, self.frame.height / 2.0, self.frame.width / 2.0), 0.0)
        }

        didSet
        {
            self.progressCircle.path = self.getCirclePath(for: self.strokeWidth)
            self.progressCircle.lineWidth = self.strokeWidth
        }
    }

    @IBInspectable
    public var progress: Float = 0.0 {
        willSet
        {
            self.progress = max(min(newValue, 1.0), 0.0)
        }
        didSet
        {
            self.progressCircle.strokeEnd = CGFloat(self.progress)
        }
    }

    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'status' instead.")
    @IBInspectable
    public var statusType: String? = "downloading"
    {
        willSet
        {
            if let newStatus = DownloadStatus(rawValue: newValue?.lowercased() ?? "")
            {
                self.status = newStatus
            }
        }
    }

    public var status: DownloadStatus = .remote
    {
        didSet
        {
            switch self.status {
                case .remote:
                    self.progressCircle.strokeColor = UIColor.gray.cgColor
                case .downloading:
                    self.progressCircle.strokeColor = self.tintColor.cgColor
                case .success:
                    self.progressCircle.strokeColor = UIColor.green.cgColor
                case .paused:
                    self.progressCircle.strokeColor = UIColor.gray.cgColor
                case .resumed:
                    self.progressCircle.strokeColor = self.tintColor.cgColor
            }
        }
    }

    public override func tintColorDidChange()
    {
        self.backgroundCircle.strokeColor = self.tintColor.cgColor

        switch self.status {
            case .downloading, .resumed:
                self.progressCircle.strokeColor = self.tintColor.cgColor
            default:
                return
        }
    }

    private func getCirclePath(for newStrokeWidth: CGFloat) -> CGPath
    {
        let strokeDiff: CGFloat = (newStrokeWidth - 1.0) / 2.0
        let maxFrameSize = min(self.frame.height, self.frame.width) - (2.0 * strokeDiff)
        let frame = CGRect(x: strokeDiff, y: strokeDiff, width: maxFrameSize, height: maxFrameSize)
        let circlePath = UIBezierPath(roundedRect: frame, cornerRadius: (maxFrameSize / 2.0))
        return circlePath.cgPath
    }

    private func drawCircle()
    {
        let circlePath = self.getCirclePath(for: self.strokeWidth)
        let outerCirclePath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height), cornerRadius: self.frame.height / 2).cgPath

        self.progressCircle.path = circlePath
        self.progressCircle.lineWidth = self.strokeWidth
        self.progressCircle.strokeColor = UIColor.white.cgColor
        self.progressCircle.strokeStart = 0
        self.progressCircle.strokeEnd = CGFloat(self.progress)
        self.progressCircle.fillColor = nil

        self.backgroundCircle.path = outerCirclePath
        self.backgroundCircle.lineWidth = 1
        self.backgroundCircle.strokeColor = self.tintColor.cgColor
        self.backgroundCircle.strokeStart = 0
        self.backgroundCircle.strokeEnd = 1.0
        self.backgroundCircle.fillColor = nil

        self.layer.addSublayer(self.progressCircle)
        self.layer.addSublayer(self.backgroundCircle)
    }
}
