//
//  NetworkLogger.swift
//  
//
//  Created by Erick Del Orbe on 5/24/20.
//

import Foundation

public class NetworkLogger: FileLogger {
    
    //MARK: - Properties
    
    //MARK: - Initializers
    override init() {
        super.init()
        logFileName = "network.log"
        queueName = "com.bugless.networkLogging"
    }
    
    override func getPrefix() -> String {
        return ""
    }
    
}

//MARK: - NetworkTapDelegate
extension NetworkLogger: NetworkTapDelegate {
    
    func didReceiveRequest(_ requestModel: NetworkRequest) {
        
        if let serializedRequestData = try? JSONEncoder().encode(requestModel), let serializedRequest = String(data: serializedRequestData, encoding: .utf8) {
            writeToLog(serializedRequest)
        }
    }
    
}

