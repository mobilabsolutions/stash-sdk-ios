//
//  CountryListCollectionViewController.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 02.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol CountryListCollectionViewControllerDelegate: class {
    func didSelectCountry(country: Country)
}

class CountryListCollectionViewController: UIViewController {
    // MARK: - Properties

    weak var delegate: CountryListCollectionViewControllerDelegate?

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

    private typealias GroupedCountries = [String: [Country]]

    private let resourceFileName = "Countries"
    private let resourceFileExtension = "plist"

    private let reuseIdentifier = "countryCell"
    private let titleHeaderReuseIdentifier = "titleHeader"
    private let headerReuseIdentifier = "headerId"

    private var currentLocation: Country = Country(name: "Germany", alpha2Code: "DE")

    private let configuration: PaymentMethodUIConfiguration

    private let cellHeight: CGFloat = 48
    private let minimumLineSpacing: CGFloat = 1
    private let cellInset: CGFloat = 0
    private let titleHeaderHeight: CGFloat = 60
    private let currentLocationHeaderHeight: CGFloat = 38
    private let headerHeight: CGFloat = 30
    private let searchBarHeight: CGFloat = 57

    private var currentLocationHeaderTitle: String = HeaderType.currentLocation.title
    private var headerTitles: [String] = []
    private var allHeaderTitles = [String]()

    private var groupedCountries: GroupedCountries = GroupedCountries()
    private var allGroupedCountries: GroupedCountries = GroupedCountries()

    private var currentCountryName: String?

    private var isSearching: Bool = false

    private lazy var timer: Timer? = nil

    private let headerView: TitleHeaderView = {
        let view = TitleHeaderView()
        view.title = "Select Your Country"
        view.accessibilityIdentifier = "HeaderView"

        return view
    }()

    private let searchView = SearchView(frame: .zero)

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()

    // MARK: - Initializers

    init(country: Country?, configuration: PaymentMethodUIConfiguration) {
        self.currentCountryName = country?.name
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.accessibilityIdentifier = "CountrySelectionView"

        view.backgroundColor = self.configuration.backgroundColor

        view.addSubview(self.headerView)
        self.headerView.configuration = self.configuration

        self.headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               leading: view.safeAreaLayoutGuide.leadingAnchor,
                               trailing: view.safeAreaLayoutGuide.trailingAnchor,
                               height: self.titleHeaderHeight)

        view.addSubview(self.searchView)
        self.searchView.anchor(top: self.headerView.bottomAnchor,
                               leading: view.safeAreaLayoutGuide.leadingAnchor,
                               trailing: view.safeAreaLayoutGuide.trailingAnchor,
                               height: self.searchBarHeight)

        view.addSubview(self.collectionView)
        self.collectionView.anchor(top: self.searchView.bottomAnchor,
                                   leading: view.safeAreaLayoutGuide.leadingAnchor,
                                   bottom: view.bottomAnchor,
                                   trailing: view.safeAreaLayoutGuide.trailingAnchor)

        self.searchView.setup(text: nil,
                              borderColor: .clear,
                              placeholder: "Search Country",
                              textFieldFocusGainCallback: nil,
                              textFieldUpdateCallback: { [weak self] textField in

                                  guard let self = self else { return }
                                  let keyword = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
                                  self.handleSearch(with: keyword)

        }, configuration: self.configuration)

        self.groupedCountries = [HeaderType.currentLocation.title: [self.currentLocation]]
        self.searchView.delegate = self

        self.setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.headerTitles.count == 0 {
            self.readCountries()
            if let name = self.currentCountryName {
                let country = self.getCountry(from: name)
                if let country = country {
                    self.currentLocation = country
                }
            }
            self.reload()
        }
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

    // MARK: - Helpers

    override func removeFromParent() {
        super.removeFromParent()

        self.stopTimer()
    }

    private func readCountries() {
        DispatchQueue.global(qos: .background).sync {
            let countries = Locale.current.getAllCountriesWithCodes()
            (self.groupedCountries, self.headerTitles) = self.groupByFirstLetter(countries: countries)
            // keep a backup (used during search)
            self.allGroupedCountries = self.groupedCountries
            self.allHeaderTitles = self.headerTitles
        }
    }

    private func groupByFirstLetter(countries: [Country]) -> (GroupedCountries, [String]) {
        var groupedCountries: GroupedCountries = [:]
        var headerTitles: [String] = []
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        var singleGroup: [Country] = []
        for alphabet in alphabets {
            singleGroup = countries.filter { (country) -> Bool in
                country.name.first == alphabet
            }
            groupedCountries[String(alphabet)] = singleGroup
            headerTitles.append(String(alphabet))
        }
        return (groupedCountries, headerTitles)
    }

    private func getCountry(from countryName: String) -> Country? {
        guard let firstAlphabet = countryName.first else {
            print("Error: Could not retrieve first letter from country - \(countryName)")
            return nil
        }

        if let countriesStartingWithAlphabet = self.groupedCountries[String(firstAlphabet)] {
            let country = countriesStartingWithAlphabet.filter {
                $0.name.caseInsensitiveCompare(countryName) == .orderedSame
            }
            if country.count > 0 {
                return country[0]
            }
        }
        return nil
    }

    private func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    private func handleSearch(with keyword: String) {
        self.stopTimer()

        self.groupedCountries = self.allGroupedCountries
        self.headerTitles = self.allHeaderTitles

        if keyword.count == 0 {
            self.reload()
            return
        }

        self.isSearching = true
        let countries = self.groupedCountries

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
                let result = countries.filter { (country) -> Bool in
                    country.name.localizedCaseInsensitiveContains(keyword)
                }
                if result.count > 0 {
                    newGrouping[startingLetterKey] = result
                }
            }
            self.groupedCountries = newGrouping
            self.headerTitles = self.groupedCountries.keys.sorted()
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
    }
}

extension CountryListCollectionViewController: UICollectionViewDataSource {
    public func numberOfSections(in _: UICollectionView) -> Int {
        return self.isSearching == true ? self.headerTitles.count : 1 + self.headerTitles.count
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isSearching == true {
            let withAlphabet = self.headerTitles[section]
            return self.groupedCountries[withAlphabet]?.count ?? 0

        } else {
            if section == HeaderType.currentLocation.index {
                return 1
            }
            let withAlphabet = self.headerTitles[section - 1]
            return self.groupedCountries[withAlphabet]?.count ?? 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: HeaderView?

        let section = indexPath.section
        header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerReuseIdentifier, for: indexPath) as? HeaderView

        if self.isSearching {
            header?.title = self.headerTitles[section]
        } else {
            header?.title = (section == HeaderType.currentLocation.index ? self.currentLocationHeaderTitle : self.headerTitles[section - 1])
        }
        header?.configuration = self.configuration

        return header ?? UICollectionReusableView()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CountryListCollectionViewCell
        else { fatalError("Wrong cell type for CountryListCollectionViewController. Should be CountryListCollectionViewCell") }

        let section = indexPath.section

        if self.isSearching {
            let withAlphabet = self.headerTitles[section]
            if let countries = self.groupedCountries[withAlphabet] {
                cell.countryName = countries[indexPath.row].name
            }
        } else {
            if section == HeaderType.currentLocation.index {
                cell.countryName = self.currentLocation.name
            } else {
                let withAlphabet = self.headerTitles[section - 1]
                if let countries = self.groupedCountries[withAlphabet] {
                    cell.countryName = countries[indexPath.row].name
                }
            }
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

        var selectedCountry: Country
        if self.isSearching {
            let withAlphabet = self.headerTitles[section]
            guard let countries = self.groupedCountries[withAlphabet] else {
                print("No countries for specified key(alphabet)")
                return
            }
            selectedCountry = countries[indexPath.row]
        } else {
            if section == HeaderType.currentLocation.index {
                selectedCountry = self.currentLocation
            } else {
                let withAlphabet = self.headerTitles[section - 1]
                guard let countries = self.groupedCountries[withAlphabet] else {
                    print("No countries for specified key(alphabet)")
                    return
                }
                selectedCountry = countries[indexPath.row]
            }
        }
        self.delegate?.didSelectCountry(country: selectedCountry)
        self.navigationController?.popViewController(animated: true)
    }
}

extension CountryListCollectionViewController: SearchViewDelegate {
    func didCancelSearch() {
        self.stopTimer()
        self.isSearching = false
        self.groupedCountries = self.allGroupedCountries
        self.headerTitles = self.allHeaderTitles
        self.searchView.clear()
        self.reload()
    }
}
