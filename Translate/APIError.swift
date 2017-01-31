//
//  AppError.swift
//  Translate
//
//  Created by Alexey Papin on 31.01.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import Foundation

let ZZHeadsAPIErrorDomain = "com.zzheads.APIErrors"

enum APIError: Error {
    case missingHTTPResponseError
    case unexpectedResponseError
    case httpResponseStatusCodeError(HTTPStatusCode)
    
    var code: Int {
        switch self {
        case .missingHTTPResponseError: return 10
        case .unexpectedResponseError: return 20
        case .httpResponseStatusCodeError(let statusCode): return statusCode.rawValue
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .missingHTTPResponseError: return "Missing HTTP Response"
        case .unexpectedResponseError: return "Unexpected HTTP Response Error"
        case .httpResponseStatusCodeError(let statusCode): return "HTTP Response Error: \(statusCode.message)"
        }
    }
    
    var error: NSError {
        return NSError(domain: ZZHeadsAPIErrorDomain, code: self.code, userInfo: [NSLocalizedDescriptionKey: self.localizedDescription])
    }
}
