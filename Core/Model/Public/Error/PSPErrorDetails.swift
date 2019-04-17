//
//  PSPError.swift
//  MobilabPaymentCore
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct PSPErrorDetails: TitleProviding, CustomStringConvertible {
    public let description: String
    public let title: String = "PSP Error"
}
