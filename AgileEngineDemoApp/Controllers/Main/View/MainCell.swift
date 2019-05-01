//
//  MainCell.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainCell: BaseCollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.gray
    }
    
    override func configure(with viewModel: BaseCollectionCellModel) {
        guard let viewModel = viewModel as? MainCellModel else {return}
        viewModel.image.bind(to: self.imageView.rx.image).disposed(by: disposeBag)
        
        viewModel.image.map { (image) -> UIColor in
            guard let image = image else {return .clear}
            if image.size != .zero{
                return .clear
            }else {
                return .red
            }
            
            }.subscribe(onNext: {[weak self] (color) in
                self?.imageView.backgroundColor = color
            }).disposed(by: disposeBag)
        super.configure(with: viewModel)
    }
    
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
        self.imageView.image = nil
        self.imageView.backgroundColor = .clear
        super.prepareForReuse()
    }
}
