//
//  Configuration.swift
//  
//
//  Created By ScriptProjects, LLC on 4/19/20.
//

import Foundation

public class Configuration {
    
    public init(
        trigger newTrigger: TriggerType = .none,
        sendMethods methods: [Integration] = [.nativeEmailClient],
        webhookUrl hookUrl: String = "",
        imageServiceCredentials imageCredentials: [String: String] = [:],
        skipFeedbackForm skipForm: Bool = false) {
        
        trigger = newTrigger
        sendMethods = methods
        webhookUrl = hookUrl
        imageServiceCredentials = imageCredentials
        skipFeedbackForm = skipForm
        
    }
    
    public enum TriggerType {
        case shake
        case screenshot
        case none
    }
    
    public enum Integration {
        case nativeEmailClient
        case webhook
    }
    
    public enum ImageStorageProvider {
        case imgur
    }
    
    public var skipFeedbackForm: Bool = false
    
    public var trigger: TriggerType = .none
    
    public var sendMethods: [Integration] = [.nativeEmailClient]
    
    public var emailRecipients: [String] = []
    
    public var webhookUrl: String = ""
    
    public var credentials: BLCredentials = BLCredentials()
    
    public var imageService: ImageStorageProvider = .imgur
    
    //Credential dictionary with headers that need to be set for each request
    public var imageServiceCredentials: [String: String] = [:]
    
}

public struct BLCredentials {
    
    public var identifier: String = ""
    public var secret: String = ""
    
    public init(){}
    
}
