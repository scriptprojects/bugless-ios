//
//  NetworkRequest.swift
//  
//
//  Created by Erick Del Orbe on 5/24/20.
//

import Foundation

class NetworkRequest: Encodable {
    
    var request: URLRequest?
    var response: HTTPURLResponse?
    var responseString: String?
    var startedAt: Date?
    var endedAt: Date?
}
