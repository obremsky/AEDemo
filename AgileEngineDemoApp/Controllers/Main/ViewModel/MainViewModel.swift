//
//  MainViewModel.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import PromiseKit
import RxSwift
import RxCocoa

class MainViewModel: BaseViewModel {
    var sections : [BaseCollectionCellModel] = [BaseCollectionCellModel]()
    var onReload : PublishSubject<Void> = PublishSubject()
    
    var page : Int = 0
    var shouldLoadNext : Bool = true

    override func fetch() {
        if NetworkManager.shared.isLoggedIn{
            self.loadFeed()
        }else{
            self.login {[weak self] (error) in
                if let _ = error {
                    print(error)
                }else{
                    self?.loadFeed()
                }
            }
        }
    }
    
    func loadFeed(){
        self.isLoading.accept(true)
        firstly{
            return LoadFeedService(page: self.page).execute()
            }.done {[weak self] (result) in
                
                guard let strongSelf = self else {return}
                strongSelf.shouldLoadNext = result.hasMore
                
                if result.images.count == 0{
                    return
                }
                
                let loaded = result.images.map({ (model) -> MainCellModel in
                    return MainCellModel(model: model)
                })
                
                strongSelf.sections.append(contentsOf: loaded)
                strongSelf.onReload.onNext(())
            }.catch { (error) in
                print(error)
            }.finally {[weak self] in
              self?.isLoading.accept(false)
        }
    }
    
    func login(_ completion : ((Error?) -> ())?){
        self.isLoading.accept(true)
        firstly{
            return AuthService().execute()
            }.done { (token) in
                NetworkManager.shared.saveToken(token)
                completion?(nil)
            }.catch { (error) in
                completion?(error)
            }.finally {[weak self] in
            self?.isLoading.accept(false)
        }
    }
    
    func insets(section : Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func interItemSpacing(section : Int) -> CGFloat{
        return 5
    }
    
    func sizeForCell(at indexPath : IndexPath, collectionViewSize : CGSize) -> CGSize{
        let insets = self.insets(section: indexPath.section)
        let width = (collectionViewSize.width - insets.left - insets.right - self.interItemSpacing(section: indexPath.section)) / 2
        return CGSize(width: width, height: width)
    }

    func willDisplay(at indexPath : IndexPath){
        if self.isLoading.value || !self.shouldLoadNext{
            return
        }
        
        if indexPath.row >= self.sections.count - 6{
            self.page += 1
            self.loadFeed()
        }
    }
}
