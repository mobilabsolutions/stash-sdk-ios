//
//  User.swift
//  Demo
//
//  Created by Rupali Ghate on 03.06.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct User {
    private let userIdKey = "userId"

    var userId: String {
        return UserDefaults.standard.string(forKey: self.userIdKey) ?? ""
    }

    func save(userId: String) {
        UserDefaults.standard.set(userId, forKey: self.userIdKey)
    }

    func getUserId() -> String {
        return UserDefaults.standard.string(forKey: self.userIdKey) ?? ""
    }
}
