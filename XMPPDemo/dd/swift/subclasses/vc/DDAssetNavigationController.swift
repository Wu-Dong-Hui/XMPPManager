//
//  DDAssetNavigationController.swift
//  Dong
//
//  Created by darkdong on 15/7/4.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit
import AssetsLibrary

typealias SetupGroupsControllerHandler = (DDAssetGroupsController) -> Void
typealias SetupAssetsControllerHandler = (DDAssetsController) -> Void

class DDAssetNavigationController: UINavigationController {
    var library: ALAssetsLibrary!
    var setupAssetsControllerHandler: SetupAssetsControllerHandler?
    
    init(library: ALAssetsLibrary?, setupGroupsControllerHandler: SetupGroupsControllerHandler?, setupAssetsControllerHandler: SetupAssetsControllerHandler?) {
        super.init(nibName: nil, bundle: nil)
        self.library = library ?? ALAssetsLibrary()

        let groupsvc = DDAssetGroupsController(library: self.library)
        setupGroupsControllerHandler?(groupsvc)
        
        let assetsvc = DDAssetsController(library: self.library)
        self.setupAssetsControllerHandler = setupAssetsControllerHandler
        setupAssetsControllerHandler?(assetsvc)
        
        viewControllers = [groupsvc, assetsvc]
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        DDLog2.print("DDAssetNavigationController deinit")
    }
}

class DDAssetGroupsController: UICollectionViewController {
    var library: ALAssetsLibrary
    var groups = [ALAssetsGroup]()
    
    init(library: ALAssetsLibrary) {
        self.library = library

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: DDAssetGroupCell.height)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        DDLog2.print("DDAssetGroupController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(DDAssetGroupsController.cancel))
        
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.registerClass(DDAssetGroupCell.self, forCellWithReuseIdentifier: DDAssetGroupCell.reuseIdentifier)
        
        library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { [weak self] (group, pstop) -> Void in
            if let assetGroup = group {
                self?.groups.append(assetGroup)
            }else {
                //enumerate groups end
                self?.collectionView?.reloadData()
            }
            }) { (error) -> Void in
                
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let assetGroup = groups[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DDAssetGroupCell.reuseIdentifier, forIndexPath: indexPath) as! DDAssetGroupCell
        cell.setupWithModel(assetGroup)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = DDAssetsController(library: library)
        vc.group = groups[indexPath.row]
        if let nc = self.navigationController as? DDAssetNavigationController {
            nc.setupAssetsControllerHandler?(vc)
        }
        navigationController?.pushViewController(vc, animated: true)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class DDAssetGroupCell: UICollectionViewCell {
    static var reuseIdentifier = "DDAssetGroupCellReuseIdentifier"

    static var height: CGFloat = 84
    static var xmargin: CGFloat = 10
    
    static var titleAttributes: [String: AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        return [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.systemFontOfSize(16),
        ]
    }
    
    static var subtitleAttributes: [String: AnyObject] {
        return [
            NSFontAttributeName: UIFont.systemFontOfSize(14),
        ]
    }
    
    var model: ALAssetsGroup!
    var imageView: UIImageView!
    var rightArrow: UIImageView!
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(white: 0.8, alpha: 1)
        self.selectedBackgroundView = selectedBackgroundView
        
        let xmargin = DDAssetGroupCell.xmargin
        let cellHeight = DDAssetGroupCell.height
        
        imageView = UIImageView(frame: CGRect(x: xmargin, y: 0, width: cellHeight, height: cellHeight))
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        self.addSubview(imageView)
        
        rightArrow = UIImageView(image: UIImage(namedNoCache: "DDMisc.bundle/arrow_right"))
        rightArrow.right = frame.maxX - xmargin
        self.addSubview(rightArrow)
        
        textLabel = UILabel(frame: CGRect(x: imageView.right + 2 * xmargin, y: 0, width: rightArrow.left - imageView.right - 3 * xmargin, height: cellHeight))
        textLabel.numberOfLines = 2
        self.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rightArrow.centerY = self.frame.height / 2
    }
    
    //MARK: - public
    func setupWithModel(assetGroup: ALAssetsGroup) {
        self.model = assetGroup
        
        imageView.image = UIImage(CGImage: assetGroup.posterImage().takeUnretainedValue())
        
        let title = NSAttributedString(string: assetGroup.name, attributes: DDAssetGroupCell.titleAttributes)
        let newline = NSAttributedString(string: "\n")
        let subtitle = NSAttributedString(string: "\(assetGroup.numberOfAssets())", attributes: DDAssetGroupCell.subtitleAttributes)
        
        textLabel.attributedText = title + newline + subtitle
    }
}

class DDAssetsController: UICollectionViewController {
    struct StateAttributes {
        var state: UIControlState
        var attributes: [String: AnyObject]
    }
    
    var library: ALAssetsLibrary!
    lazy var group: ALAssetsGroup! = {
        return DDCamera.syncGetAssetsGroupWithType(ALAssetsGroupType(ALAssetsGroupSavedPhotos), library: self.library)
    }()

    var typeFilter = ALAssetsFilter.allAssets()
    var filter: AssetFilter?
    var assets: [ALAsset]!
    var maxNumberOfSelectedAssets = Int.max
    
    var doneNormalTextAttributes: [String: AnyObject] = [
        NSForegroundColorAttributeName : UIColor(ir: 8, ig: 186, ib: 8)
    ]
    var doneStateAttributesArray: [StateAttributes]!
    
    var didSelectAssetsHandler: (([ALAsset]!) -> Void)?
    
    init(library: ALAssetsLibrary) {
        self.library = library
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //itemDimension * 4 + minSpacing * 3 = 77 * 4 + 4 * 3 = 308 + 12 = 320
        let minSpacing = DDSystem.x(4)
        layout.minimumLineSpacing = minSpacing
        layout.minimumInteritemSpacing = minSpacing
        let itemDimension = DDSystem.x(77)
        layout.itemSize = CGSize(width: itemDimension, height: itemDimension)
        
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        DDLog2.print("DDAssetsController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DDLog2.print("DDAssetsController viewDidLoad")
        
        // Do any additional setup after loading the view.
        title = group.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(DDAssetGroupsController.cancel))
        
        //setup toolbar
        let itemFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
////        let itemPreview = UIBarButtonItem(title: "预览", style: .Plain, target: self, action: "preview")
        let itemDone = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(DDAssetsController.done))
        if let stateAttributesArray = doneStateAttributesArray {
            for stateAttributes in stateAttributesArray {
                let state = stateAttributes.state
                let attributes = stateAttributes.attributes
                itemDone.setTitleTextAttributes(attributes, forState: state)
            }
        }else {
            itemDone.setTitleTextAttributes(doneNormalTextAttributes, forState: .Normal)
        }

        let items = [itemFlexibleSpace, itemDone]
        self.setToolbarItems(items, animated: false)
        
        view.backgroundColor = UIColor.whiteColor()
        
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.allowsMultipleSelection = true
        collectionView!.registerClass(DDAssetCell.self, forCellWithReuseIdentifier: DDAssetCell.reuseIdentifier)
        
        if assets == nil {
            DDCamera.enumerateAssetsWithGroup(group, library: library, filter: filter, typeFilter: typeFilter, completionHandler: { [weak self] (alassets) -> Void in
                self?.assets = alassets.reverse()
                self?.collectionView?.reloadData()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.toolbarHidden = true
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let asset = assets[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DDAssetCell.reuseIdentifier, forIndexPath: indexPath) as! DDAssetCell
        cell.setupWithModel(asset)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let indexPaths = collectionView.indexPathsForSelectedItems()
        return indexPaths!.count < maxNumberOfSelectedAssets
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DDAssetCell
        cell.setupSelection()
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DDAssetCell
        cell.setupSelection()
    }

    func done() {
        if let indexPaths = collectionView?.indexPathsForSelectedItems() {
            let selectedAssets = indexPaths.map {
                return self.assets[$0.row]
            }
            self.didSelectAssetsHandler?(selectedAssets)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: TODO preview
    func preview() {
        
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class DDAssetCell: UICollectionViewCell {
    static var reuseIdentifier = "DDAssetCellReuseIdentifier"
    static var xmargin: CGFloat = 10
    
    var model: ALAsset!
    var imageView: UIImageView!
    var selectionView: UIImageView!
    var videoMark: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        self.addSubview(imageView)
        
        selectionView = UIImageView(image: UIImage(namedNoCache: "DDMisc.bundle/circle_blue_check"))
        selectionView.right = imageView.right
        selectionView.hidden = true
        self.addSubview(selectionView)
        
//        videoMark = UIImageView(image: UIImage(namedNoCache: "DDMisc.bundle/video_camera"))
        videoMark = UIImageView(image: UIImage(namedNoCache: "icon_video"))
        videoMark.left = DDSystem.x(4)
        videoMark.bottom = imageView.bottom
        videoMark.hidden = true
        self.addSubview(videoMark)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - public
    func setupSelection() {
        selectionView.hidden = !self.selected
    }
    
    func setupWithModel(asset: ALAsset) {
        self.model = asset
        
        imageView.image = asset.thumbnailImage
        self.setupSelection()
        videoMark.hidden = !asset.isVideo
    }
}