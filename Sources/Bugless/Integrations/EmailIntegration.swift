//
//  EmailIntegration.swift
//  
//
//  Created By ScriptProjects, LLC on 4/14/20.
//

import MessageUI

class EmailIntegration: NSObject, IssueIntegration, MFMailComposeViewControllerDelegate {
    
    var currentIssue: Issue!
    var currentContext: UIViewController!
    
    func send(issue: Issue) {
        currentIssue = issue
        sendEmail()
    }
    
    func sendEmail(_ context: UIViewController? = Bugless.topMostViewController()) {
        currentContext = context
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject((currentIssue.systemInfo["appName"] ?? "Bugless feedback") + ": You've received a user feedback")
            mailComposer.setMessageBody(composeEmailBody(currentIssue), isHTML: false)
            mailComposer.setToRecipients(Bugless.configuration.emailRecipients)
            
            for screenshot in currentIssue.screenshots {
                if let attachment = screenshot.pngData() {
                    mailComposer.addAttachmentData(attachment, mimeType: "image/png", fileName: "screenshot.png")
                }
            }
            
            NotificationCenter.default.post(name: .buglessIssueSubmittionStarted, object: nil)
            if let topController = context {
                topController.present(mailComposer, animated: true)
            }
            
        } else {
            if let context = context {
                //Alert the user that they're unable to send mail
                AlertHelper.info(title: "Error", message: "Unable to send email. Do you have an email account configured on your phone?", context: context)
            }
        }
    }
    
    static func doesRequireCredentials() -> Bool {
        return false
    }
    
    func composeEmailBody(_ issue: Issue) -> String {
        
        var result = issue.message + "\n\nSystem Information:\n\n"
        
        for line in issue.systemInfo {
            result += line.key + ": " + line.value + "\n"
        }
        
        return result
        
    }
     
     func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("User cancelled")
            break
        case .saved:
            print("Mail saved to send later")
            break
        case .sent:
            print("Mail sent successfully")
            break
        case .failed:
            print("Failed to send email")
            break
        default:
            break
        }
        
        currentContext?.dismiss(animated: true) {
            if result == .failed {
                //Alert to failed email
                let alert = UIAlertController(title: "Error", message: "Email sending failed", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let retry = UIAlertAction(title: "Retry", style: .default) { _ in self.send(issue: self.currentIssue) }
                alert.addAction(retry)
                alert.addAction(cancel)
                if let topController = Bugless.topMostViewController() {
                    topController.present(alert, animated: true)
                }
                
                NotificationCenter.default.post(name: .buglessIssueSubmitionFailed, object: nil, userInfo: ["alert": false]) 
            } else {
                NotificationCenter.default.post(name: .buglessIssueSubmittionSuccesful, object: nil)
            }
        }
    }
    
}
