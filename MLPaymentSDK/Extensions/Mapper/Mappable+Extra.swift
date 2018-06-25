//
//  Mappable+Extra.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

extension Mappable {
    
    /// Parse given json object. You can specify key where to parse from.
    static func parse(_ json: Any?, key: String?=nil) -> Self? {
        return parseGeneric(json, key: key)
    }
    
    /// Parse given json array. You can specify key where to parse from. Keys can be nested with '.'
    static func parseArray(_ json: Any?, key: String?=nil) -> [Self] {
        guard let json = json else { return [] }
        return parseArrayGeneric(json, key: key)
    }
}

// MARK: - Private
private extension Mappable {
    static func parseGeneric<T: Mappable>(_ json: Any?, key: String?=nil) -> T? {
        guard let json = json as? MLURLSessionManager.JSON else { return nil }
        
        var mappedObj: T?
        if let key = key, let nestedJson = json[key] as? MLURLSessionManager.JSON {
            mappedObj = Mapper<T>().map(JSON: nestedJson)
        } else {
            mappedObj = Mapper<T>().map(JSON: json)
        }
        return mappedObj
    }
    
    static func parseArrayGeneric<T: Mappable>(_ json: Any, key: String?=nil) -> [T] {
        let parseDirectlyHandler: (_ json: Any) -> [T] = { json -> [T] in
            return Mapper<T>().mapArray(JSONObject: json) ?? []
        }
        if let key = key, let jsonArray = json as? MLURLSessionManager.JSON {
            var currentNestedJson: [ String: Any ] = jsonArray
            let keys = key.components(separatedBy: ".")
            for nestedKey in keys.dropLast() {
                guard let nestedJson = currentNestedJson[nestedKey] as? MLURLSessionManager.JSON else { return parseDirectlyHandler(json) }
                currentNestedJson = nestedJson
            }
            let lastKey = keys.last ?? key
            let subArray = (currentNestedJson[lastKey] as? [Any])
            return parseDirectlyHandler(subArray ?? json)
        } else {
            return parseDirectlyHandler(json)
        }
    }
}
