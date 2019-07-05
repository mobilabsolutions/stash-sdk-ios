//
//  AliasManager.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

class AliasManager {
    static let shared = AliasManager()
    private var cachedAliases: [Alias] = []
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private static let fileName = "alias_list.json"

    private init() {
        self.cachedAliases = self.readAliasesFromFile(name: AliasManager.fileName)
    }

    func save(alias: Alias) {
        self.cachedAliases.append(alias)
        self.saveFile(name: AliasManager.fileName)
    }

    var aliases: [Alias] {
        return self.cachedAliases
    }

    private func readAliasesFromFile(name: String) -> [Alias] {
        guard let url = getFileUrl(name: name)
        else { return [] }

        guard let data = FileManager.default.contents(atPath: url.path)
        else { return [] }

        guard let decoded = try? decoder.decode([Alias].self, from: data)
        else { return [] }

        return decoded
    }

    private func saveFile(name: String) {
        guard let url = getFileUrl(name: name)
        else { return }

        guard let encoded = try? encoder.encode(self.cachedAliases)
        else { return }

        _ = try? encoded.write(to: url)
    }

    private func getFileUrl(name: String) -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(name)
    }
}
