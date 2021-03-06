//
//  FormCellModel.swift
//  StashCore
//
//  Created by Robert on 01.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

public struct FormCellModel {
    public let type: FormCellType

    var necessaryData: [NecessaryData] {
        switch self.type {
        case let .text(data): return [data.necessaryData]
        case let .pairedText(data): return [data.firstNecessaryData, data.secondNecessaryData]
        case .dateCVV: return [.expirationMonth, .expirationYear, .cvv]
        case .country: return [.country]
        }
    }

    public init(type: FormCellType) {
        self.type = type
    }

    public enum FormCellType {
        case text(TextData)
        case pairedText(PairedTextData)
        case dateCVV
        case country

        public struct TextData {
            public let necessaryData: NecessaryData
            public let title: String
            public let placeholder: String
            public let setup: ((NecessaryData, UITextField) -> Void)?
            public let didFocus: ((UITextField) -> Void)?
            public let didUpdate: ((NecessaryData, UITextField) -> Void)?

            public init(necessaryData: NecessaryData,
                        title: String,
                        placeholder: String,
                        setup: ((NecessaryData, UITextField) -> Void)?,
                        didFocus: ((UITextField) -> Void)?,
                        didUpdate: ((NecessaryData, UITextField) -> Void)?) {
                self.didUpdate = didUpdate
                self.didFocus = didFocus
                self.setup = setup
                self.title = title
                self.necessaryData = necessaryData
                self.placeholder = placeholder
            }
        }

        public struct PairedTextData {
            public let firstNecessaryData: NecessaryData
            public let firstTitle: String
            public let firstPlaceholder: String
            public let secondNecessaryData: NecessaryData
            public let secondTitle: String
            public let secondPlaceholder: String
            public let setup: ((NecessaryData, UITextField) -> Void)?
            public let didUpdate: ((NecessaryData, UITextField) -> Void)?

            public init(firstNecessaryData: NecessaryData,
                        firstTitle: String,
                        firstPlaceholder: String,
                        secondNecessaryData: NecessaryData,
                        secondTitle: String,
                        secondPlaceholder: String,
                        setup: ((NecessaryData, UITextField) -> Void)?,
                        didUpdate: ((NecessaryData, UITextField) -> Void)?) {
                self.didUpdate = didUpdate
                self.setup = setup
                self.firstTitle = firstTitle
                self.firstPlaceholder = firstPlaceholder
                self.firstNecessaryData = firstNecessaryData
                self.secondTitle = secondTitle
                self.secondPlaceholder = secondPlaceholder
                self.secondNecessaryData = secondNecessaryData
            }
        }
    }
}
