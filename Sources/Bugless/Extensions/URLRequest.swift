//
//  URLRequest.swift
//  
//
//  Created by Erick Del Orbe on 5/24/20.
//

import Foundation

extension URLRequest: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case httpMethod
        case url
        case httpBody
        case allHTTPHeaderFields = "headers"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(httpMethod, forKey: .httpMethod)
        try container.encode(url?.absoluteString ?? "", forKey: .url)
        try container.encode(httpBody, forKey: .httpBody)
        try container.encode(allHTTPHeaderFields ?? [:], forKey: .allHTTPHeaderFields)
        
    }
}
