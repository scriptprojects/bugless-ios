//
//  FeedbackViewController.swift
//  
//
//  Created By ScriptProjects, LLC on 3/21/20.
//

import UIKit
import MessageUI

class FeedbackViewController: UIViewController {
    
    var placeholderLabel: UILabel!
    var messageView: UITextView!
    var logsRow: ToggleContentRow!
    var screenshotRow: ToggleContentRow!
    var issueType: IssueType = .none
    var screenshot: UIImage?
    var systemInfo: [String: String]!
    var appName: String?
    var usernameField: UITextField!
    var borderLayer: CALayer?
    static var shared: FeedbackViewController!
    
    convenience init(_ screenshot: UIImage?) {
        self.init()
        self.screenshot = screenshot
        FeedbackViewController.shared = self
    }
    
    static func dismiss() {
        shared.dismiss(animated: true)
    }
}

//MARK: - View controller overrides
extension FeedbackViewController {
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        mainViewSetup()
        systemInfo = collectLogs()
        
        //Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(issueSubmitionSucessful), name: .buglessIssueSubmittionSuccesful, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(issueSubmitionFailed(notification:)), name: .buglessIssueSubmitionFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(issueSubmittionStarted), name: .buglessIssueSubmittionStarted, object: nil)
        
    }
    
}

//MARK: - User interface setups
extension FeedbackViewController {
    
    func mainViewSetup() {
        
        //Nav bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didRequestClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(didRequestSend))
        
        //UI
        //Email field
        usernameField = UITextField()
        usernameField.placeholder = "Enter your username"
        usernameField.autocapitalizationType = .none
        
        if #available(iOS 11.0, *) {
            usernameField.textContentType = .emailAddress
            
            view.addSubview(usernameField)
            BorderHelper.addBorder(usernameField, edge: .bottom, borderWidth: 1, borderColor: UIColor.gray.withAlphaComponent(0.25))
            usernameField.translatesAutoresizingMaskIntoConstraints = false
            
            usernameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            usernameField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
            usernameField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
            usernameField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            
        }
        
        //Message view
        messageView = UITextView()
        messageView.font = usernameField.font
        messageView.delegate = self
        messageView.textContainer.lineFragmentPadding = 0
        
        if #available(iOS 11.0, *) {
            view.addSubview(messageView)
            messageView.translatesAutoresizingMaskIntoConstraints = false
            BorderHelper.addBorder(messageView, edge: .bottom, borderWidth: 1, borderColor: UIColor.gray.withAlphaComponent(0.25))
            CH.pinHorizontal(messageView, parentView: view, withInsets: .all(8))
            CH.place(messageView, by: usernameField, on: .bottom)
            
        }
        
        //Message view placeholder
        placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("Please enter a detailed description of your issue", comment: "") //TODO: Should be different based on option picked (bug, feature, question)
        
        messageView.addSubview(placeholderLabel)
        if #available(iOS 11.0, *) {
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            CH.pinHorizontal(placeholderLabel, parentView: messageView)
            CH.pinTop(placeholderLabel, parentView: messageView, withInset: (messageView.font?.pointSize)! / 2)
        }
        placeholderLabel.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.3) //TODO: Is there a better way to match placeholder color of UITextField?
        placeholderLabel.isHidden = !messageView.text.isEmpty
        
        //Log UI
        logsRow = ToggleContentRow()
        logsRow.titleLabel.text = "Include system information"
        logsRow.showViewButton()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didRequestInfoPreview))
        logsRow.viewButton.addGestureRecognizer(tapGesture)
                
        CH.pin(logsRow, to: view, onEdge: .bottom, useSafeArea: true)
        logsRow.addBorder()
        
        //Screenshot UI
        if screenshot == nil { screenshot = Bugless.takeScreenshot() }
        if let screenshot = screenshot {
            screenshotRow = ToggleContentRow()
            screenshotRow.titleLabel.text = "Include screenshot"
            screenshotRow.set(image: screenshot)
            
            //Wire up screenshot preview
            screenshotRow.imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didRequestScreenshotPreview))
            screenshotRow.imageView.addGestureRecognizer(tapGesture)
            
            CH.pinHorizontal(screenshotRow, parentView: view)
            CH.place(screenshotRow, by: logsRow, on: .top)
            CH.place(screenshotRow, by: messageView, on: .bottom)
            screenshotRow.addBorder()
        } else {
            CH.place(logsRow, by: messageView, on: .bottom)
        }
        
        //Dark mode
        
        if #available(iOS 13.0, *) {
            
            usernameField.backgroundColor = .systemBackground
            usernameField.textColor = .label
            view.backgroundColor = .systemBackground
            placeholderLabel.textColor = .separator
            
        }
        
    }
    
}

//MARK: - Actions
extension FeedbackViewController {
    
    @objc func didRequestClose() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func didRequestScreenshotPreview() {
        
        if let image = screenshotRow?.imageView?.image {
            let controller = ScreenshotPreviewController()
            controller.screenshot = image
            navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    @objc func didRequestInfoPreview() {
        
        let controller = LogPreviewController(style: .plain)
        controller.logs = systemInfo
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @objc func didRequestSend() {
        
        for sendMethod in Bugless.configuration.sendMethods {
            let integration = Bugless.integration(for: sendMethod)
            integration.send(issue: getIssue())
        }
        
    }
}

//MARK: - Helper methods
extension FeedbackViewController {
    
    func batteryStateToString(_ state: UIDevice.BatteryState) -> String {
        
        return state == .full ? "full" : (state == .unplugged ? "unplugged" : (state == .charging ? "charging" : "unknown") )
        
    }
    
    func interfaceToString(_ interface: UIUserInterfaceIdiom) -> String {
        
        if #available(iOS 9.0, *) {
            return interface == .phone ? "iPhone" : ( interface == .pad ? "iPad" : ( interface == .tv ? "TV" : ( interface == .carPlay ? "CarPlay" : "Unspecified" ) ) )
        } else {
            // Fallback on earlier versions
            return ""
        }
        
    }
    
    func collectLogs() -> [String: String] {
        
        //MAYBE: This might become its own class
        //Collect logs along with system information
        //var logs: [[String: String]] = []
        var logs: [String: String] = [:]
        let device = UIDevice.current
        appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
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
        logs["batteryState"]  =  batteryStateToString(device.batteryState)
        logs["interface"]     =  interfaceToString(device.userInterfaceIdiom)
        
        return logs
        
    }
    
    //TODO: Remove
    func composeEmailBody() -> String {
        
        var result = messageView.text + "\n\nSystem Information:\n\n"
        
        for line in systemInfo {
            result += line.key + ": " + line.value + "\n"
        }
        
        return result
        
    }
    
    //TODO: Remove
    func sendThroughGithubIssue() {
        
        let client = GithubIntegration()
        let issue = Issue()
        issue.username = usernameField.text ?? ""
        issue.title = (appName ?? "Bugless feedback") + ": You've received a user feedback"
        issue.message = messageView.text
        if screenshot != nil { issue.screenshots = [screenshot!] }
        issue.systemInfo = systemInfo
        issue.type = issueType
        client.send(issue: issue)
        
    }
    
    //TODO: Don't include options that have been turned off by the user
    func getIssue() -> Issue {
        let issue = Issue()
        issue.username = usernameField.text ?? ""
        issue.title = (appName ?? "Bugless feedback") + ": You've received a user feedback"
        issue.message = messageView.text
        if screenshotRow.toggleControl.isOn && screenshot != nil {
            issue.screenshots = [screenshot!]
        }
        if logsRow.toggleControl.isOn {
            issue.systemInfo = systemInfo
        }
        issue.type = issueType
        return issue
    }
    
    //MARK: - Notification selectors
    @objc func issueSubmitionSucessful() {
        AlertHelper.info(title: "Success", message: "Your issue was sent successfully", context: self)
        dismiss(animated: true)
    }
    
    @objc func issueSubmitionFailed(notification: Notification) {
        if notification.userInfo?["alert"] == nil || notification.userInfo?["alert"] as! Bool == true {
            AlertHelper.info(title: "Error", message: "Your issue could not be sent. Please try again later.", context: self)
        }
        dismiss(animated: true)
    }
    
    @objc func issueSubmittionStarted() {
        //TODO: Show a loader
    }
}

//MARK: - Text view & Mail composer delegate methods
extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !messageView.text.isEmpty
    }
    
}

extension FeedbackViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("Called from feedbackviewcontroller")
    }
}
