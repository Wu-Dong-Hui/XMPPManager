//
//  DDBalanceController.swift
//  Dong
//
//  Created by darkdong on 15/4/1.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var models: [DDTableViewModel] = []
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.extendedLayoutIncludesOpaqueBars = true
        
        tableView = UITableView(frame: self.view.bounds)
        tableView.separatorStyle = .None
        tableView.registerClass(DDTableViewCell.self, forCellReuseIdentifier: DDTableViewModel.reusableCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func calculateHeightForModels(models: [DDTableViewModel]) {
        for model in models {
            model.calculateHeights()
            if let submodels = model.submodels {
                calculateHeightForModels(submodels)
            }
        }
    }
    
    func toggleFoldWithModel(model: DDTableViewModel, atIndex index: Int) {
        if model.accessoryType == .Folded {
            if let submodels = model.submodels {
                var models = self.models
                let next = index + 1
                let range = next...next
                models.replaceRange(range, with: submodels)
                self.models = models
                
                var indexPaths = [NSIndexPath]()
                for i in 0..<submodels.count {
                    let ip = NSIndexPath(forRow: next + i, inSection: 0)
                    indexPaths.append(ip)
                }
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                tableView.endUpdates()
            }
            model.accessoryType = .Unfolded
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
        }else if model.accessoryType == .Unfolded {
            if let submodels = model.submodels {
                var models = self.models
                let next = index + 1
                let range = next...(next + submodels.count)//Range(start: next, end: next + submodels.count)
                models.removeRange(range)
                self.models = models
                
                var indexPaths = [NSIndexPath]()
                for i in 0..<submodels.count {
                    let ip = NSIndexPath(forRow: next + i, inSection: 0)
                    indexPaths.append(ip)
                }
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                tableView.endUpdates()
            }
            model.accessoryType = .Folded
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.models.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let model = self.models[index]
        let cell = tableView.dequeueReusableCellWithIdentifier(model.dynamicType.reusableCellIdentifier, forIndexPath: indexPath) as! DDTableViewCell
        cell.setupCellWithModel(model, atIndex: index)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let model = self.models[index]
        return model.cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DDLog2.print("didSelectRowAtIndexPath \(indexPath)")
        let index = indexPath.row
        let model = self.models[index]
        self.toggleFoldWithModel(model, atIndex: index)
    }
}

func ==(lhs: DDTableViewModel, rhs: DDTableViewModel) -> Bool {
    if let lid = lhs.id, let rid = rhs.id {
        return lid == rid
    }else {
        return false
    }
}

class DDTableViewModel: Equatable {
    class var reusableCellIdentifier: String {
        return NSStringFromClass(self)
    }
    
    enum AccessoryType: Int {
        case None = 0
        case Detail = 1
        case Folded = 2
        case Unfolded = 3
    }
    var id: String!
    var leftAttributedString: NSAttributedString!
    var leftImage: UIImage!

    var rightAttributedString: NSAttributedString!
    var rightImage: UIImage!
    var rightPlaceholderAttributedString: NSAttributedString!

    var selected: Bool = false
    var accessoryType: AccessoryType = .None
    var submodels: [DDTableViewModel]!
    
    var cellHeight: CGFloat!
    
    init() {
        
    }
    
    func calculateHeights() {
        if cellHeight == nil {
            cellHeight = 50
        }
    }
}

class DDTableViewCell: UITableViewCell {
    var model: DDTableViewModel!
    
    var leftLabel: UILabel!
    var leftImageView: UIImageView!
    
    var rightLabel: UILabel!
    var rightPlaceholderLabel: UILabel!
    var rightImageView: UIImageView!
    
    var bottomLine: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        leftLabel = UILabel()
        leftLabel.font = UIFont.systemFontOfSize(14)
        contentView.addSubview(leftLabel)
        leftImageView = UIImageView()
        contentView.addSubview(leftImageView)
        
        rightLabel = UILabel()
        rightLabel.font = UIFont.systemFontOfSize(14)
        contentView.addSubview(rightLabel)
        rightPlaceholderLabel = UILabel()
        rightPlaceholderLabel.font = UIFont.systemFontOfSize(14)
        contentView.addSubview(rightPlaceholderLabel)
        rightImageView = UIImageView()
        contentView.addSubview(rightImageView)
        
        let bottomLineHeight: CGFloat = 0.5
        bottomLine = UIView(frame: CGRect(x: 0, y: self.contentView.height - bottomLineHeight, width: self.contentView.width, height: bottomLineHeight))
        bottomLine.backgroundColor = UIColor.lightGrayColor()
        bottomLine.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        bottomLine.hidden = true
        contentView.addSubview(bottomLine)
    }
    
    func setupCellWithModel(model: DDTableViewModel!, atIndex index: Int) {
        self.model = model
        
        leftLabel.attributedText = model.leftAttributedString
        leftImageView.image = model.leftImage
        
        rightLabel.attributedText = model.rightAttributedString
        rightImageView.image = model.rightImage
    }
}

class DDBalanceButton: DDButton {
    var leftMargin: CGFloat = 10
    var rightMargin: CGFloat = 10
    var leftLabel: UILabel!
    var rightLabel: UILabel!
    var moreImgView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let leftLabel = UILabel()
        self.leftLabel = leftLabel
        self.addSubview(leftLabel)
        
        let moreImgView = UIImageView(image: UIImage(namedNoCache: "DDMisc.bundle/arrow_right"))
        self.moreImgView = moreImgView
        self.addSubview(moreImgView)
        
        let rightLabel = UILabel()
        self.rightLabel = rightLabel
        self.addSubview(rightLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        DDLog2.print("DDBalanceButton layoutSubviews")
        
        let cy: CGFloat = self.height / 2
        
        self.leftLabel.left = self.leftMargin
        self.leftLabel.centerY = cy
        
        self.moreImgView.right = self.width - self.rightMargin
        self.moreImgView.centerY = cy

        self.rightLabel.right = self.moreImgView.left - self.rightMargin
        self.rightLabel.centerY = cy
    }
}
