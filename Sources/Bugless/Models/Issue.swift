//
//  Issue.swift
//  
//
//  Created By ScriptProjects, LLC on 3/31/20.
//

import UIKit

class Issue {
    
    var username: String = ""
    var title: String = ""
    var message: String = ""
    var screenshots: [UIImage] = []
    var systemInfo: [String: String] = [:]
    var type: IssueType = .none
    //TODO: var networkLogs: [NetworkLog]
    
    init() {
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(username, forKey: .username)
        try container.encode(title, forKey: .title)
        try container.encode(message, forKey: .message)
        try container.encode(systemInfo, forKey: .systemInfo)
        try container.encode(type, forKey: .type)
        
        var imageData: [Data] = []
        for screenshot in screenshots {
            imageData.append(screenshot.jpegData(compressionQuality: 0.5)!)
        }
        if imageData.count > 0 {
            try container.encode(imageData, forKey: .screenshots)
        }
    }
    
    static func collectSystemInfo() -> [String: String] {
        
        var logs: [String: String] = [:]
        let device = UIDevice.current
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
        let appVersion = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
        let appIdentifier = Bundle.main.infoDictionary![kCFBundleIdentifierKey as String] as! String
        
        logs["appName"]       =  appName ?? ""
        logs["appVersion"]    =  appVersion
        logs["appIdentifier"] =  appIdentifier
        logs["deviceName"]    =  device.name
        logs["systemName"]    =  device.systemName
        logs["systemVersion"] =  device.systemVersion
        logs["model"]         =  device.localizedModel
        logs["batteryLevel"]  =  "\(device.batteryLevel)"
        
        return logs
        
    }
    
    static func issueWith(screenshot: UIImage?) -> Issue {
        let issue = Issue()
        issue.systemInfo = collectSystemInfo()
        if let screenshot = screenshot {
            issue.screenshots = [screenshot]
        }
        return issue
    }
}

extension Issue: Encodable {
    
    enum Keys: String, CodingKey {
        case username
        case title
        case message
        case screenshots
        case systemInfo
        case type
    }
    
}

enum IssueType: Int {
    case bug
    case suggestion
    case question
    case none
}

extension IssueType: Codable {
    
    enum Key: CodingKey {
        case rawValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        
        if let val = IssueType(rawValue: rawValue) {
            self = val
        } else {
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.rawValue, forKey: .rawValue)
    }
    
}

class SerializableIssue: Issue {
    
    var imageLinks: [String]
    
    public init(_ issue: Issue, imageLinks newImages: [String]) {
        imageLinks = newImages
        super.init()
        username = issue.username
        title = issue.title
        message = issue.message
        systemInfo = issue.systemInfo
        type = issue.type
        screenshots = []
    }
    
    func toJson() -> String {
        if let result = try? JSONEncoder().encode(self), let final = String(data: result, encoding: .utf8) {
            return final
        } else {
            return "{}"
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(username, forKey: .username)
        try container.encode(title, forKey: .title)
        try container.encode(message, forKey: .message)
        try container.encode(systemInfo, forKey: .systemInfo)
        try container.encode(type, forKey: .type)
        try container.encode(imageLinks, forKey: .screenshots)
    }
    
}
