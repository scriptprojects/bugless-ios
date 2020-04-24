//
//  IssueIntegration.swift
//  
//
//  Created By ScriptProjects, LLC on 4/14/20.
//

protocol IssueIntegration {
    
    func send(issue: Issue)
    static func doesRequireCredentials() -> Bool
    
}
