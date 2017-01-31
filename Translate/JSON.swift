//
//  JSON.swift
//  APIClient
//
//  Created by Alexey Papin on 30.01.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import Foundation

typealias JSON = [String: AnyObject]
typealias JSONArray = [JSON]
typealias JSONTaskCompletion = (JSON?, HTTPURLResponse?, Error?) -> Void
typealias JSONArrayTaskCompletion = (JSONArray?, HTTPURLResponse?, Error?) -> Void
typealias JSONTask = URLSessionDataTask
typealias URLSessionDataTaskCompletion = (Data?, URLResponse?, Error?) -> Void

protocol JSONDecodable: class {
    init?(with json: JSON)
}

typealias Parse<T> = ((JSON) -> T?) where T: JSONDecodable
typealias ParseArray<T> = ((JSONArray) -> [T]?) where T: JSONDecodable

extension JSONDecodable {
    static var parse: Parse<Self> {
        return { (json: JSON) in
            return Self.init(with: json)
        }
    }

    static var parseArray: ParseArray<Self> {
        return { (jsonArray: JSONArray) in
            return [Self].init(with: jsonArray)
        }
    }
}

extension Array where Element: JSONDecodable {
    init?(with jsonArray: JSONArray) {
        self.init()
        for json in jsonArray {
            if let value = Element.init(with: json) {
                self.append(value)
            } else {
                return nil
            }
        }
    }
}
