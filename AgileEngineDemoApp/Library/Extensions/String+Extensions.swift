//
//  String+Extensions.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import Foundation

extension String{
    static var docsPath : String{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return path
    }
    
    static var cacheFolder : String {
        return self.docsPath.appendingPathComponent("cache")
    }
    
    func appendingPathComponent(_ string: String) -> String {
        return URL(fileURLWithPath: self).appendingPathComponent(string).path
    }
}

