//
//  FormCellModel.swift
//  MobilabPaymentCore
//
//  Created by Robert on 01.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public struct FormCellModel {
    public let type: FormCellType

    var necessaryData: [NecessaryData] {
        switch self.type {
        case let .text(data): return [data.necessaryData]
        case .dateCVV: return [.expirationMonth, .expirationYear, .cvv]
        }
    }

    public init(type: FormCellType) {
        self.type = type
    }

    public enum FormCellType {
        case text(TextData)
        case dateCVV

        public struct TextData {
            public let necessaryData: NecessaryData
            public let title: String
            public let placeholder: String
            public let setup: ((NecessaryData, UITextField) -> Void)?
            public let didUpdate: ((NecessaryData, UITextField) -> Void)?

            public init(necessaryData: NecessaryData,
                        title: String,
                        placeholder: String,
                        setup: ((NecessaryData, UITextField) -> Void)?,
                        didUpdate: ((NecessaryData, UITextField) -> Void)?) {
                self.didUpdate = didUpdate
                self.setup = setup
                self.title = title
                self.necessaryData = necessaryData
                self.placeholder = placeholder
            }
        }
    }
}
