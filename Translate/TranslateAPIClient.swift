//
//  TranslateAPIClient.swift
//  Translate
//
//  Created by Alexey Papin on 31.01.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import Foundation
import Alamofire

let debugLogging = true

enum TranslateEndpoint: Endpoint {
    case translate(text: String, from: String?, to: String)
    case languages
    
    var baseURL: URL {
        return URL(string: "http://transltr.org")!
    }
    
    var path: String {
        switch self {
        case .translate(let text, let from, let to):
            var path = "/api/translate?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&to=\(to)"
            if let from = from {
                path += "&from=\(from)"
            }
            return path
        case .languages:
            return "/api/getlanguagesfortranslate"
        }
    }
    
    var request: URLRequest {
        let url = URL(string: self.path, relativeTo: self.baseURL)!
        return URLRequest(url: url)
    }
}

class TranslateAPIClient: NSObject, APIClient {
    let configuration: URLSessionConfiguration
    let delegate: URLSessionDelegate?
    let delegateQueue: OperationQueue?
    
    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate? = nil, delegateQueue: OperationQueue? = nil) {
        self.configuration = configuration
        self.delegate = delegate
        self.delegateQueue = delegateQueue
        super.init()
    }
    
    convenience override init() {
        self.init(configuration: .default)
    }
    
    lazy var session: URLSession = {
        let session = URLSession(configuration: self.configuration, delegate: self.delegate, delegateQueue: self.delegateQueue)
        return session
    }()

    func fetch<T: JSONDecodable>(endpoint: Endpoint, completion: @escaping (APIResult<T>) -> Void) {
        if (debugLogging) {
            print(endpoint.request)
        }
        self.fetch(request: endpoint.request, parse: T.parse, completion: completion)
    }
    
    func fetchArray<T: JSONDecodable>(endpoint: Endpoint, completion: @escaping (APIResultArray<T>) -> Void) {
        if (debugLogging) {
            print(endpoint.request)
        }
        self.fetchArray(request: endpoint.request, parse: T.parseArray, completion: completion)
    }
}
