//
//  APIClient.swift
//  APIClient
//
//  Created by Alexey Papin on 30.01.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import Foundation

enum APIResult<T> {
    case Success(T)
    case Failure(Error)
}

enum APIResultArray<T> {
    case Success([T])
    case Failure([T], [Error])
}

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var request: URLRequest { get }
}

protocol APIClient {
    var configuration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask
    func fetch<T: JSONDecodable>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void)
}

let errorNameInJSON = "error"

public let ZZHNetworkingErrorDomain = "com.zzheads.App.NetworkingError"
public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20

extension APIClient {
    
    func taskCompletion(with completion: @escaping JSONTaskCompletion) -> URLSessionDataTaskCompletion {
        return { (data: Data?, response: URLResponse?, error: Error?) in
            guard let response = response as? HTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")]
                let error = NSError(domain: ZZHNetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, response, error)
                return
            }
            
            switch response.statusCode {
            case 200:
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON
                    completion(json, response, nil)
                    return
                } catch let serialError {
                    completion(nil, response, serialError)
                    return
                }
                
            default:
                guard let httpError = HTTPStatusCode(rawValue: response.statusCode) else {
                    let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Unknown HTTP code", comment: "")]
                    let error = NSError(domain: ZZHNetworkingErrorDomain, code: response.statusCode, userInfo: userInfo)
                    completion(nil, response, error)
                    return
                }
                
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString(httpError.message, comment: "")]
                let error = NSError(domain: ZZHNetworkingErrorDomain, code: httpError.rawValue, userInfo: userInfo)
                completion(nil, response, error)
                return
            }
        }
    }
    
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask {
        let task = session.dataTask(with: request, completionHandler: taskCompletion(with: completion))
        return task
    }
}
