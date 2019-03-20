//
//  DoneButtonCollectionViewCell.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 18.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

protocol DoneButtonCellDelegate: class {
    func didTapDoneButton()
}

class DoneButtonCollectionViewCell: UICollectionViewCell {
    private var doneEnabled: Bool = false {
        didSet {
            self.button.isEnabled = self.doneEnabled
            self.button.backgroundColor = self.doneEnabled ? .black : .lightGray
        }
    }

    private weak var delegate: DoneButtonCellDelegate?

    private let button = UIButton()

    func setup(delegate: DoneButtonCellDelegate, buttonEnabled: Bool) {
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

        self.button.setTitle("Add", for: .normal)
        self.button.setTitleColor(.white, for: .normal)
        self.button.backgroundColor = .black
        self.button.layer.cornerRadius = 5
        self.button.layer.masksToBounds = true

        self.button.addTarget(self, action: #selector(self.didTapButton), for: .touchUpInside)

        contentView.addSubview(self.button)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    @objc private func didTapButton() {
        self.delegate?.didTapDoneButton()
    }
}
