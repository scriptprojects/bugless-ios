//
//  NetworkTap.swift
//  
//
//  Created by Erick Del Orbe on 5/25/20.
//
//

import Foundation

///Monitors network requests for the purposes of logging
class NetworkTap: URLProtocol {
    
    //MARK: - Properties
    private lazy var session: URLSession = { [unowned self] in return URLSession(configuration: .default, delegate: self, delegateQueue: nil) }()
    private static let requestKey = "com.bugless.networkRequestKey"
    private var requestModel: NetworkRequest = NetworkRequest()
    private var responseData: NSMutableData?
    static var delegate: NetworkTapDelegate?
    
    //MARK: - Methods
    private static func canHandle(request: URLRequest) -> Bool {
        //TODO: Implement function that will check if we can indeed handle this request
        return true
    }
}

//MARK: - URLProtocol overrides
extension NetworkTap {
    
    override class public func canInit(with request: URLRequest) -> Bool {
    
        return canHandle(request: request)
    }
    
    public override class func canInit(with task: URLSessionTask) -> Bool {
        
        guard let request = task.currentRequest else { return false }
        return canHandle(request: request)
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        
        return request
        
    }
    
    public override func startLoading() {
        
        //Log request
        requestModel.request = request
        requestModel.startedAt = Date()
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: NetworkTap.requestKey, in: mutableRequest)
        session.dataTask(with: mutableRequest as URLRequest).resume()
        
    }
    
    public override func stopLoading() {
        
        session.getTasksWithCompletionHandler { (dataTasks, _, _) in
            dataTasks.forEach { $0.cancel() }
        }
        
    }
    
}


extension NetworkTap: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        responseData?.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        requestModel.response = response as? HTTPURLResponse
        
        self.responseData = NSMutableData()
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        let updatedRequest: URLRequest
        if URLProtocol.property(forKey: NetworkTap.requestKey, in: request) != nil {
            let requestCopy = mutableRequest(request)
            URLProtocol.removeProperty(forKey: NetworkTap.requestKey, in: requestCopy)
            updatedRequest = requestCopy as URLRequest
        } else {
            updatedRequest = request
        }
        
        client?.urlProtocol(self, wasRedirectedTo: updatedRequest, redirectResponse: response)
        completionHandler(updatedRequest)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let responseData = responseData as Data?, let responseString = String(data: responseData, encoding: .utf8) {
            requestModel.responseString = responseString
        }
        
        requestModel.endedAt = Date()
        NetworkTap.delegate?.didReceiveRequest(requestModel)
        
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func mutableRequest(_ request: URLRequest) -> NSMutableURLRequest {
        
        return (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
    }
    
}

protocol NetworkTapDelegate {
    
    func didReceiveRequest(_ requestModel: NetworkRequest)
    
}
