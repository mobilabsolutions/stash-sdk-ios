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
    let defaultSectionInsets: UIEdgeInsets
    let defaultSectionLineSpacing: CGFloat = 8
    let defaultTopInset: CGFloat = 40
    
    private let configuration: PaymentMethodUIConfiguration
    
    private let buttonHeight: CGFloat = 44
    private let amountViewHeight: CGFloat = 32
    
    var availableBottomAnchor: NSLayoutYAxisAnchor {
        get {
            return button.topAnchor
        }
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
        button.addTarget(self, action: #selector(handleCheckout), for: .touchUpInside)
        
        return button
    }()
    
    private let amountInfoView = UIView()
    
    // MARK: public methods
    
    func setTitle(title: String) {
        // attributed navigation title
        let attributes = [NSAttributedString.Key.font: UIConstants.defaultFont(of: 24, type: UIConstants.DefaultFontType.bold)]
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSMutableAttributedString(string: title, attributes: attributes)
        titleLabel.textColor = UIConstants.aquamarine
        
        navigationItem.titleView = titleLabel
    }
    
    func setButtonTitle(title: String) {
        button.setTitle(title, for: .normal)
    }
    
    func setButtonVisibility(to status: Bool) {
        button.isHidden = !status
    }
    
    func setButtonInteraction(to status: Bool) {
        button.isUserInteractionEnabled = status
        button.backgroundColor = status == true ? UIConstants.aquamarine : UIConstants.coolGrey
    }
    
    // MARK: - Initializers
    
    public init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        defaultSectionInsets = UIEdgeInsets(top: defaultTopInset, left: self.defaultInset, bottom: self.defaultInset, right: self.defaultInset)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCollectionView()
    }
    
    // MARK: Handlers
    
    @objc private func handleCheckout() {
    }
    
    // MARK: - Helpers
    private func setupViews() {
        view.backgroundColor = configuration.backgroundColor
        button.backgroundColor = configuration.buttonColor

        view.addSubview(button)
        let tabBarHeight: CGFloat = tabBarController?.tabBar.frame.height ?? 0
        button.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: defaultInset, paddingBottom: tabBarHeight + defaultInset, paddingRight: defaultInset, height: buttonHeight)
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = configuration.backgroundColor
        collectionView.scrollIndicatorInsets.top = defaultSectionInsets.top
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = defaultSectionInsets
            layout.minimumLineSpacing = defaultSectionLineSpacing
        }
    }
}
