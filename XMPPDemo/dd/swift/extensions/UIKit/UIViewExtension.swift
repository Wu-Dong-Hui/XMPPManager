//
//  UIViewExtension.swift
//  Dong
//
//  Created by darkdong on 14-7-30.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit

struct UIViewPersistenceOptions: OptionSetType {
    private var value: UInt = 0
    
    var boolValue: Bool { return value != 0 }
    var rawValue: UInt { return self.value }
    
    init(rawValue value: UInt) { self.value = value }
    init(nilLiteral: ()) { self.value = 0 }
    
    static var allZeros: UIViewPersistenceOptions { return self.init(rawValue: 0) }
    
    static var None: UIViewPersistenceOptions { return self.init(rawValue: 0) }
    static var Superview: UIViewPersistenceOptions   { return self.init(rawValue: 0b0001) }
    static var Frame: UIViewPersistenceOptions   { return self.init(rawValue: 0b0010) }
}

extension UIView {
    private struct Static {
        static let persistenceKeyFrame = "frame"
        static let persistenceKeySuperview = "superview"
    }
    
    // MARK:- geometry
    var width: CGFloat {
        get {
            return frame.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return frame.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    var left: CGFloat {
        get {
            return frame.minX
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var right: CGFloat {
        get {
            return frame.maxX
        }
        set {
            frame.origin.x = newValue - frame.width
        }
    }
    
    var top: CGFloat {
        get {
            return frame.minY
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.maxY
        }
        set {
            frame.origin.y = newValue - frame.height
        }
    }
    
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center = CGPoint(x: newValue, y: center.y)
        }
    }
    
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center = CGPoint(x: center.x, y: newValue)
        }
    }
    
    var centerOfSize: CGPoint {
        return CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    
    var boundsRect: CGRect {
        return CGRect(origin: CGPointZero, size: frame.size)
    }
    
    func setHeightWhileKeepingBottom(height: CGFloat) {
        frame.origin.y += frame.height - height
        frame.size.height = height
    }
    
    // MARK:- hierarchy
    
    var viewController: UIViewController? {
//        for var nextview = self.superview; nextview != nil; nextview = nextview!.superview {
//            if let vc = nextview!.nextResponder() as? UIViewController {
//                return vc
//            }
//        }
        var nextView = self.superview
        while nextView != nil {
            if let vc = nextView!.nextResponder() as? UIViewController {
                return vc
            } else {
                nextView = nextView?.superview
            }
        }
        return nil
    }
    
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    func firstResponderView() -> UIView? {
        if isFirstResponder() {
            return self
        }else {
            for subview in subviews {
                if let view = subview.firstResponderView() {
                    return view
                }
            }
            return nil
        }
    }
    
    func viewWithClass(anyClass: AnyClass) -> UIView? {
        if isKindOfClass(anyClass) {
            return self
        }else {
            for subview in subviews {
                if let view = subview.viewWithClass(anyClass) {
                    return view
                }
            }
            return nil
        }
    }
    
    // MARK:- layout
    class func layoutView(view: UIView, constraintRect: CGRect, insets: DDEdgeInsets = .Nil, horizontalAlignment: UIControlContentHorizontalAlignment = .Center, verticalAlignment: UIControlContentVerticalAlignment = .Center) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        if insets.left != nil {
            x = constraintRect.minX + insets.left!
        }else if insets.right != nil {
            x = constraintRect.maxX - insets.right! - view.width
        }else {
            //no insets left or right，use horizontalAlignment
            if .Left == horizontalAlignment {
                x = constraintRect.minX
            }else if .Right == horizontalAlignment {
                x = constraintRect.maxX - view.width
            }else {
                x = constraintRect.midX - view.width / 2
            }
        }
        
        if insets.top != nil {
            y = constraintRect.minY + insets.top!
        }else if insets.bottom != nil {
            y = constraintRect.maxY - insets.bottom! - view.height
        }else {
            //no insets top or bottom，use verticalAlignment
            if .Top == verticalAlignment {
                y = constraintRect.minY
            }else if .Bottom == verticalAlignment {
                y = constraintRect.maxY - view.height
            }else {
                y = constraintRect.midY - view.height / 2
            }
        }
        
        view.origin = CGPoint(x: x, y: y)
    }
    
    class func layoutViewsHorizontally(views: [UIView], constraintRect: CGRect, insets: DDEdgeInsets = .Nil, verticalAlignment: UIControlContentVerticalAlignment = .Center, spacings: [CGFloat]! = nil) {
        
        //exclude hidden views
        let visibleViews = views.filter {
            !$0.hidden
        }
        
        if 0 == visibleViews.count {
            return
        }
        
        if 1 == visibleViews.count {
            let view = visibleViews[0]
            self.layoutView(view, constraintRect: constraintRect, insets: insets, horizontalAlignment: .Center, verticalAlignment: verticalAlignment)
        }else {
            let totalVisibleViewsWidth = visibleViews.reduce(0) {
                $0 + $1.width
            }
            
            let totalNumberOfSpacings = visibleViews.count - 1
            var standardSpacings: [CGFloat] = []
            
            if let customSpacings = spacings where !customSpacings.isEmpty {
                if customSpacings.count > totalNumberOfSpacings {
                    let range = 0...totalNumberOfSpacings//Range(start: 0, end: totalNumberOfSpacings)
                    standardSpacings = [CGFloat](customSpacings[range])
                }else {
                    standardSpacings.appendContentsOf(customSpacings)
                }
                if standardSpacings.count < totalNumberOfSpacings {
                    //not enough, add default
                    let defaultCustomSpacing = customSpacings.last!
                    let numberOfMissingCustomSpacings = totalNumberOfSpacings - customSpacings.count
                    for _ in 0..<numberOfMissingCustomSpacings {
                        standardSpacings.append(defaultCustomSpacing)
                    }
                }
            }else {
                let left = insets.left ?? 0
                let right = insets.right ?? 0
                let autoSpacing: CGFloat = (constraintRect.width - left - right - totalVisibleViewsWidth) / CGFloat(totalNumberOfSpacings)
                for _ in 0..<visibleViews.count - 1 {
                    standardSpacings.append(autoSpacing)
                }
            }
            
            let totalStandardSpacing = standardSpacings.reduce(0) {
                $0 + $1
            }
            
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            if insets.left != nil {
                x = constraintRect.minX + insets.left!
            }else {
                if insets.right != nil {
                    x = constraintRect.maxX - totalStandardSpacing - totalVisibleViewsWidth - insets.right!
                }else {
                    let widthsLeft = constraintRect.width - totalStandardSpacing - totalVisibleViewsWidth
                    x = constraintRect.minX + widthsLeft / 2
                }
            }
            
            var standardSpacingsGenerator = standardSpacings.generate()
            
            for view in visibleViews {
                let spacing = standardSpacingsGenerator.next() ?? 0
                
                if insets.top != nil {
                    y = constraintRect.minY + insets.top!
                }else if insets.bottom != nil {
                    y = constraintRect.maxY - insets.bottom! - view.height
                }else {
                    //no insets top or bottom，use verticalAlignment
                    if .Top == verticalAlignment {
                        y = constraintRect.minY
                    }else if .Bottom == verticalAlignment {
                        y = constraintRect.maxY - view.height
                    }else {
                        y = constraintRect.midY - view.height / 2
                    }
                }
                view.origin = CGPoint(x: x, y: y)
                x += view.width + spacing
            }
        }
    }
    
    class func layoutViewsVertically(views: [UIView], constraintRect: CGRect, insets: DDEdgeInsets = .Nil, horizontalAlignment: UIControlContentHorizontalAlignment = .Center, spacings: [CGFloat]! = nil) {
        
        //exclude hidden views
        let visibleViews = views.filter {
            !$0.hidden
        }
        
        if 0 == visibleViews.count {
            return
        }
        
        if 1 == visibleViews.count {
            let view = visibleViews[0]
            self.layoutView(view, constraintRect: constraintRect, insets: insets, horizontalAlignment: horizontalAlignment, verticalAlignment: .Center)
        }else {
            let totalVisibleViewsHeight = visibleViews.reduce(0) {
                $0 + $1.height
            }
            
            let totalNumberOfSpacings = visibleViews.count - 1
            var standardSpacings: [CGFloat] = []
            
            if let customSpacings = spacings where !customSpacings.isEmpty {
                if customSpacings.count > totalNumberOfSpacings {
                    let range = 0...totalNumberOfSpacings//Range(start: 0, end: totalNumberOfSpacings)
                    standardSpacings = [CGFloat](customSpacings[range])
                }else {
                    standardSpacings.appendContentsOf(customSpacings)
                }
                if standardSpacings.count < totalNumberOfSpacings {
                    //not enough, add default
                    let defaultCustomSpacing = customSpacings.last!
                    let numberOfMissingCustomSpacings = totalNumberOfSpacings - customSpacings.count
                    for _ in 0..<numberOfMissingCustomSpacings {
                        standardSpacings.append(defaultCustomSpacing)
                    }
                }
            }else {
                let top = insets.top ?? 0
                let bottom = insets.bottom ?? 0
                let autoSpacing: CGFloat = (constraintRect.height - top - bottom - totalVisibleViewsHeight) / CGFloat(totalNumberOfSpacings)
                for _ in 0..<visibleViews.count - 1 {
                    standardSpacings.append(autoSpacing)
                }
            }
            
            let totalStandardSpacing = standardSpacings.reduce(0) {
                $0 + $1
            }
            
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            if insets.top != nil {
                y = constraintRect.minY + insets.top!
            }else {
                if insets.bottom != nil {
                    y = constraintRect.maxY - totalStandardSpacing - totalVisibleViewsHeight - insets.bottom!
                }else {
                    let heightsLeft = constraintRect.height - totalStandardSpacing - totalVisibleViewsHeight
                    y = constraintRect.minY + heightsLeft / 2
                }
            }
            
            var standardSpacingsGenerator = standardSpacings.generate()
            
            for view in visibleViews {
                let spacing = standardSpacingsGenerator.next() ?? 0

                if insets.left != nil {
                    x = constraintRect.minX + insets.left!
                }else if insets.right != nil {
                    x = constraintRect.maxX - insets.right! - view.width
                }else {
                    //no insets left or right，use horizontalAlignment
                    if .Left == horizontalAlignment {
                        x = constraintRect.minX
                    }else if .Right == horizontalAlignment {
                        x = constraintRect.maxX - view.width
                    }else {
                        x = constraintRect.midX - view.width / 2
                    }
                }
                view.origin = CGPoint(x: x, y: y)
                y += view.height + spacing
            }
        }
    }
    
    class func layoutViewsTabularly(views: [UIView],  constraintRect: CGRect, columns: Int, gridSize: CGSize, insets: DDEdgeInsets = .Nil) {
        if columns <= 1 {
            UIView.layoutViewsVertically(views, constraintRect: constraintRect, insets: insets)
            return
        }
        
        //exclude hidden views
        let visibleViews = views.filter {
            !$0.hidden
        }
        
        if 0 == visibleViews.count {
            return
        }
        
        let left = insets.left ?? 0
        let right = insets.right ?? 0
        let autoSpacing: CGFloat = (constraintRect.width - left - right - CGFloat(columns) * gridSize.width) / CGFloat(columns - 1)
//        let rows = (visibleViews.count + columns - 1) / columns
        
        let firstOriginX = constraintRect.minX + left
        let top = insets.top ?? 0
        let firstOriginY = constraintRect.minY + top
        let firstCenterX = firstOriginX + gridSize.width / 2
        let firstCenterY = firstOriginY + gridSize.height / 2
        var currentCenter = CGPoint(x: firstCenterX, y: firstCenterY)
        var index = 0
        
        for view in visibleViews {
            if index > 0 && 0 == index % columns {
                //new row
                currentCenter.x = firstCenterX
                currentCenter.y += gridSize.height + autoSpacing
            }
            view.center = currentCenter
            currentCenter.x += gridSize.width + autoSpacing
            index += 1
        }
    }
    
    class func layoutViewsFlowly(views: [UIView],  constraintRect: CGRect, insets: DDEdgeInsets = .Nil, spacing: CGPoint = CGPoint(x: 10, y: 10)) -> CGFloat {
        //exclude hidden views
        let visibleViews = views.filter {
            !$0.hidden
        }
        
        if 0 == visibleViews.count {
            return 0
        }
        
        let x0 = insets.left ?? 0
        let y0 = insets.top ?? 0
        var x = x0
        var y = y0
        var nextY = y0
        let maxX = constraintRect.maxX - (insets.right ?? 0)
        for view in visibleViews {
            if x + view.width > maxX {
                x = x0
                y = nextY
            }
            view.origin = CGPoint(x: x, y: y)
            x = view.right + spacing.x
            nextY = max(nextY, view.bottom + spacing.y)
        }
        return nextY
    }
    
    // MARK:- layout subviews

    func layoutView(view: UIView, constraintRect: CGRect? = nil, insets: DDEdgeInsets = .Nil, horizontalAlignment: UIControlContentHorizontalAlignment = .Center, verticalAlignment: UIControlContentVerticalAlignment = .Center) {
        let rect = constraintRect ?? CGRect(origin: CGPointZero, size: self.size)
        
        UIView.layoutView(view, constraintRect: rect, insets: insets, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment)
    }
    
    func layoutSubviewsHorizontally(insets: DDEdgeInsets = .Nil, verticalAlignment: UIControlContentVerticalAlignment = .Center, spacings: [CGFloat]? = nil, constraintRect: CGRect? = nil) {
        
        let subviews = self.subviews 
        let rect = constraintRect ?? CGRect(origin: CGPointZero, size: self.size)
        
        UIView.layoutViewsHorizontally(subviews, constraintRect: rect, insets: insets, verticalAlignment: verticalAlignment, spacings: spacings)
    }
    
    func layoutSubviewsVertically(insets: DDEdgeInsets = .Nil, horizontalAlignment: UIControlContentHorizontalAlignment = .Center, spacings: [CGFloat]? = nil, constraintRect: CGRect? = nil) {
        
        let subviews = self.subviews 
        let rect = constraintRect ?? CGRect(origin: CGPointZero, size: self.size)
        
        UIView.layoutViewsVertically(subviews, constraintRect: rect, insets: insets, horizontalAlignment: horizontalAlignment, spacings: spacings)
    }
    
    func layoutSubviewsTabularly(columns: Int, gridSize: CGSize, insets: DDEdgeInsets = .Nil, constraintRect: CGRect? = nil) {
        let subviews = self.subviews 
        let rect = constraintRect ?? CGRect(origin: CGPointZero, size: self.size)
        
        UIView.layoutViewsTabularly(subviews, constraintRect: rect, columns: columns, gridSize: gridSize, insets: insets)
    }
    
    func layoutSubviewsFlowly(insets: DDEdgeInsets = .Nil, spacing: CGPoint = CGPoint(x: 10, y: 10), constraintRect: CGRect? = nil) -> CGFloat  {
        let subviews = self.subviews 
        let rect = constraintRect ?? CGRect(origin: CGPointZero, size: self.size)
        
        return UIView.layoutViewsFlowly(subviews, constraintRect: rect, insets: insets, spacing: spacing)
    }

    // MARK: - display
    
    func isVisible() -> Bool {
        if hidden {
            return false
        }
//        for var nextview = superview; nextview != nil; nextview = nextview!.superview {
//            if nextview!.hidden {
//                return false
//            }
//        }
        var nextView = superview
        while nextView != nil {
            if nextView!.hidden {
                return false
            } else {
                nextView = nextView?.superview
            }
        }
        return true
    }
    
    func hasLayerMask() -> Bool {
        return layer.mask != nil
    }
    
    func clipsToOval() {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(ovalInRect: bounds)
        maskLayer.path = path.CGPath
        layer.mask = maskLayer
    }
    
    func clipsToRoundedRect(cornerRadius cornerRadius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).CGPath
        layer.mask = maskLayer
    }
    
    func clipsToMaskImage(maskImage: UIImage?) {
        guard let image = maskImage else {
            return
        }
        let maskImageView = UIImageView(frame: bounds)
        maskImageView.image = image
        layer.mask = maskImageView.layer
    }
    
    func clipsToSpeechShape(insets insets: UIEdgeInsets, cornerRadius: CGFloat, triangleVertex vertex: CGPoint, triangleBasePoint1 point1: CGPoint, triangleBasePoint2 point2: CGPoint) {
//        var inset = UIEdgeInsetsZero
//        if point1.x == point2.x {
//            //triangle in horizontal direction
//            if vertex.x > point1.x {
//                //right chevron
//                inset.right = bounds.width - point1.x
//            }else {
//                //left chevron
//                inset.left = point1.x
//            }
//        }else if point1.y == point2.y {
//            //triangle in vertical direction
//            if vertex.y > point1.y {
//                //down chevron
//                inset.bottom = bounds.height - point1.y
//            }else {
//                //up chevron
//                inset.top = point1.y
//            }
//        }else {
//            return
//        }
        let rect = bounds.rectByEdgeInsets(insets)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        let pathForTriangle = UIBezierPath()
        pathForTriangle.moveToPoint(vertex)
        pathForTriangle.addLineToPoint(point1)
        pathForTriangle.addLineToPoint(point2)
        pathForTriangle.closePath()
        
        path.appendPath(pathForTriangle)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        layer.mask = maskLayer
    }
    
    func drawBorder(borderWidth: CGFloat, color: UIColor?) {
        layer.borderWidth = borderWidth
        layer.borderColor = color?.CGColor
    }
    
    // MARK: - misc
    func save(options: UIViewPersistenceOptions = .Frame) {
        var dic: [NSObject: AnyObject] = [:]
        
        if (options.intersect(.Frame)).boolValue {
            dic[Static.persistenceKeyFrame] = NSValue(CGRect: self.frame)
        }
        
        if (options.intersect(.Superview)).boolValue && self.superview != nil {
            dic[Static.persistenceKeySuperview] = self.superview
        }
        self.associatedObject = dic
    }
    
    func restore() {
        if let dic = self.associatedObject as? [NSObject: AnyObject] {
            if let superview = dic[Static.persistenceKeySuperview] as? UIView {
                superview.addSubview(self)
            }
            
            if let frameValue = dic[Static.persistenceKeyFrame] as? NSValue {
                self.frame = frameValue.CGRectValue()
            }
        }
        
        self.associatedObject = nil
    }
    
    //MARK: - show transition
    func showhide(shouldShow: Bool, duration: NSTimeInterval = 0.3, transition: String = kCATransitionFromBottom, transitionDistance: CGFloat? = nil, completion: (() -> Void)? = nil) {
        let finalTop = self.top
        var distance: CGFloat = 0
        
        if let d = transitionDistance {
            distance = d
        }else {
            if transition == kCATransitionFromBottom || transition == kCATransitionFromTop {
                distance = self.height
            }else if transition == kCATransitionFromLeft || transition == kCATransitionFromRight {
                distance = self.width
            }
        }
        
        if shouldShow {
            self.hidden = false
            self.alpha = 0
            var transitionBeginTop = self.top
            if transition == kCATransitionFromBottom {
                transitionBeginTop = finalTop + distance
            }else if transition == kCATransitionFromTop {
                transitionBeginTop = finalTop - distance
            }
            self.top = transitionBeginTop
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.top = finalTop
                self.alpha = 1
                }, completion: { (finished) -> Void in
                    completion?()
            })
        }else {
            var transitionEndTop = self.top
            if transition == kCATransitionFromBottom {
                transitionEndTop = finalTop + distance
            }else if transition == kCATransitionFromTop {
                transitionEndTop = finalTop - distance
            }
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.top = transitionEndTop
                self.alpha = 0
                }, completion: { (finished) -> Void in
                    self.hidden = true
                    self.top = finalTop
                    self.alpha = 1
                    completion?()
            })
        }
    }
}
    