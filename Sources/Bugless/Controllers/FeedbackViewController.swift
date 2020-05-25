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
    var systemInfoRow: ToggleContentRow!
    var screenshotRow: ToggleContentRow!
    var logsRow: ToggleContentRow!
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
        systemInfo = Issue.collectSystemInfo()
        
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
        
        //TODO: Support targets below iOS 11
        if #available(iOS 11.0, *) {
            usernameField.textContentType = .emailAddress
        }
            
            
        /*view.addSubview(usernameField)
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        
        usernameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        usernameField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        usernameField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        usernameField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true*/
        
        //Message view
        messageView = UITextView()
        messageView.font = usernameField.font
        messageView.delegate = self
        messageView.textContainer.lineFragmentPadding = 0
        
        //Message view placeholder
        placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("Please enter a detailed description of your issue", comment: "") //TODO: Should be different based on option picked (bug, feature, question)
        
        placeholderLabel.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.3) //TODO: Is there a better way to match placeholder color of UITextField?
        placeholderLabel.isHidden = !messageView.text.isEmpty
        
        //System Info UI
        systemInfoRow = ToggleContentRow()
        systemInfoRow.titleLabel.text = "Include system information"
        systemInfoRow.showViewButton()
        systemInfoRow.toggleControl.isEnabled = false
        
        systemInfoRow.viewButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didRequestInfoPreview)))
                
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
            
        }
        
        //Logs UI
        logsRow = ToggleContentRow()
        logsRow.titleLabel.text = "Include logs"
        logsRow.showViewButton()
        logsRow.viewButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didRequestLogPreview)))
        
        //MARK: - Constraints based UI layout
        //Username field
        CH.pin(usernameField, to: view, onEdge: .top, withInsets: .leading(8), useSafeArea: true)
        CH.setHeight(usernameField, height: 44)
        BorderHelper.addBorder(usernameField, edge: .bottom, borderWidth: 1, borderColor: UIColor.gray.withAlphaComponent(0.25))
        
        //Message view
        CH.pinHorizontal(messageView, parentView: view, withInsets: .all(8))
        CH.place(messageView, by: usernameField, on: .bottom)
        BorderHelper.addBorder(messageView, edge: .bottom, borderWidth: 1, borderColor: UIColor.gray.withAlphaComponent(0.25))
        
        //Message placeholder view
        CH.pinHorizontal(placeholderLabel, parentView: messageView)
        CH.pinTop(placeholderLabel, parentView: messageView, withInset: (messageView.font?.pointSize)! / 2)
        
        //Info row
        //CH.pin(systemInfoRow, to: view, onEdge: .bottom, useSafeArea: true)
        CH.pinHorizontal(systemInfoRow, parentView: view)
        systemInfoRow.addBorder()
        
        //Screenshot
        if screenshot != nil {
            CH.pinHorizontal(screenshotRow, parentView: view)
            CH.place(screenshotRow, by: messageView, on: .bottom)
            CH.place(screenshotRow, by: systemInfoRow, on: .top)
            screenshotRow.addBorder()
        } else {
           CH.place(systemInfoRow, by: messageView, on: .bottom)
        }
        
        //Log row
        CH.pin(logsRow, to: view, onEdge: .bottom, useSafeArea: true)
        CH.place(logsRow, by: systemInfoRow, on: .bottom)
        logsRow.addBorder()
        
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
        
        let controller = SystemInfoPreviewController(style: .plain)
        controller.logs = systemInfo
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @objc func didRequestLogPreview() {
        
        let controller = LogPreviewController()
        controller.loggers = ["Main": Bugless.fileLog, "Network": Bugless.networkLog]
        controller.title = "Logs"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func didRequestSend() {
        
        let issue = Issue.getIssue(screenshot)
        
        issue.username = usernameField.text ?? ""
        issue.title = (appName ?? "Bugless feedback") + ": You've received a user feedback"
        issue.message = messageView.text
        issue.type = issueType
        if !screenshotRow.toggleControl.isOn {
            issue.screenshots = []
        }
        if !logsRow.toggleControl.isOn {
            issue.mainLog = "[Declined by user]"
            issue.networkLog = "[Declined by user]"
        }
        
        for sendMethod in Bugless.configuration.sendMethods {
            let integration = Bugless.integration(for: sendMethod)
            
            integration.send(issue: issue)
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
    
    //MARK: - Notification selectors
    @objc func issueSubmitionSucessful() {
        DispatchQueue.main.async {
            AlertHelper.hideLoader()
            AlertHelper.info(title: "Success", message: "Your issue was sent successfully", context: self) { _ in
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc func issueSubmitionFailed(notification: Notification) {
        DispatchQueue.main.async {
            AlertHelper.hideLoader()
            if notification.userInfo?["alert"] == nil || notification.userInfo?["alert"] as! Bool == true {
                AlertHelper.info(title: "Error", message: "Your issue could not be sent. Please try again later.", context: self) { _ in
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc func issueSubmittionStarted() {
        AlertHelper.showLoader(message: "Submitting issue...", context: self)
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
