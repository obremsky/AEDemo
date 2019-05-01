//
//  Image.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit

class ImagesRequest : NSObject, Decodable{
    
    private enum CodingKeys : String, CodingKey {
        case hasMore
        case images = "pictures"
    }

    let hasMore : Bool
    let images : [Image]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasMore = try container.decode(Bool.self, forKey: .hasMore)
        images = try container.decode([Image].self, forKey: .images)
    }
}

class Image: NSObject, Decodable {

    let id : String
    let link : String
    
    private enum CodingKeys : String, CodingKey {
        case id
        case link = "cropped_picture"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id =  try container.decode(String.self, forKey: .id)
        link = try container.decode(String.self, forKey: .link)
    }
}
