//
//  ViewControllerCircleView.swift
//  example
//
//  Created by Richard Weinhold on 12.02.19.
//  Copyright © 2019 CircleProgressView. All rights reserved.
//

import UIKit

class ViewControllerCircleView: UIViewController
{
    @IBOutlet var progressView: UICircleProgressView!

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
        self.progressView.style = sender.selectedSegmentIndex == 0 ? .old : .new
    }

    private func simulateDownload()
    {
        // waiting for download to start
        DispatchQueue.main.sync
        {
            self.progressView.progress = 0.0
            self.progressView.status = .waiting
        }
        usleep(5_000_000)

        // download started
        DispatchQueue.main.sync
        {
            self.progressView.status = .downloading
        }
        usleep(1_000_000)

        // downloading
        for progress in stride(from: 0.0, through: 1.0, by: 0.01)
        {
            DispatchQueue.main.sync
            {
                self.progressView.progress = Float(progress)
            }
            usleep(20000)
        }

        // download succeeded
        DispatchQueue.main.sync
        {
            self.progressView.progress = 1.0
            self.progressView.status = .success
        }
        usleep(1_000_000)

        // change color, just for fun
        DispatchQueue.main.sync
        {
            self.progressView.colorSuccess = UIColor(red: 0.113, green: 0.725, blue: 0.329, alpha: 1)
        }
    }
}
