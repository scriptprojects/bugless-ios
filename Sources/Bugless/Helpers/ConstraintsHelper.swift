//
//  ConstraintsHelper.swift
//  
//
//  Created By ScriptProjects, LLC on 3/22/20.
//

import UIKit

typealias CH = ConstraintsHelper

class ConstraintsHelper {
    
    enum Edge {
        case leading
        case trailing
        case top
        case bottom
        case all
    }
    
    static func pin(_ view: UIView, to parentView: UIView, onEdge edge: Edge, withInsets insets: EdgeInsets = .zero, useSafeArea: Bool = false) {
        
        if #available(iOS 9.0, *) {
            
            if !parentView.subviews.contains(view) { parentView.addSubview(view) }
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if edge != .leading  { pinTrailing(view, parentView: parentView, withInset: insets.trailing, useSafeArea: useSafeArea) }
            if edge != .trailing { pinLeading (view, parentView: parentView, withInset: insets.leading, useSafeArea: useSafeArea)  }
            if edge != .top      { pinBottom  (view, parentView: parentView, withInset: insets.bottom, useSafeArea: useSafeArea)   }
            if edge != .bottom   { pinTop     (view, parentView: parentView, withInset: insets.top, useSafeArea: useSafeArea)      }
            
        }
        
    }
    
    static func pinHorizontal(_ view: UIView, parentView: UIView, withInsets insets: EdgeInsets = .zero, useSafeArea: Bool = false) {
        
        if !parentView.subviews.contains(view) { parentView.addSubview(view) }
        view.translatesAutoresizingMaskIntoConstraints = false
        pinLeading(view, parentView: parentView, withInset: insets.leading, useSafeArea: useSafeArea)
        pinTrailing(view, parentView: parentView, withInset: insets.trailing, useSafeArea: useSafeArea)
        
    }
    
    static func pinVertical(_ view: UIView, parentView: UIView, withInsets insets: EdgeInsets = .zero, useSafeArea: Bool = false) {
        
        if !parentView.subviews.contains(view) { parentView.addSubview(view) }
        view.translatesAutoresizingMaskIntoConstraints = false
        pinTop(view, parentView: parentView, withInset: insets.top, useSafeArea: useSafeArea)
        pinBottom(view, parentView: parentView, withInset: insets.bottom, useSafeArea: useSafeArea)
        
    }
    
    static func pinLeading(_ view: UIView, parentView: UIView, withInset inset: CGFloat = 0, useSafeArea: Bool = false) {
        if #available(iOS 11.0, *) {
            let leadingAnchor = useSafeArea ? parentView.safeAreaLayoutGuide.leadingAnchor : parentView.leadingAnchor
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset).isActive = true
        } else {
            //TODO: iOS 8.0 and below fallback
        }
    }
    
    static func pinTrailing(_ view: UIView, parentView: UIView, withInset inset: CGFloat = 0, useSafeArea: Bool = false) {
        if #available(iOS 11.0, *) {
            let trailingAnchor = useSafeArea ? parentView.safeAreaLayoutGuide.trailingAnchor : parentView.trailingAnchor
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset).isActive = true
        } else {
            //TODO: iOS 8.0 and below fallback
        }
    }
    
    static func pinTop(_ view: UIView, parentView: UIView, withInset inset: CGFloat = 0, useSafeArea: Bool = false) {
        if #available(iOS 11.0, *) {
            let topAnchor = useSafeArea ? parentView.safeAreaLayoutGuide.topAnchor : parentView.topAnchor
            view.topAnchor.constraint(equalTo: topAnchor, constant: inset).isActive = true
        } else {
            //TODO: iOS 8.0 and below fallback
        }
    }
    
    static func pinBottom(_ view: UIView, parentView: UIView, withInset inset: CGFloat = 0, useSafeArea: Bool = false) {
        if #available(iOS 11.0, *) {
            let bottomAnchor = useSafeArea ? parentView.safeAreaLayoutGuide.bottomAnchor : parentView.bottomAnchor
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1*inset).isActive = true
        } else {
            //TODO: iOS 8.0 and below fallback
        }
    }
    
    static func place(_ view: UIView, by otherView: UIView, on edge: Edge, inset: CGFloat = 0) {
        
        if #available(iOS 9.0, *) {
            
                 if edge == .leading  { otherView.leadingAnchor .constraint(equalTo: view.trailingAnchor, constant: inset).isActive = true }
            else if edge == .trailing { otherView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset) .isActive = true }
            else if edge == .top      { otherView.topAnchor     .constraint(equalTo: view.bottomAnchor, constant: inset)  .isActive = true }
            else if edge == .bottom   { otherView.bottomAnchor  .constraint(equalTo: view.topAnchor, constant: inset)     .isActive = true }
            
        }
        
    }
    
    static func setHeight(_ view: UIView, height: CGFloat) {
        
        if #available(iOS 9.0, *) {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    static func setWidth(_ view: UIView, width: CGFloat) {
        if #available(iOS 9.0, *) {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    static func setAspectRatio(_ view: UIView, ratio: CGFloat = 1.0) {
        
        if #available(iOS 9.0, *) {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ratio).isActive = true
        }
        
    }
    
}

struct EdgeInsets {
    var top: CGFloat = 0
    var bottom: CGFloat = 0
    var leading: CGFloat = 0
    var trailing: CGFloat = 0
    
    static var zero: EdgeInsets {
        EdgeInsets()
    }
    
    static func leading(_ inset: CGFloat)  -> EdgeInsets { EdgeInsets(leading: inset) }
    
    static func trailing(_ inset: CGFloat) -> EdgeInsets { EdgeInsets(trailing: inset) }
    
    static func top(_ inset: CGFloat)      -> EdgeInsets { EdgeInsets(top: inset) }
    
    static func bottom(_ inset: CGFloat)   -> EdgeInsets { EdgeInsets(bottom: inset) }
    
    static func all(_ inset: CGFloat)      -> EdgeInsets { EdgeInsets(top: inset, bottom: inset, leading: inset, trailing: -1*inset) }
}
