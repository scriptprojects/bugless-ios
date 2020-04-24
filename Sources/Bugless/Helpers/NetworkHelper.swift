//
//  NetworkHelper.swift
//  
//
//  Created By ScriptProjects, LLC on 4/9/20.
//

import UIKit

class NetworkHelper {
    
    static var credentialHeaders: [String: String] = [:]
    
    static func setCredential(headers: [String: String]) {
        credentialHeaders = headers
    }
    
    static func imgurUpload(image: UIImage, withCredentials credentials: [String: String], completion: @escaping (String?) -> Void) {
        let imgurUploadUrl = "https://api.imgur.com/3/upload"
        setCredential(headers: credentials)
        upload(URL(string: imgurUploadUrl), image: image, completion: completion)
    }
    
    static func upload(_ url: URL?, image: UIImage, completion: @escaping (String?) -> Void) {
        
        guard let url = url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let uuid = UUID().uuidString
        let boundary = "Boundary-\(uuid)"
        
        for (key, value) in credentialHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(parameters: [:], boundary: boundary, data: image.jpegData(compressionQuality: 0.7)!, mimeType: "image/jpg", filename: "screenshot1_\(uuid).jpg")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            if let data = data, let result = try? JSONDecoder().decode(ImageUploadResult.self, from: data) {
                completion(result.data.link)
            } else {
                //TODO: Handle error
                completion(nil)
            }
        }
        task.resume()
        
    }
    
    static func createBody(parameters: [String: String], boundary: String, data: Data, mimeType: String, filename: String) -> Data {
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.append(getData(boundaryPrefix))
            body.append(getData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"))
            body.append(getData("\(value)\r\n"))
        }
        
        body.append(getData(boundaryPrefix))
        body.append(getData("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n"))
        body.append(getData("Content-Type: \(mimeType)\r\n\r\n"))
        body.append(data)
        body.append(getData("\r\n"))
        body.append(getData("--" + boundary + "--"))
        
        return body
        
    }
    
    static func getData(_ string: String) -> Data {
        
        let stringData = string.data(using: .utf8, allowLossyConversion: false)!
        return stringData
        
    }
    
    static func postJson(_ urlString: String, jsonString json: String, headers: [String: String] = [:], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let url = URL(string: urlString) {
            var request: URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("BuglessMobile/1", forHTTPHeaderField: "User-Agent")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
            
            request.httpBody = json.data(using: .utf8)
            let jsonTask: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                completion(data, response, error)
            }
            jsonTask.resume()
        }
    }
}


class ImageUploadResult: Codable {
    var data: ImageUploadResultData
    var success: Bool
    var status: Int
}

class ImageUploadResultData: Codable {
    var id: String = ""
    var title: String? = ""
    var description: String? = ""
    var deletehash: String = ""
    var link: String = ""
}
