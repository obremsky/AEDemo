//
//  BaseViewModel.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 29/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PromiseKit

class BaseViewModel: NSObject {
    
    let isLoading : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    func fetch(){
        
    }
}
