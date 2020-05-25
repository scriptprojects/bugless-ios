//
//  AlertHelper.swift
//  
//
//  Created By ScriptProjects, LLC on 4/16/20.
//

import UIKit

public class AlertHelper {
    
    static var loaderController: UIAlertController?
    
    static func info(title: String, message: String, buttonTitle: String = "Dismiss", context: UIViewController, completion: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: buttonTitle, style: .cancel, handler: completion))
        DispatchQueue.main.async {
            context.present(alert, animated: true)
        }
        
    }
    
    public static func showLoader(message: String = "Loading...", context: UIViewController) {
        
        hideLoader()
        loaderController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        loaderController?.view.addSubview(UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)))
        context.present(loaderController!, animated: true)
    }
    
    public static func hideLoader() {
        loaderController?.dismiss(animated: true)
    }
    
}
