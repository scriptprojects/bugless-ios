//
//  LogPreviewController.swift
//  
//
//  Created By ScriptProjects, LLC on 3/30/20.
//

import UIKit

class LogPreviewController: UITableViewController {
    
    var logs: [String: String] = [:]
    var keys: [String] = []
    
    internal override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //tableView.register(UITableViewCell, forCellReuseIdentifier: "logItemCell")
        keys = Array(logs.keys)
        navigationItem.title = "System Info/Logs"
    }
}

//MARK: - Datasource methods
extension LogPreviewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let key = keys[indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "logItemCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "logItemCell")
        }
        cell?.textLabel?.text = camelCaseToWords(keys[indexPath.row])
        cell?.detailTextLabel?.text = logs[key]
        
        return cell!
    }
    
    func camelCaseToWords(_ string: String) -> String {
        return string.unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0.count > 0 {
                    return ($0.capitalized + " " + String($1))
                }
            }
            return $0.capitalized + String($1)
        }
    }
    
}
