//
//  AuthService.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import PromiseKit


enum AuthServiceError : Error{
    case invalidResponse
}

class AuthService: ClientAPIService {
    func execute() -> Promise<String>{
        return Promise<String>{seal in
            do {
                let body = ["apiKey" : "23567b218376f79d9415"]
                let json = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                firstly{
                    return self.sendPOSTRequest(at: "auth", withBody : json, withHeaders: nil)
                    }.done({ (data) in
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            print(json)
                            if let dictionary = json as? [String : Any], let token = dictionary["token"] as? String{
                                seal.fulfill(token)
                            }else {
                                seal.reject(AuthServiceError.invalidResponse)
                            }
                        }catch{
                            seal.reject(error)
                        }
                    }).catch({ (error) in
                        seal.reject(error)
                    })
            }catch{
                seal.reject(error)
            }
        }
    }
    
    override var needsAuthorization: Bool{
        return false
    }
}
