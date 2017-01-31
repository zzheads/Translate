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

extension APIClient {
    
    func taskCompletion(with completion: @escaping JSONTaskCompletion) -> URLSessionDataTaskCompletion {
        return { (data: Data?, response: URLResponse?, error: Error?) in
            guard let response = response as? HTTPURLResponse else {
                completion(nil, nil, APIError.missingHTTPResponseError.error)
                return
            }
            
            guard let data = data else {
                completion(nil, response, error)
                return
            }
            
            let statusCode = HTTPStatusCode.getCode(response.statusCode)
            switch statusCode {
            case .ok:
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON
                    completion(json, response, nil)
                    return
                } catch let serialError {
                    completion(nil, response, serialError)
                    return
                }
                
            default:
                let errorCode = HTTPStatusCode.getCode(response.statusCode)
                completion(nil, response, APIError.httpResponseStatusCodeError(errorCode).error)
                return
            }
        }
    }
    
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask {
        let task = session.dataTask(with: request, completionHandler: taskCompletion(with: completion))
        return task
    }
}
