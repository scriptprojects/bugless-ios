//
//  ScreenshotPreviewController.swift
//  
//
//  Created By ScriptProjects, LLC on 3/22/20.
//

import UIKit
import PencilKit

//TODO: Add image markup functionality
class ScreenshotPreviewController: UIViewController {
    
    var anchor: Any!
    var screenshot: UIImage!
    var screenshotView: UIImageView!
    
    override func viewDidLoad() {
        
        if screenshot != nil {
            screenshotView = UIImageView(image: screenshot)
            screenshotView.contentMode = .scaleAspectFit
            
            view.addSubview(screenshotView)
            CH.pin(screenshotView, to: view, onEdge: .all, useSafeArea: true)
            screenshotView.layer.borderColor = UIColor.gray.cgColor
            screenshotView.layer.borderWidth = 2
        }
        
        navigationItem.title = "Screenshot"
        
    }
}
