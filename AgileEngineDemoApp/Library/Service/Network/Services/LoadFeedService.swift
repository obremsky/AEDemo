//
//  LoadFeedService.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import PromiseKit

class LoadFeedService: ClientAPIService {
    let page : Int
    init(page : Int) {
        self.page = page
    }
    func execute() -> Promise<ImagesRequest>{
        return Promise<ImagesRequest> {seal in
            firstly{
                return self.sendGETRequest(at: "images?page=\(self.page)", withHeaders: nil)
                }.done { (data) in
                    do {
                        let images = try JSONDecoder().decode(ImagesRequest.self, from: data)
                        seal.fulfill(images)
                    }catch{
                        seal.reject(error)
                    }
                }.catch { (error) in
                    seal.reject(error)
            }
        }
    }
}
