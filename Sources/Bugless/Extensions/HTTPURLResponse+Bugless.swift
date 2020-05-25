//
//  HTTPURLResponse+Bugless.swift
//  
//
//  Created by Erick Del Orbe on 5/24/20.
//

import Foundation

extension HTTPURLResponse: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case allHeaderFields = "headers"
        case mimeType
        case textEncodingName = "encoding"
        case expectedContentLength = "contentLength"
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode, forKey: .statusCode)
        if let headers = allHeaderFields as? [String: String] {
            try container.encode(headers, forKey: CodingKeys.allHeaderFields)
        }
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(textEncodingName, forKey: .textEncodingName)
        try container.encode(expectedContentLength, forKey: .expectedContentLength)
        
    }
}
