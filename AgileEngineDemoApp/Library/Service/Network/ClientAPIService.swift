//
//  ClientAPIService.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import Foundation
import PromiseKit

enum ServiceError : Error{
    case emptyAuthToken
}

enum HTTPError : Error{
    case httpError(code : Int)
    
    static func error(code: Int, data: Data?) -> Error? {
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = json as? [String : Any] else { return nil }
                print(dictionary)
                if let errDetails = dictionary["details"] as? [String : Any], errDetails.keys.count > 0 {
                    var errMessage = ""
                    for (key, value) in errDetails {
                        errMessage += "\(key) \(value) \n"
                    }
                    return NSError(domain: "Demo Error", code: code, userInfo: [NSLocalizedDescriptionKey : errMessage])
                } else if let errMessage = dictionary["message"] as? String {
                    return NSError(domain: "Demo Error", code: code, userInfo: [NSLocalizedDescriptionKey : errMessage])
                }
                
            } catch let error as NSError {
                return error
            }
        }
        return nil
    }
}

enum URLType: String {
    case cdn
    case local
}

class ClientAPIService: NSObject {
    
    let tokenKey : String = "Authorization"
    
    static let defaultSession = URLSession(configuration: .default)
    static let validResponseCodes = 200..<300
    var  task : URLSessionTask?
    
    func sendGETRequest(at path: String,
                        withHeaders headers: [String : String]?,
                        withURLType urlType: URLType = .local, useFullPath : Bool = false) -> Promise<Data> {
        
        let urlString = useFullPath ? path : self.baseUrl + path
        var request = URLRequest(url: URL(string : urlString)!)
        request.httpMethod = "GET"
        return self.urlTaskWith(request: request as URLRequest)
    }
    
    func sendPOSTRequest(at path: String,
                         withBody body: Data? = nil,
                         withHeaders headers: [String : String]?,
                         withURLType urlType: URLType = .local) -> Promise<Data> {
        
        var request = URLRequest(url: URL(string : self.baseUrl + path)!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpBody = body
        return self.urlTaskWith(request: request as URLRequest)
    }
    
    
    func sendPUTRequest(at path: String,
                        body: Data? = nil,
                        withHeaders headers: [String : Any]?,
                        withURLType urlType: URLType = .local) -> Promise<Data> {
        
        var request = URLRequest(url: URL(string : self.baseUrl + path)!)
        request.httpMethod = "PUT"
        request.httpBody = body
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        return self.urlTaskWith(request: request as URLRequest)
    }
    
    func sendDELETERequest(at path: String,
                           withHeaders headers: [String : String]?,
                           withURLType urlType: URLType = .local) -> Promise<Data> {
        
        var request = URLRequest(url:URL(string : self.baseUrl + path)!)
        request.httpMethod = "DELETE"
        return self.urlTaskWith(request: request as URLRequest)
    }
    
    
    func urlTaskWith(request : URLRequest) -> Promise<Data> {
        print("==============\(self) : \(request.url!)")
        if let body = request.httpBody{
            do {
                if let dict = try JSONSerialization.jsonObject(with: body, options: .allowFragments) as? [String : Any]{
                    print(dict)
                }
            }catch{
            }
        }
        
        return Promise<Data> {seal in
            
            var mutableRequest = request
            
            if self.needsAuthorization == true {
                guard let token = NetworkManager.shared.authToken else {
                    seal.reject(ServiceError.emptyAuthToken)
                    return
                }
                mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: self.tokenKey)
            }
            
            
            let task = NetworkManager.shared.session.dataTask(with: mutableRequest) {(data, response , error) in
                defer{
                    self.task = nil
                }
                
                if let response = response as? HTTPURLResponse, let cookieDict = response.allHeaderFields as? [String : String] , let url = response.url{
                    
                    print(response)
                    
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieDict, for: url)
                    for cookie in cookies{
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                   
                    
                    if response.statusCode > 300 {
                        let error = HTTPError.error(code: response.statusCode, data: data) ?? HTTPError.httpError(code: response.statusCode)
                        seal.reject(error)
                        return
                    }
                }
                
                if let error = error {
                    print(error)
                }
                
                if let data = data{
                    do {
                        let dict = try JSONSerialization.jsonObject(with: data, options: [])
                        print(dict)
                        
                    }catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }else {
                    print("\(self) : empty response data")
                }
                
                seal.resolve(data, error)
            }
            self.task = task
            task.resume()
        }
    }
    
    func downloadFile(url : String, fileUrl : String) -> Promise<String>{
        var request = URLRequest(url: URL(string : url)!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        return Promise<String> {seal in
            firstly{
                return NetworkManager.shared.session.downloadTask(.promise, with: request, to: URL(fileURLWithPath: fileUrl))
                }.done { (url, _) in
                    print("Did download file to \(url)")
                    seal.fulfill(url.absoluteString)
                }.catch { (error) in
                    print("Cant download file: \(error)")
                    seal.reject(error)
            }
        }
    }
    
    var baseUrl : String {
        return "http://195.39.233.28:8035/"
    }
    
    
    var needsAuthorization : Bool {
        return true
    }
}
