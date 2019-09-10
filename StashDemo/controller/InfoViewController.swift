//
//  ItemsController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import StashCore
import UIKit

class InfoViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Properties

    private let pspValues = [StashPaymentProvider.adyen, .braintree, .bsPayone]

    private let bgImageView = UIImageView(image: UIConstants.infoScreenBgImage)

    private lazy var subtitleLabel: UILabel = {
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

    private let pspPicker = UIPickerView()

    private let subtitleTopPadding: CGFloat = 20
    private let pspPickerTopPadding: CGFloat = 10
    private let backgroundImageHeightPercentage: CGFloat = 0.25
    private let backgroundImageTopPadding: CGFloat = 160

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
        self.pspPicker.isUserInteractionEnabled = !PaymentService.shared.sdkIsSetUp
        self.pspPicker.alpha = !PaymentService.shared.sdkIsSetUp ? 1.0 : 0.6
        self.pspPicker.selectRow(self.pspValues.firstIndex(of: PaymentService.shared.selectedPsp) ?? 0,
                                 inComponent: 0,
                                 animated: false)
    }

    // MARK: - Helpers

    private func setupViews() {
        view.addSubview(self.bgImageView)
        self.bgImageView.anchor(top: self.view.topAnchor, centerX: view.centerXAnchor, paddingTop: self.backgroundImageTopPadding)
        self.bgImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: self.backgroundImageHeightPercentage).isActive = true
        self.bgImageView.contentMode = .scaleAspectFit

        view.addSubview(self.subtitleLabel)
        self.subtitleLabel.anchor(top: self.bgImageView.bottomAnchor, centerX: view.centerXAnchor, paddingTop: self.subtitleTopPadding)

        setButtonVisibility(to: false)

        self.setupPspPickerView()
    }

    private func setupPspPickerView() {
        self.pspPicker.dataSource = self
        self.pspPicker.delegate = self

        self.pspPicker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pspPicker)

        self.pspPicker.anchor(top: self.subtitleLabel.bottomAnchor,
                              leading: self.view.leadingAnchor,
                              trailing: self.view.trailingAnchor,
                              paddingTop: self.pspPickerTopPadding)
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return self.pspValues.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return self.pspValues[row].rawValue
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        PaymentService.shared.selectPsp(psp: self.pspValues[row])
    }
}
