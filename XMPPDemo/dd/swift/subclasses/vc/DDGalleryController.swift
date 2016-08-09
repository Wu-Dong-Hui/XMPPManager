//
//  DDGalleryController.swift
//  Dong
//
//  Created by darkdong on 15/8/28.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDGalleryController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    static var interpageSpacing: CGFloat = 40
    
    var cellClass: DDGalleryCell.Type!
    var cellReuseIdentifier: String!
    
    var models = [AnyObject]()

    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(cellClass != nil, "You must assign 'cellClass' property with subclass of DDGalleryCell")
        assert(cellReuseIdentifier != nil, "You must assign 'cellReuseIdentifier' property")

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSize(width: view.frame.width + DDGalleryController.interpageSpacing, height: view.frame.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect(origin: CGPointZero, size: layout.itemSize), collectionViewLayout: layout)
        collectionView.pagingEnabled = true
        collectionView.registerClass(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)

        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let model: AnyObject = models[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! DDGalleryCell
        cell.reuseWithModel(model)
        return cell
    }
}

class DDGalleryCell: UICollectionViewCell, DDCellReusable {
    var model: AnyObject!
    var galleryView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        DDLog2.print("DDGalleryCell frame \(frame)")
        
        let galleryFrame = CGRect(x: 0, y: 0, width: frame.size.width - DDGalleryController.interpageSpacing, height: frame.size.height)
//        DDLog2.print("DDGalleryCell galleryFrame \(galleryFrame)")
        
        galleryView = UIView(frame: galleryFrame)
        self.contentView.addSubview(galleryView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reuseWithModel(model: AnyObject) {
        DDLog2.print("DDGalleryCell reuseWithModel")
        self.model = model
    }
}
