//
//  BaseViewController.swift
//  Demo
//
//  Created by Rupali Ghate on 23.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class BaseViewController: UIViewController {
    // MARK: - Properties

    let defaultInset: CGFloat = 16
    let defaultSectionLineSpacing: CGFloat = 8
    let defaultSectionInsets: UIEdgeInsets

    private let defaultTopInset: CGFloat = 40
    private let buttonHeight: CGFloat = 44
    private let amountViewHeight: CGFloat = 32

    private let configuration: PaymentMethodUIConfiguration

    var availableBottomAnchor: NSLayoutYAxisAnchor {
        return self.button.topAnchor
    }

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()

    private lazy var totalAmountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIConstants.defaultFont(of: 18, type: .bold)
        label.textColor = UIConstants.dark
        label.text = "Total Amount"

        return label
    }()

    private lazy var amountValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIConstants.defaultFont(of: 24, type: .black)
        label.textColor = UIConstants.aquamarine
        label.text = NSDecimalNumber(integerLiteral: 0).toCurrency()

        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = false
        button.titleLabel?.font = UIConstants.defaultFont(of: 14, type: .bold)
        button.addTarget(self, action: #selector(handleScreenButtonSelection), for: .touchUpInside)

        return button
    }()

    private let amountInfoView = UIView()

    // MARK: public methods

    func setTitle(title: String) {
        let attributes = [NSAttributedString.Key.font: UIConstants.defaultFont(of: 24, type: UIConstants.DefaultFontType.bold)]
        let attributedText = NSMutableAttributedString(string: title, attributes: attributes)

        let titleLabel = UILabel()
        titleLabel.attributedText = attributedText
        titleLabel.textColor = UIConstants.aquamarine
        navigationItem.titleView = titleLabel
    }

    func setButtonTitle(title: String) {
        self.button.setTitle(title, for: .normal)
    }

    func setButtonVisibility(to status: Bool) {
        self.button.isHidden = !status
    }

    func setButtonInteraction(to status: Bool) {
        self.button.isUserInteractionEnabled = status
        self.button.backgroundColor = status == true ? UIConstants.aquamarine : UIConstants.coolGrey
    }

    // MARK: - Initializers

    public init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        self.defaultSectionInsets = UIEdgeInsets(top: self.defaultTopInset, left: self.defaultInset, bottom: self.defaultInset, right: self.defaultInset)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupCollectionView()
    }

    // MARK: Handlers

    @objc func handleScreenButtonSelection() {}

    // MARK: - Helpers

    private func setupViews() {
        view.backgroundColor = self.configuration.backgroundColor
        self.button.backgroundColor = self.configuration.buttonColor

        view.addSubview(self.button)
        let tabBarHeight: CGFloat = tabBarController?.tabBar.isHidden == false ? tabBarController?.tabBar.frame.height ?? 0 : 0
        self.button.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: self.defaultInset, paddingBottom: tabBarHeight + 24, paddingRight: self.defaultInset, height: self.buttonHeight)
    }

    private func setupCollectionView() {
        self.collectionView.backgroundColor = self.configuration.backgroundColor
        self.collectionView.scrollIndicatorInsets.top = self.defaultSectionInsets.top

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = self.defaultSectionInsets
            layout.minimumLineSpacing = self.defaultSectionLineSpacing
        }
    }
}
