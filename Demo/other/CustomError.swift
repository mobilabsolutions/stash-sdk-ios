//
//  CustomError.swift
//  Demo
//
//  Created by Rupali Ghate on 03.06.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct CustomError: LocalizedError {
    let localizedDescription: String

    init(description: String) {
        self.localizedDescription = description
    }
}
