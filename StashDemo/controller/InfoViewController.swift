//
//  ItemsController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import StashCore
import UIKit

class InfoViewController: BaseViewController {
    // MARK: - Properties

    private let bgImageView = UIImageView(image: UIConstants.infoScreenBgImage)

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIConstants.defaultFont(of: 12, type: .regular)
        label.textColor = UIConstants.coolGrey
        label.numberOfLines = 0

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center

        let text = "APP Version \(InfoService.getDemoAppVersion())\r SDK Version \(InfoService.getSDKVersion())\r Backend Version \(InfoService.getBackendVersion())"
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))

        label.attributedText = attrString
        return label
    }()

    private let subTitleTopPadding: CGFloat = 20

    private let configuration: PaymentMethodUIConfiguration

    // MARK: - Initializers

    override init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        super.init(configuration: configuration)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(title: "Info")

        self.setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Helpers

    private func setupViews() {
        view.addSubview(self.bgImageView)
        self.bgImageView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor)

        view.addSubview(self.subTitleLabel)
        self.subTitleLabel.anchor(top: self.bgImageView.bottomAnchor, centerX: view.centerXAnchor, paddingTop: self.subTitleTopPadding)

        setButtonVisibility(to: false)
    }
}
