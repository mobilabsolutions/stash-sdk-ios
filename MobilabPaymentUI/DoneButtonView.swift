//
//  DoneButtonView.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public protocol DoneButtonViewDelegate: class {
    func didTapDoneButton()
}

public protocol DoneButtonUpdating {
    func updateDoneButton(enabled: Bool)
}

public protocol DoneButtonUpdater: class {
    var doneButtonUpdating: DoneButtonUpdating? { get set }
}

public class DoneButtonView: UIView {
    public var doneEnabled: Bool = false {
        didSet {
            self.button.isEnabled = self.doneEnabled
            self.button.backgroundColor = self.doneEnabled ? UIConstants.aquamarine : UIConstants.disabledColor
        }
    }

    private let buttonHeight: CGFloat = 40

    private weak var delegate: DoneButtonViewDelegate?
    private let button = UIButton()

    public func setup(delegate: DoneButtonViewDelegate, buttonEnabled: Bool) {
        self.doneEnabled = buttonEnabled
        self.delegate = delegate
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.button.translatesAutoresizingMaskIntoConstraints = false

        self.button.setTitle("SAVE", for: .normal)
        self.button.setTitleColor(.white, for: .normal)
        self.button.backgroundColor = UIConstants.trueBlue
        self.button.setTitleColor(.white, for: .normal)
        self.button.layer.cornerRadius = 5
        self.button.layer.masksToBounds = true
        self.button.titleLabel?.font = UIConstants.defaultFont(of: 14, type: .medium)

        self.button.addTarget(self, action: #selector(self.didTapButton), for: .touchUpInside)

        self.addSubview(self.button)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
    }

    @objc private func didTapButton() {
        self.delegate?.didTapDoneButton()
    }
}
