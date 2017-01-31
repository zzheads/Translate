//
//  TranslationLanguage.swift
//  Translate
//
//  Created by Alexey Papin on 31.01.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import Foundation

class TranslationLanguage: NSObject, JSONDecodable {
    let code: String
    let name: String
    
    required init?(with json: JSON) {
        guard
            let code = json["languageCode"] as? String,
            let name = json["languageName"] as? String
            else {
                return nil
        }
        self.code = code
        self.name = name
        super.init()
    }
}

extension TranslationLanguage {
    override var description: String {
        return "\(TranslationLanguage.self)<\(self.hash)>: {\n\t\"code\": \(code),\n\t\"name\": \(name)\n}"
    }
}
