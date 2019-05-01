//
//  BaseVC.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 29/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import MBProgressHUD

class BaseVC: UIViewController {
    
    var progressHUD : MBProgressHUD?
    public func showLoader(_ shouldDisplay: Bool) -> Void {
        DispatchQueue.main.async {[weak self] in
            if shouldDisplay {
                self?.setActivityIndicator()
            } else {
                self?.removeActivityIndicator()
            }
        }
    }

    private func setActivityIndicator() -> Void {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progressHUD = progressHUD
    }
    
    private func removeActivityIndicator() -> Void {
        self.progressHUD?.hide(animated: true)
        self.progressHUD = nil
    }
}
