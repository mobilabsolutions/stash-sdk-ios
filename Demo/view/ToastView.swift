//
//  ToastView.swift
//  Demo
//
//  Created by Rupali Ghate on 27.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class ToastView: UILabel {
    // MARK: Properties

    private let animationDuration: TimeInterval = 1
    private let labelHeight: CGFloat = 35
    private let bottomOffset: CGFloat = -25

    // MARK: Public Methods

    func showMessage(withText message: String) {
        text = " \(message)  "

        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        rootVC?.view.addSubview(self)

        UIView.animate(withDuration: self.animationDuration, animations: {
            self.alpha = 1
        }) { _ in
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(white: 0, alpha: 0.7)

        textAlignment = .center
        textColor = .white
        font = UIFont.systemFont(ofSize: 16)

        numberOfLines = 0
        lineBreakMode = .byWordWrapping

        alpha = 0
    }

    private var widthAnchorConstraint: NSLayoutConstraint?

    override func didMoveToSuperview() {
        guard let superView = self.superview else { return }

        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: self.bottomOffset).isActive = true
        heightAnchor.constraint(equalToConstant: self.labelHeight).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
