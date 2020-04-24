//
//  BorderedView.swift
//  
//
//  Created By ScriptProjects, LLC on 3/29/20.
//

import UIKit
import CoreGraphics

//TODO: UIHelper maybe??
class BorderHelper {
    
    static func addBorder(_ view: UIView, edge: CH.Edge, borderWidth: CGFloat, borderColor: UIColor) {
        
    
        let borderView = UIView(frame: .zero)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = borderColor
        view.addSubview(borderView)
        if edge == .bottom || edge == .top {
            CH.setHeight(borderView, height: borderWidth)
            CH.pinHorizontal(borderView, parentView: view.superview!)
        } else {
            CH.setWidth(borderView, width: view.superview!.frame.width)
            CH.pinVertical(borderView, parentView: view.superview!)
        }
        CH.place(borderView, by: view, on: edge, inset: 1)
        
    }
    
}
