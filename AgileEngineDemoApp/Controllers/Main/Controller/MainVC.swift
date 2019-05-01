//
//  MainVC.swift
//  AgileEngineDemoApp
//
//  Created by md760 on 30/04/2019.
//  Copyright © 2019 Obremsky. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class MainVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel : MainViewModel = MainViewModel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetch()
    }
    
    func configureUI(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "MainCell", bundle: nil), forCellWithReuseIdentifier: "MainCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        self.collectionView.collectionViewLayout = layout
    }
    
    func setupObservers(){
        self.viewModel.isLoading.skip(1).distinctUntilChanged().take(2).observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (isLoading) in
            self?.showLoader(isLoading)
        }).disposed(by: disposeBag)
        
        self.viewModel.onReload.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            self?.collectionView.reloadData()
        }).disposed(by: disposeBag)
    }
}

extension MainVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = self.viewModel.sections[indexPath.row]
        let identifier = cellModel.cellIdentifier
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? BaseCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: cellModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.viewModel.interItemSpacing(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.viewModel.sizeForCell(at: indexPath, collectionViewSize: collectionView.frame.size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.viewModel.insets(section: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.willDisplay(at: indexPath)
    }
}
