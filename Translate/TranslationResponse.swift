//
//  TranslationResponse.swift
//  Translate
//
//  Created by Alexey Papin on 31.01.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import Foundation

class TranslationResponse: NSObject, JSONDecodable {
    let from: String
    let to: String
    let text: String
    let translationText: String
    
    required init?(with json: JSON) {
        guard
            let to = json["to"] as? String,
            let text = json["text"] as? String,
            let translationText = json["translationText"] as? String,
            let from = json["from"] as? String
            else {
                return nil
        }
        self.from = from
        self.to = to
        self.text = text
        self.translationText = translationText
        super.init()
    }
}

extension TranslationResponse {
    override var description: String {
        return "\(TranslationResponse.self)<\(self.hash)>: {\n\t\"text\": \(text),\n\t\"translationText\": \(translationText),\n\t\"from\": \(from),\n\t\"to\": \(to)\n}"
    }
}
