//
//  MainCellModel.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PromiseKit

class MainCellModel: BaseCollectionCellModel {
    let image : BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    let model : Image

    //you can show some loader or smth like this in the cell
    var isLoading : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    init(model : Image) {
        self.model = model
    }
    
    override var cellIdentifier: String{
        return "MainCell"
    }
    
    override func tearUp() {
        if self.image.value != nil || self.isLoading.value{
            return
        }
    
        self.isLoading.accept(true)
        firstly{
            return DownloadImageService(link: self.model.link).execute()
            }.done {[weak self] (imageUrl) in
                
                let path = String.cacheFolder.appendingPathComponent(imageUrl)
                if let data = FileManager.default.contents(atPath: path), let image = UIImage(data: data){
                    
                    //print(data)
                    self?.image.accept(image)
                }
            }.catch {[weak self] (error) in
                self?.image.accept(UIImage())
            }.finally {[weak self] in
                self?.isLoading.accept(false)
        }
    }
}
