//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal final class ListItemView: UIView {
    internal init() {
        super.init(frame: .zero)

        addSubview(self.imageView)
        addSubview(self.titleLabel)
        addSubview(self.subtitleLabel)

        self.configureConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    internal var title: String = "" {
        didSet {
            self.updateTitle()
        }
    }

    internal var subtitle: String = "" {
        didSet {
            self.updateSubtitle()
        }
    }

    internal var titleAttributes: [NSAttributedString.Key: Any]? {
        didSet {
            self.updateTitle()
        }
    }

    internal var imageURL: URL? {
        didSet {
            if let imageURL = imageURL {
                self.imageView.downloadImage(from: imageURL)
            } else {
                self.imageView.image = nil
            }
        }
    }

    // MARK: - Private

    private let dynamicTypeController = DynamicTypeController()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4.0
        imageView.layer.borderWidth = 1.0 / UIScreen.main.nativeScale
        imageView.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isAccessibilityElement = false

        return titleLabel
    }()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.isAccessibilityElement = false

        return subtitleLabel
    }()

    private func configureConstraints() {
        let constraints = [
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 40.0),
            imageView.heightAnchor.constraint(equalToConstant: 26.0),

            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20.0),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
            subtitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]

        titleLabel.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)

        NSLayoutConstraint.activate(constraints)
    }

    private func updateTitle() {
        if let titleAttributes = titleAttributes {
            let attributedTitle = NSMutableAttributedString(string: title, attributes: titleAttributes)

            titleLabel.attributedText = attributedTitle

            self.dynamicTypeController.observeDynamicType(for: self.titleLabel, withTextAttributes: titleAttributes, textStyle: .body)
        } else {
            let preferredLabelFont = UIFont.systemFont(ofSize: 17)
            self.dynamicTypeController.observeDynamicType(for: self.titleLabel, withTextAttributes: [.font: preferredLabelFont], textStyle: .body)
            self.titleLabel.text = self.title
        }
    }

    private func updateSubtitle() {
        let attributes = Appearance.shared.listAttributes.cellSubtitleAttributes
        let attributedSubtitle = NSMutableAttributedString(string: subtitle, attributes: attributes)
        subtitleLabel.attributedText = attributedSubtitle
        self.dynamicTypeController.observeDynamicType(for: self.subtitleLabel, withTextAttributes: attributes, textStyle: .body)
    }
}
