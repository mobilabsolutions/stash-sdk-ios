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

class CountryListCollectionViewController: UIViewController {
    private enum HeaderType: Int {
        case CurrentLocation = 0
        case AllCountries
        
        var index: Int {
            return self.rawValue
        }
        
        var title: String {
            switch self {
            case .CurrentLocation: return "Current Location"
            default: return ""
            }
        }
    }
    
    weak var delegate: CountryListCollectionViewControllerProtocol?
    
    private typealias GroupedCountries = Dictionary<String, [String]>
    
    private let resourceFileName = "Countries"
    private let resourceFileExtension = "plist"
    
    private let reuseIdentifier = "countryCell"
    private let titleHeaderReuseIdentifier = "titleHeader"
    private let headerReuseIdentifier = "headerId"
    
    private let cellHeight: CGFloat = 48
    private let minimumLineSpacing: CGFloat = 1
    private let backgroundColor = UIConstants.iceBlue
    private let cellInset: CGFloat = 0
    private let titleHeaderHeight: CGFloat = 60
    private let currentLocationHeaderHeight: CGFloat = 38
    private let headerHeight: CGFloat = 30
    private let searchBarHeight: CGFloat = 57
    
    private let defaultCurrentLocation: String = "Germany"
    
    private var countries: GroupedCountries = GroupedCountries()
    private var allCountries: GroupedCountries = GroupedCountries()
    private var countryHeaderTexts: [String] = [HeaderType.CurrentLocation.title]
    private var allCountryHeaders = [String]()
    
    private let configuration: PaymentMethodUIConfiguration
    
    private var isSearching: Bool = false
    
    private lazy var timer: Timer? = nil
    
    private let headerView: TitleHeaderView = {
        let view = TitleHeaderView()
        view.title = "Select Your Country"
        return view
    }()
    
    private let searchView = SearchView(frame: .zero)
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = configuration.backgroundColor
        
        view.addSubview(headerView)
        headerView.configuration = configuration
        
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                          bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor,
                          paddingTop: 0, paddingLeft: 0,
                          paddingBottom: 0, paddingRight: 0,
                          width: 0, height: titleHeaderHeight)
        
        view.addSubview(searchView)
        searchView.anchor(top: headerView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                          bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor,
                          paddingTop: 0, paddingLeft: 0,
                          paddingBottom: 0, paddingRight: 0,
                          width: 0, height: searchBarHeight)
        
        view.addSubview(collectionView)
        collectionView.anchor(top: searchView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                              bottom: view.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor,
                              paddingTop: 0, paddingLeft: 0,
                              paddingBottom: 0, paddingRight: 0,
                              width: 0, height: 0)
        
        self.searchView.setup(text: nil,
                              borderColor: .clear,
                              placeholder: "Search Country",
                              textFieldFocusGainCallback: nil,
                              textFieldUpdateCallback: {[weak self] textField in
                                
                                guard let self = self else { return }
                                let keyword = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
                                self.handleSearch(with: keyword)
                                
            }, configuration: self.configuration)
        
        self.countries = [HeaderType.CurrentLocation.title : [defaultCurrentLocation]]
        
        self.searchView.delegate = self
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(CountryListCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.register(TitleHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.titleHeaderReuseIdentifier)
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)
        
        collectionView.backgroundColor = self.configuration.backgroundColor
        
        //sticky header
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if countries.keys.count == 1 {
            readCountries()
        }
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        
        stopTimer()
    }
    
    private func readCountries() {
        DispatchQueue.global(qos: .background).async {
            let bundle = Bundle(for: CountryListCollectionViewController.self)
            
            guard let url = bundle.url(forResource: self.resourceFileName, withExtension: self.resourceFileExtension, subdirectory: "") else {
                fatalError("\(self.resourceFileName).\(self.resourceFileExtension) not found!")
            }
            
            do {
                let data = try Data(contentsOf: url)
                let list = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? GroupedCountries
                
                guard let countriesDictionary = list  else { return }
                let keys = Array(countriesDictionary.keys.sorted())
                
                for key in keys {
                    if let countriesStartingWithAlphabet = countriesDictionary[key] {
                        self.countries[key] = countriesStartingWithAlphabet
                    }
                }
                self.countryHeaderTexts.append(contentsOf: keys)
                
                self.allCountries = self.countries
                self.allCountryHeaders = self.countryHeaderTexts    //keep a backup
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
    
    private func handleSearch(with keyword: String) {
        stopTimer()
        
        countries = allCountries
        countryHeaderTexts = allCountryHeaders
        
        if keyword.count == 0 {
            self.reload()
            return
        }
        
        isSearching = true
        
        let countries = self.countries.count > 0 ? self.countries : self.allCountries
        
        //add some delay to fetch. This is to avoid fetch call for every character change in searchbar
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self](_) in
            guard let self = self else { return }
            
            self.filter(groupedCountries: countries, byString: keyword)
            self.reload()
        })
    }
    
    private func filter(groupedCountries : GroupedCountries, byString keyword : String) {
        DispatchQueue.global(qos: .background).sync {
            var newGrouping = GroupedCountries()
            
            for (startingLetterKey, countries) in groupedCountries {
                if startingLetterKey == HeaderType.CurrentLocation.title {
                    continue
                }
                let result = countries.filter { (countryName) -> Bool in
                    return countryName.localizedCaseInsensitiveContains(keyword)
                }
                if result.count > 0 {
                    newGrouping[startingLetterKey] = result
                }
            }
            self.countries = newGrouping
            self.countryHeaderTexts = self.countries.keys.sorted()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
}

extension CountryListCollectionViewController: UICollectionViewDataSource {
    public func numberOfSections(in _: UICollectionView) -> Int {
        return countryHeaderTexts.count
    }
    
    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = countryHeaderTexts[section]
        return self.countries[key]?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: HeaderView?
        
        let section = indexPath.section
        header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerReuseIdentifier, for: indexPath) as? HeaderView
        
        header?.title = countryHeaderTexts[section]
        
        header?.backgroundColor = configuration.backgroundColor
        header?.configuration = configuration
        
        return header ?? UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CountryListCollectionViewCell
            else { fatalError("Wrong cell type for CountryListCollectionViewController. Should be CountryListCollectionViewCell") }
        
        let section = indexPath.section
        let key = countryHeaderTexts[section]
        if let countries = self.countries[key] {
            cell.countryName = countries[indexPath.row]
        }
        cell.configuration = configuration
        return cell
    }
}

extension CountryListCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 2 * self.cellInset, height: self.cellHeight)
    }
    
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return self.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = section == HeaderType.CurrentLocation.rawValue ? currentLocationHeaderHeight : headerHeight
        return CGSize(width: collectionView.frame.width, height: height)
    }
}

extension CountryListCollectionViewController: UICollectionViewDelegate {
    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        
        let key = countryHeaderTexts[section]
        guard let countries = self.countries[key] else {
            print("No countries for specified key(alphabet)")
            return
        }
        
        let name = countries[indexPath.row]
        delegate?.didSelectCountry(name: name)
        self.navigationController?.popViewController(animated: true)
    }
}


extension CountryListCollectionViewController: SearchViewDelegate {
    func didCancelSearch() {
        self.isSearching = false
        self.searchView.clear()
        self.countries = self.allCountries
        self.countryHeaderTexts = self.allCountryHeaders
        self.reload()
    }
}
