//
//  Logger.swift
//  
//
//  Created by Erick Del Orbe on 5/24/20.
//

import Foundation

public class FileLogger {
    
    var queueName = "com.bugless.logging"
    var logDirectoryPath: String = "logs/"
    var logFileName: String = "main.log"
    var logFileUrl: URL!
    var serialQueue: DispatchQueue!
    
    func initializeLogFile() {
        if let logDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(logDirectoryPath) {
            
            do {
                try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Unable to create log directory")
            }
            
            logFileUrl = logDirectory.appendingPathComponent(logFileName, isDirectory: false)
            if !FileManager.default.fileExists(atPath: logFileUrl.path) {
                FileManager.default.createFile(atPath: logFileUrl.path, contents: nil, attributes: nil)
                print(logFileUrl.absoluteString.removingPercentEncoding!)
            }
        }
    }
    
    func writeToLog(_ logString: String) {
        
        let prefix = getPrefix()
        
        if logFileUrl == nil {
            initializeLogFile()
        }
        
        //Write without blocking
        if let logUrl = self.logFileUrl {
            if serialQueue == nil { serialQueue = DispatchQueue(label: queueName) }
            serialQueue.async {
                do {
                    let handle = try FileHandle(forWritingTo: logUrl)
                    handle.seekToEndOfFile()
                    handle.write((prefix + logString + "\n").data(using: .utf8)!)
                    handle.closeFile()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func getLogContents() -> String {
        
        return (try? String(contentsOf: logFileUrl)) ?? ""
        
    }
    
    func getPrefix() -> String {
        //TODO: Better date formatting
        return "\(Date()): "
    }
}
