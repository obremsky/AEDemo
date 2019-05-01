//
//  NetworkManager.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    fileprivate  let tokenKey : String = "authToken"
    
    lazy var session : URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    static var currentSsid : String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        let key = kCNNetworkInfoKeySSID as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else { continue }
            return interfaceInfo[key] as? String
        }
        return nil
    }
    
    var isLoggedIn : Bool{
        guard let _ = UserDefaults.standard.object(forKey: self.tokenKey) as? String else {return false}
        return false
    }
    
    func saveToken(_ token : String){
        UserDefaults.standard.set(token, forKey: self.tokenKey)
    }
    
    var authToken : String?{
        return UserDefaults.standard.object(forKey: self.tokenKey) as? String
    }
}
