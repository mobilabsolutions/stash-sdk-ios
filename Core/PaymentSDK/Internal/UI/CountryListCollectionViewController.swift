//
//  CountryListCollectionViewController.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 02.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

protocol CountryListCollectionViewControllerProtocol: class {
    func didSelectCountry(name: String)
}

class CountryListCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private enum HeaderType: Int {
        case Search
        case CurrentLocation
        case AllCountries
        
        var headerTitle: String {
            switch self {
            case .Search: return "Select Your Country"
            case .CurrentLocation: return "Current Location"
            case .AllCountries: return ""
            }
        }
        
    }

    weak var delegate: CountryListCollectionViewControllerProtocol?
    
    private typealias CountriesArray = [String]
    private typealias CountriesWithAlphabeticalGrouping =  Dictionary<String, CountriesArray>

    private let reuseIdentifier = "countryCell"
    private let titleHeaderReuseIdentifier = "titleHeader"
    private let headerReuseIdentifier = "headerId"

    private let cellHeight: CGFloat = 48
    private let minimumLineSpacing: CGFloat = 1
    private let backgroundColor = UIConstants.iceBlue
    private let cellInset: CGFloat = 0
    private let titleHeaderHeight: CGFloat = 80
    private let currentLocationHeaderHeight: CGFloat = 38
    private let headerHeight: CGFloat = 30

    private let defaultCurrentLocation: String = "Germany"

    private lazy var countriesArray: [CountriesArray] = [[defaultCurrentLocation]]
    
    private var countryHeaderTexts: [String]?
    
    private let configuration: PaymentMethodUIConfiguration
    
    init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(CountryListCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        self.collectionView.register(TitleHeaderView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.titleHeaderReuseIdentifier)
        self.collectionView.register(HeaderView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)

        self.collectionView.backgroundColor = self.configuration.backgroundColor
        
        //sticky header
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if countriesArray.count == 1 {
            readCountries()
        }
    }
    
    private func readCountries() {
        DispatchQueue.global(qos: .background).async {
            let bundle = Bundle(for: CountryListCollectionViewController.self)
            
            guard let url = bundle.url(forResource: "Countries", withExtension: "plist", subdirectory: "") else {
                fatalError("Countries.plist not found!")
            }

            do {
                let data = try Data(contentsOf: url)
                let list = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? CountriesWithAlphabeticalGrouping
                
                guard let countriesDictionary = list  else { return }
                self.countryHeaderTexts = Array(countriesDictionary.keys.sorted())
                
                for key in countriesDictionary.keys.sorted() {
                    if let countriesStartingWithAlphabet = countriesDictionary[key] {
                         self.countriesArray.append(countriesStartingWithAlphabet)
                    }
                }
                self.reload()

            } catch let err {
                fatalError(err.localizedDescription)
            }
        }
    }
    
    private func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in _: UICollectionView) -> Int {
        return countriesArray.count + 1 // 1 for search header
    }
    
    override func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == HeaderType.Search.rawValue ? 1 : countriesArray[section - 1].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CountryListCollectionViewCell
            else { fatalError("Wrong cell type for CountryListCollectionViewController. Should be CountryListCollectionViewCell") }
        
        let section = indexPath.section
        
        if section == HeaderType.Search.rawValue {
            return cell
        } else {
            cell.countryName = self.countriesArray[section - 1][indexPath.row]
        }
        cell.configuration = configuration
        return cell
    }
    
    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        
        let name = self.countriesArray[section - 1][indexPath.item]
        print(name)
        delegate?.didSelectCountry(name: name)

        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.cellHeight)
    }
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return self.minimumLineSpacing
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: HeaderView?
        
        let section = indexPath.section
        
        if section == HeaderType.Search.rawValue {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: self.titleHeaderReuseIdentifier, for: indexPath) as? TitleHeaderView
        } else {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerReuseIdentifier, for: indexPath) as? HeaderView
        }
        
        if section == HeaderType.Search.rawValue {
            header?.title = HeaderType.Search.headerTitle
        } else if indexPath.section == HeaderType.CurrentLocation.rawValue {
            header?.title = HeaderType.CurrentLocation.headerTitle
        } else {
            header?.title = countryHeaderTexts?[section - 2]
        }
        header?.backgroundColor = configuration.backgroundColor
        header?.configuration = configuration
        
        return header ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
        let height = section == HeaderType.Search.rawValue ? titleHeaderHeight :
                                section == HeaderType.CurrentLocation.rawValue ? currentLocationHeaderHeight :
                                            headerHeight
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
}
