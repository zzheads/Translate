//
//  AlamoAPIClient.swift
//  Translate
//
//  Created by Alexey Papin on 01.02.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import Foundation
import Alamofire

class AlamoAPIClient {
    
    func fetch<T: JSONDecodable>(endpoint: Endpoint, completion: @escaping (T?) -> Void) {
        Alamofire.request(endpoint.url, method: .get, parameters: nil)
            .validate()
            .responseJSON { (response) -> Void in
                
                guard response.result.isSuccess else {
                    print("Error while fetching: \(response.result.error)")
                    completion(nil)
                    return
                }
                
                guard
                    let json = response.result.value as? JSON,
                    let value = T(with: json)
                    else {
                        print("Error while fetching: \(response.result.error)")
                        completion(nil)
                        return
                }
                
                completion(value)
        }
    }
}
