//
//  ToggleContentRow.swift
//  
//
//  Created By ScriptProjects, LLC on 3/22/20.
//

import UIKit

class ToggleContentRow: UIView {
    
    var toggleControl: UISwitch!
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var viewButton: UIButton!
    
    init() {
        super.init(frame: .zero)
        
        //Toggle
        toggleControl = UISwitch()
        toggleControl.isOn = true
        CH.pin(toggleControl, to: self, onEdge: .trailing, withInsets: .all(12))
        
        //Title
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        CH.pinLeading(titleLabel, parentView: self, withInset: 12)
        CH.pinTop(titleLabel, parentView: self, withInset: 12)
        CH.setHeight(titleLabel, height: 31)
        
        CH.setHeight(self, height: 55)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ToggleContentRow {
    
    func set(image: UIImage) {
        
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        
        CH.setAspectRatio(imageView)
        CH.pinVertical(imageView, parentView: self, withInsets: .all(5))
        CH.place(imageView, by: toggleControl, on: .leading, inset: 12)
        
    }
    
    func showViewButton() {
        
        //View button
        viewButton = UIButton(type: .custom)
        viewButton.setTitle("View", for: .normal)
        viewButton.setTitleColor(UIColor(red: 0.06, green: 0.45, blue: 0.98, alpha: 1), for: .normal)
        addSubview(viewButton)
        viewButton.translatesAutoresizingMaskIntoConstraints = false
    
        CH.pinTop(viewButton, parentView: self)
        CH.pinBottom(viewButton, parentView: self)
        CH.place(viewButton, by: toggleControl, on: .leading, inset: 12)
        
    }
    
    
    func addBorder() {
        BorderHelper.addBorder(self, edge: .bottom, borderWidth: 1, borderColor: UIColor.gray.withAlphaComponent(0.25))
    }
}
