//
//  DownloadImageService.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import PromiseKit

enum DownloadImageServiceError : Error{
    case invalidUrl
}

class DownloadImageService: ClientAPIService {

    let link : String
    var temp : String?
    
    init (link : String){
        self.link = link
        if let url = URL(string: link){
            self.temp = String.cacheFolder.appendingPathComponent(String(Date().timeIntervalSince1970) + "_" +  url.lastPathComponent)
        }
    }
    
    func execute() -> Promise<String>{
        return Promise<String>{seal in
            guard let storage = self.temp else {
                seal.reject(DownloadImageServiceError.invalidUrl)
                return
            }
            
            firstly{
                return self.downloadFile(url: link, fileUrl: storage)
                }.done { (fileUrl) in
                    seal.fulfill(URL(fileURLWithPath: fileUrl).lastPathComponent)
                }.catch { (error) in
                    seal.reject(error)
            }
        }
    }
}
