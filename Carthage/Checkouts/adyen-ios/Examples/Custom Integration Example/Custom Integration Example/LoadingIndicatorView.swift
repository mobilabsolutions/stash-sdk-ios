//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class LoadingIndicatorView: UIView {
    // MARK: - UIView

    override var frame: CGRect {
        didSet {
            let expectedSize = CGSize(width: LoadingIndicatorView.sideLength, height: LoadingIndicatorView.sideLength)
            if expectedSize != self.frame.size {
                var staticSizeFrame = self.frame
                staticSizeFrame.size = expectedSize
                self.frame = staticSizeFrame
            }
        }
    }

    // MARK: - Public

    static func defaultLoadingIndicator() -> LoadingIndicatorView {
        let side = LoadingIndicatorView.sideLength
        let loading = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: side, height: side))
        loading.backgroundColor = Theme.primaryColor
        loading.layer.cornerRadius = side / 2.0

        loading.imageView.frame = loading.bounds
        loading.imageView.contentMode = .center
        loading.addSubview(loading.imageView)

        return loading
    }

    func start() {
        self.shouldStopAnimating = false
        self.rotate()
    }

    func stop() {
        self.shouldStopAnimating = true
    }

    func markAsCompleted() {
        self.shouldStopAnimating = true
        self.shouldMarkAsCompleted = true
    }

    func markAsError() {
        self.shouldStopAnimating = true
        self.shouldMarkAsError = true
    }

    // MARK: - Private

    private static var sideLength: CGFloat = Theme.buttonHeight
    private var imageView = UIImageView(image: UIImage(named: "loading_indicator"))

    private var shouldStopAnimating = false
    private var shouldMarkAsCompleted = false
    private var shouldMarkAsError = false

    private func rotate() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: { () -> Void in
            self.imageView.transform = self.imageView.transform.rotated(by: CGFloat.pi / 2)
        }) { (_) -> Void in
            if !self.shouldStopAnimating {
                self.rotate()
            } else if self.shouldMarkAsCompleted {
                self.imageView.transform = CGAffineTransform.identity
                self.imageView.image = UIImage(named: "checkmark")
            } else if self.shouldMarkAsError {
                self.imageView.transform = CGAffineTransform.identity
                self.imageView.image = UIImage(named: "error")?.withRenderingMode(.alwaysTemplate)
                self.imageView.tintColor = UIColor.white
                self.backgroundColor = Theme.errorColor
            }
        }
    }
}
