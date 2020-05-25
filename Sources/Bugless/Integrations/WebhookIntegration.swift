//
//  WebhookIntegration.swift
//  
//
//  Created By ScriptProjects, LLC on 4/14/20.
//

import Foundation

class WebhookIntegration: IssueIntegration {
    
    var webhookUrl: String = Bugless.configuration.webhookUrl
    
    func send(issue: Issue) {
        //Make sure webhook is correctly configured
        guard webhookUrl != "" else { print("Bugless Error: You must configure a webhook URL"); return }
        
        //Signal the beginning of submittion so loader can be shown
        NotificationCenter.default.post(name: .buglessIssueSubmittionStarted, object: nil)
        
        if issue.screenshots.count > 0 {
            //TODO: Support multiple screenshots
            NetworkHelper.imgurUpload(image: issue.screenshots[0], withCredentials: Bugless.configuration.imageServiceCredentials) { (imageLink) in
                self.send(issue: issue, with: imageLink)
            }
        } else {
            send(issue: issue, with: nil)
        }
    }
    
    static func doesRequireCredentials() -> Bool {
        return false
    }
    
    func send(issue: Issue, with imageLink: String?) {
        let issueToSend = SerializableIssue(issue, imageLinks: imageLink == nil ? [] : [imageLink!])
        let payload = issueToSend.toJson()
        NetworkHelper.postJson(self.webhookUrl, jsonString: payload) { (data, response, error) in
            if error == nil {
                //Dismiss feedback controller
                NotificationCenter.default.post(name: .buglessIssueSubmittionSuccesful, object: nil)
            } else {
                NotificationCenter.default.post(name: .buglessIssueSubmitionFailed, object: nil, userInfo: ["error": error!])
            }
        }
    }
}
