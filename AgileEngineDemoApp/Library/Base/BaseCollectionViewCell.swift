//
//  BaseCollectionViewCell.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 29/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
 
    func configure(with viewModel : BaseCollectionCellModel){
        viewModel.tearUp()
    }
}
