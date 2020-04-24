//
//  Bugless.swift
//
//  Created By ScriptProjects, LLC on 3/20/20.
//  Copyright © 2020 ScriptProjects, LLC. All rights reserved.
//

import UIKit

public class Bugless {
    
    //MARK: - Private API
    init() {}
    
    static var configuration: Configuration = Configuration()
    
    static var integrations: [IssueIntegration] = []
    
    static var prefs = UserDefaults(suiteName: "ml.bugless.preferences")  //Persistent storage
    
    static func showOptions(_ context: UIViewController, screenshot: UIImage?) {
        
        //Localized strings
        let alertTitle = NSLocalizedString("Need help?", comment: "Bugless: Popup title asking the user what kind of report they want to make")
        
        //Show options with alert controller
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        let bug = UIAlertAction(title: "Report a problem", style: .default) { _ in
            showFeedbackForm(context, screenshot: screenshot, issueType: .bug)
        }
        let question = UIAlertAction(title: "Ask a question", style: .default) { _ in
            showFeedbackForm(context, screenshot: screenshot, issueType: .question)
        }
        let suggest = UIAlertAction(title: "Give a suggestion", style: .default) { _ in
            showFeedbackForm(context, screenshot: screenshot, issueType: .suggestion)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(bug)
        alert.addAction(question)
        alert.addAction(suggest)
        alert.addAction(cancel)
        context.present(alert, animated: true)
        
    }
    
    static func showFeedbackForm(_ context: UIViewController, screenshot: UIImage?, issueType: IssueType = .none) {
        
        if Bugless.configuration.skipFeedbackForm {
            let issue = Issue.issueWith(screenshot: screenshot)
            integrations = []
            for sendMethod in Bugless.configuration.sendMethods {
                let integration = Bugless.integration(for: sendMethod)
                integrations.append(integration)
                integration.send(issue: issue)
            }
        } else {
            let feedbackController = FeedbackViewController(screenshot)
            
            switch issueType {
            case .bug:
                feedbackController.navigationItem.title = "Report a problem"
            case .suggestion:
                feedbackController.navigationItem.title = "Suggest improvement"
            case .question:
                feedbackController.navigationItem.title = "Ask a question"
            case .none:
                feedbackController.navigationItem.title = ""
            }
            
            let nav = UINavigationController()
            nav.viewControllers = [feedbackController]
            nav.modalPresentationStyle = .fullScreen
            
            context.present(nav, animated: true, completion: nil)
        }
        
    }
    
    static func takeScreenshot() -> UIImage? {

        if #available(iOS 10.0, *) {
            if let window = topMostViewController()?.view.window {
                return UIGraphicsImageRenderer(size: window.bounds.size).image { _ in
                    window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func getTopMostViewController(from root: UIViewController) -> UIViewController {
        
        if root.presentedViewController == nil {
            return root
        }
        if let navigation = root.presentedViewController as? UINavigationController {
            if navigation.visibleViewController != nil {
                return getTopMostViewController(from: navigation.visibleViewController!)
            } else {
                return navigation
            }
        }
        if let tab = root.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return getTopMostViewController(from: selectedTab)
            }
            return getTopMostViewController(from: tab)
            
        }
        return getTopMostViewController(from: root.presentedViewController!)
    }
    
    static func topMostViewController() -> UIViewController? {
        if let controller = UIApplication.shared.windows.first?.rootViewController {
            return getTopMostViewController(from: controller)
        }
        return nil
        
    }
    
    static func integration(for sendMethod: Configuration.Integration) -> IssueIntegration {
        switch sendMethod {
        case .nativeEmailClient:
            return EmailIntegration()
        case .webhook:
            return WebhookIntegration()
        }
    }
    
    @objc static func cleanUp() {
        integrations = []
    }
    
    //MARK: - Public API
    public static func initialize(configuration config: Configuration? = nil) {
        
        //TODO: Check credentials if needed (email doesn't require credentails)
        if let config = config { configuration = config }
        switch configuration.trigger {
        case .shake:
            //TODO: Shake initialization
            break
        case .screenshot:
            //TODO: Screenshot initialization
            break
        default:
            //None, manual triggers only
            break
        }
        NotificationCenter.default.addObserver(Bugless.self, selector: #selector(cleanUp), name: .buglessIssueSubmittionSuccesful, object: nil)
        NotificationCenter.default.addObserver(Bugless.self, selector: #selector(cleanUp), name: .buglessIssueSubmitionFailed, object: nil)
    }
    
    public static func show() {
        
        let screenshot = takeScreenshot()
        let topMostViewController = Bugless.topMostViewController()
        
        if let context = topMostViewController {
            showOptions(context, screenshot: screenshot)
        } else {
            print("Bugless Error: Unable to find top most view controller")
        }
    }
}
