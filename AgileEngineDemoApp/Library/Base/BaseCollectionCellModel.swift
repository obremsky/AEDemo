//
//  BaseCollectionCellModel.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 29/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit

class BaseCollectionCellModel: NSObject {
    
    private var identifier : String = "Cell"
    
    var cellIdentifier : String{
        return self.identifier
    }
    
    
    func tearUp(){
        
    }
    
    func tearDown(){
        
    }
}
