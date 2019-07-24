//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view controller that displays an activity indicator to indicate a loading state.
internal final class LoadingViewController: ShortViewController {
    // MARK: - UIViewController

    override func loadView() {
        view = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

        view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()

        self.applyConstraints()
    }

    // MARK: - Internal

    internal var activityIndicatorColor: UIColor? {
        didSet {
            if let activityIndicatorColor = activityIndicatorColor {
                self.activityIndicator.color = activityIndicatorColor
            }
        }
    }

    // MARK: - Private

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = UIColor.lightGray
        return activityIndicatorView
    }()

    private func applyConstraints() {
        let constraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -11.0),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
