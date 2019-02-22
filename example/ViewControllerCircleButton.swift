//
//  ViewControllerCircleButton.swift
//  example
//
//  Created by Richard Weinhold on 22.02.19.
//  Copyright © 2019 CircleProgressView. All rights reserved.
//

import UIKit

class ViewControllerCircleButton: UIViewController
{
    @IBOutlet var progressButton: UICircleProgressButton!
    private var stopDownload: Bool = false

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func progress(_: Any)
    {
        DispatchQueue.global().async
        {
            self.simulateDownload()
        }
    }

    @IBAction func toggleStyleType(_ sender: UISegmentedControl)
    {
        self.progressButton.style = sender.selectedSegmentIndex == 0 ? .old : .new
    }

    private func simulateDownload()
    {
        self.stopDownload = false

        // waiting for download to start
        DispatchQueue.main.sync
        {
            self.progressButton.progress = 0.0
            self.progressButton.status = .waiting
        }

        for _ in stride(from: 0, through: 5000, by: 1)
        {
            if self.stopDownload
            {
                DispatchQueue.main.sync
                {
                    self.progressButton.status = .downloading
                    self.progressButton.progress = 0.0
                }
                return
            }
            usleep(1000)
        }

        // download started
        DispatchQueue.main.sync
        {
            self.progressButton.status = .downloading
        }

        for _ in stride(from: 0, through: 1000, by: 1)
        {
            if self.stopDownload
            {
                DispatchQueue.main.sync { self.progressButton.status = .canceled }
                return
            }
            usleep(1000)
        }

        // downloading
        for progress in stride(from: 0.0, through: 1.0, by: 0.01)
        {
            DispatchQueue.main.sync { self.progressButton.progress = Float(progress) }
            if self.stopDownload
            {
                DispatchQueue.main.sync { self.progressButton.status = .canceled }
                return
            }

            usleep(20000)
        }

        // download succeeded
        DispatchQueue.main.sync
        {
            self.progressButton.progress = 1.0
            self.progressButton.status = .success
        }

        for _ in stride(from: 0, through: 1000, by: 1)
        {
            if self.stopDownload
            {
                DispatchQueue.main.sync { self.progressButton.status = .canceled }
                return
            }
            usleep(1000)
        }

        // change color, just for fun
        DispatchQueue.main.sync
        {
            self.progressButton.colorSuccess = UIColor(red: 0.113, green: 0.725, blue: 0.329, alpha: 1)
        }
    }

    @IBAction func buttonPressed(_: UICircleProgressButton)
    {
        self.stopDownload = !self.stopDownload
        print("toggled to: \(self.stopDownload)")
    }
}
