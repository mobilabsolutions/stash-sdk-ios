//
//  BaseCollectionViewController.swift
//  Sample
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import UIKit

class BaseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    private let configuration: UIConfiguration
    
    let screenTitle: String
    private let titleHeaderReuseIdentifier = "titleHeader"
    
    private let cellInset: CGFloat = 16
    private let defaultHeaderHeight: CGFloat = 65
    
    // MARK: - Initializers
    
    public init(configuration: UIConfiguration, title: String) {
        self.configuration = configuration
        self.screenTitle = title
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    
    // MARK: CollectionView methods
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: titleHeaderReuseIdentifier, for: indexPath) as? TitleHeaderView
            else { fatalError("Should be able to dequeue TitleHeaderView as header supplementary vie for \(self.titleHeaderReuseIdentifier)") }
        
        headerView.title = self.screenTitle
        headerView.configuration = self.configuration
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width - 2 * cellInset, height: defaultHeaderHeight)
    }
    
    // MARK: - Helpers
    
    func setupCollectionView() {
        collectionView.backgroundColor = configuration.backgroundColor

        collectionView.register(TitleHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.titleHeaderReuseIdentifier)
        
    }
    
    
}
