//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormLabel: UIStackView {
    public init() {
        super.init(frame: CGRect.zero)

        addArrangedSubview(self.label)
        layoutMargins = UIEdgeInsets(top: self.margin, left: 0, bottom: self.margin, right: 0)
        isLayoutMarginsRelativeArrangement = true
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    public var textAttributes = Appearance.shared.textAttributes

    public var attributedTitle: NSAttributedString? {
        didSet {
            guard let attributedTitle = attributedTitle else {
                return
            }

            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedTitle)
            mutableAttributedString.addAttributes(self.textAttributes, range: NSRange(location: 0, length: mutableAttributedString.length))
            self.label.attributedText = mutableAttributedString
            self.dynamicTypeController.observeDynamicType(for: self.label, withTextAttributes: self.textAttributes, textStyle: .body)
            accessibilityLabel = attributedTitle.string
        }
    }

    public var text: String? {
        didSet {
            guard let text = text else {
                return
            }

            let attributedTitle = NSAttributedString(string: text, attributes: textAttributes)
            label.attributedText = attributedTitle
            self.dynamicTypeController.observeDynamicType(for: self.label, withTextAttributes: self.textAttributes, textStyle: .body)
            accessibilityLabel = text
        }
    }

    public var onLabelTap: (() -> Void)?

    // MARK: - Private

    private let dynamicTypeController = DynamicTypeController()
    private let margin: CGFloat = 16.0

    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)

        return label
    }()

    @objc private func didTapLabel() {
        self.onLabelTap?()
    }
}
