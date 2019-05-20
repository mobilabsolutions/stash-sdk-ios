//
//  BaseCollectionViewController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class BaseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    private let configuration: PaymentMethodUIConfiguration

    private let cellInset: CGFloat = 16
    private let defaultHeaderHeight: CGFloat = 65

    // MARK: - Initializers

    public init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCollectionView()
    }

    // MARK: CollectionView methods

    // MARK: - Helpers

    func setTitle(title: String) {
        // attributed navigation title
        let attributes = [NSAttributedString.Key.font: UIConstants.defaultFont(of: 24, type: UIConstants.DefaultFontType.black)]

        let titleLabel = UILabel()
        titleLabel.attributedText = NSMutableAttributedString(string: title, attributes: attributes)
        titleLabel.textColor = self.configuration.buttonColor

        navigationItem.titleView = titleLabel
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = self.configuration.backgroundColor
    }
}
