//
//  CountryListCollectionViewController.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 02.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol CountryListCollectionViewControllerDelegate: class {
    func didSelectCountry(name: String)
}

class CountryListCollectionViewController: UIViewController {
    // MARK: - Properties

    weak var delegate: CountryListCollectionViewControllerDelegate?
    var currentLocation: String?

    private enum HeaderType: Int {
        case currentLocation = 0
        case allCountries

        var index: Int {
            return self.rawValue
        }

        var title: String {
            switch self {
            case .currentLocation: return "Current Location"
            default: return ""
            }
        }
    }

    private typealias GroupedCountries = [String: [String]]

    private let resourceFileName = "Countries"
    private let resourceFileExtension = "plist"

    private let reuseIdentifier = "countryCell"
    private let titleHeaderReuseIdentifier = "titleHeader"
    private let headerReuseIdentifier = "headerId"

    private let defaultCurrentLocation: String = "Germany"

    private let configuration: PaymentMethodUIConfiguration

    private let cellHeight: CGFloat = 48
    private let minimumLineSpacing: CGFloat = 1
    private let cellInset: CGFloat = 0
    private let titleHeaderHeight: CGFloat = 60
    private let currentLocationHeaderHeight: CGFloat = 38
    private let headerHeight: CGFloat = 30
    private let searchBarHeight: CGFloat = 57

    private var countries: GroupedCountries = GroupedCountries()
    private var allCountries: GroupedCountries = GroupedCountries()
    private var countryHeaders: [String] = [HeaderType.currentLocation.title]
    private var allCountryHeaders = [String]()

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

    // MARK: - Initializers

    init(currentLocation: String, configuration: PaymentMethodUIConfiguration) {
        self.currentLocation = !currentLocation.isEmpty ? currentLocation : self.defaultCurrentLocation
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = self.configuration.backgroundColor

        view.addSubview(self.headerView)
        self.headerView.configuration = self.configuration

        self.headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                               right: view.safeAreaLayoutGuide.rightAnchor,
                               height: self.titleHeaderHeight)

        view.addSubview(self.searchView)
        self.searchView.anchor(top: self.headerView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                               right: view.safeAreaLayoutGuide.rightAnchor,
                               height: self.searchBarHeight)

        view.addSubview(self.collectionView)
        self.collectionView.anchor(top: self.searchView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                                   bottom: view.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)

        self.searchView.setup(text: nil,
                              borderColor: .clear,
                              placeholder: "Search Country",
                              textFieldFocusGainCallback: nil,
                              textFieldUpdateCallback: { [weak self] textField in

                                  guard let self = self else { return }
                                  let keyword = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
                                  self.handleSearch(with: keyword)

        }, configuration: self.configuration)

        self.countries = [HeaderType.currentLocation.title: [self.currentLocation!]]
        self.searchView.delegate = self

        self.setupCollectionView()
    }

    private func setupCollectionView() {
        self.collectionView.register(CountryListCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        self.collectionView.register(TitleHeaderView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.titleHeaderReuseIdentifier)
        self.collectionView.register(HeaderView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerReuseIdentifier)

        self.collectionView.backgroundColor = self.configuration.backgroundColor

        // sticky header
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.countries.keys.count == 1 {
            self.readCountries()
        }
    }

    // MARK: - Helpers

    override func removeFromParent() {
        super.removeFromParent()

        self.stopTimer()
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

                guard let countriesDictionary = list else { return }
                let keys = Array(countriesDictionary.keys.sorted())

                for key in keys {
                    if let countriesStartingWithAlphabet = countriesDictionary[key] {
                        self.countries[key] = countriesStartingWithAlphabet
                    }
                }
                self.countryHeaders.append(contentsOf: keys)

                self.allCountries = self.countries
                self.allCountryHeaders = self.countryHeaders // keep a backup
                self.reload()

            } catch let err {
                print("Error while reading countries from file: \(err.localizedDescription)")
            }
        }
    }

    private func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    private func handleSearch(with keyword: String) {
        self.stopTimer()

        countries = self.allCountries
        self.countryHeaders = self.allCountryHeaders

        if keyword.count == 0 {
            self.reload()
            return
        }

        self.isSearching = true
        let countries = self.countries

        // add some delay to fetch. This is to avoid fetch call for every character change in searchbar
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }

            self.filter(groupedCountries: countries, byString: keyword)
            self.reload()
        })
    }

    private func filter(groupedCountries: GroupedCountries, byString keyword: String) {
        DispatchQueue.global(qos: .background).sync {
            var newGrouping = GroupedCountries()

            for (startingLetterKey, countries) in groupedCountries {
                if startingLetterKey == HeaderType.currentLocation.title {
                    continue
                }
                let result = countries.filter { (countryName) -> Bool in
                    countryName.localizedCaseInsensitiveContains(keyword)
                }
                if result.count > 0 {
                    newGrouping[startingLetterKey] = result
                }
            }
            self.countries = newGrouping
            self.countryHeaders = self.countries.keys.sorted()
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
    }
}

extension CountryListCollectionViewController: UICollectionViewDataSource {
    public func numberOfSections(in _: UICollectionView) -> Int {
        return self.countryHeaders.count
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let withAlphabet = self.countryHeaders[section]
        return self.countries[withAlphabet]?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: HeaderView?

        let section = indexPath.section
        header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerReuseIdentifier, for: indexPath) as? HeaderView

        header?.title = self.countryHeaders[section]

        header?.configuration = self.configuration

        return header ?? UICollectionReusableView()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CountryListCollectionViewCell
        else { fatalError("Wrong cell type for CountryListCollectionViewController. Should be CountryListCollectionViewCell") }

        let section = indexPath.section
        let withAlphabet = self.countryHeaders[section]
        if let countries = self.countries[withAlphabet] {
            cell.countryName = countries[indexPath.row]
        }
        cell.configuration = self.configuration
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

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = section == HeaderType.currentLocation.rawValue ? self.currentLocationHeaderHeight : self.headerHeight
        return CGSize(width: collectionView.frame.width, height: height)
    }
}

extension CountryListCollectionViewController: UICollectionViewDelegate {
    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section

        let withAlphabet = self.countryHeaders[section]
        guard let countries = self.countries[withAlphabet] else {
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
        self.countryHeaders = self.allCountryHeaders
        self.reload()
    }
}
