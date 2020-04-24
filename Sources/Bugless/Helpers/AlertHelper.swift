//
//  File.swift
//  
//
//  Created By ScriptProjects, LLC on 4/16/20.
//

import UIKit

class AlertHelper {
    
    static func info(title: String, message: String, buttonTitle: String = "Dismiss", context: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: buttonTitle, style: .cancel, handler: nil))
        context.present(alert, animated: true)
        
    }
    
}
