//
//  LogPreviewController.swift
//  
//
//  Created by Erick Del Orbe on 5/25/20.
//

import UIKit

///Lets the user preview the logs that will be sent with their report
class LogPreviewController: UIViewController {
    
    var logView: UITextView!
    var loggers: [String: FileLogger?] = [:]
    
    override func viewDidLoad() {
        
        navigationItem.title = title
        
        logView = UITextView(frame: .zero)
        logView.isEditable = false
        CH.pin(logView, to: view, onEdge: .all)
        
        for (key, logger) in loggers {
            if let logger = logger {
                logView.text += key + " Logs\n" + logger.getLogContents() + "\n"
            }
        }
        
    }
}
