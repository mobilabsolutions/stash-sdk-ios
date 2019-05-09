//
//  TitleHeaderView.swift
//  Sample
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//
import UIKit

class TitleHeaderView: UICollectionReusableView {
    private static let defaultTextColor = UIConstants.dark
    private let labelHeightCostant: CGFloat = 32

    var title: String? {
        didSet {
            self.label.text = self.title
        }
    }
    
    var configuration: UIConfiguration? {
        didSet {
            #warning("should use title color instead of button color")
            self.label.textColor = self.configuration?.buttonColor ?? TitleHeaderView.defaultTextColor
            self.backgroundColor = self.configuration?.backgroundColor
        }
    }
    
    let label: SubtitleLabel = {
        let label = SubtitleLabel()
        label.font = UIConstants.defaultFont(of: 16, type: .medium)
        label.textColor = UIConstants.coolGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    
    private let horizontalToSuperViewOffset: CGFloat = 16
    private let verticalToSuperViewOffset: CGFloat = -16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    func sharedInit() {
        self.addSubview(self.label)
        
        NSLayoutConstraint.activate([
            self.label.centerXAnchor.constraint(equalTo: centerXAnchor),
//            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horizontalToSuperViewOffset),
//            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -horizontalToSuperViewOffset),
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: verticalToSuperViewOffset),
            self.label.heightAnchor.constraint(equalToConstant: labelHeightCostant)
//            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -verticalToSuperViewOffset),
            ])

        self.label.font = UIConstants.defaultFont(of: 24, type: .black)
        self.label.textColor = configuration?.buttonColor
    }
}
