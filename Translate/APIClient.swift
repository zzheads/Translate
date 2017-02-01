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

enum APIArrayResult<T> {
    case Success([T])
    case Failure(Error)
}

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var request: URLRequest { get }
    var url: URL { get }
}

protocol APIClient {
    var configuration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    func JSONTaskWithRequest<J>(request: URLRequest, completion: @escaping TaskCompletion<J>) -> JSONTask
    func fetch<T: JSONDecodable>(request: URLRequest, completion: @escaping (APIResult<T>) -> Void)
    func fetchArray<T: JSONDecodable>(request: URLRequest, completion: @escaping (APIArrayResult<T>) -> Void) 
}

extension APIClient {
    
    func taskCompletion<J>(with completion: @escaping TaskCompletion<J>) -> URLSessionDataTaskCompletion {
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
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? J
                    print("serialization to: \(J.self)")
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
        
    func JSONTaskWithRequest<J>(request: URLRequest, completion: @escaping TaskCompletion<J>) -> JSONTask {
        let task = session.dataTask(with: request, completionHandler: taskCompletion(with: completion))
        return task
    }
    
    func fetch<T: JSONDecodable>(request: URLRequest, completion: @escaping (APIResult<T>) -> Void) {
        let task = JSONTaskWithRequest(request: request) { (json: JSON?, response: HTTPURLResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.Failure(error))
                    } else {
                        completion(.Failure(APIError.unexpectedResponseError.error))
                    }
                    return
                }
                if let value = T(with: json) {
                    completion(.Success(value))
                } else {
                    completion(.Failure(APIError.serializationError.error))
                }
            }
        }
        task.resume()
    }
    
    func fetchArray<T: JSONDecodable>(request: URLRequest, completion: @escaping (APIArrayResult<T>) -> Void) {
        let task = JSONTaskWithRequest(request: request) { (json: JSONArray?, response: HTTPURLResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.Failure(error))
                    } else {
                        completion(.Failure(APIError.unexpectedResponseError.error))
                    }
                    return
                }
                if let value = [T](with: json) {
                    completion(.Success(value))
                } else {
                    completion(.Failure(APIError.serializationError.error))
                }
            }
        }
        task.resume()
    }
}
