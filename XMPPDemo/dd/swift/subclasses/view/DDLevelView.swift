//
//  DDLevelView.swift
//  Dong
//
//  Created by darkdong on 15/2/5.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDBaseLevelView: UIView {
    var currentLevels = 2 {
        didSet {
            if currentLevels != oldValue {
                refreshPath()
            }
        }
    }
    var maxLevels = 3
    var contentInsets = UIEdgeInsetsZero {
        didSet {
            refreshPath()
        }
    }

    var lineWidth: CGFloat = 4
    var strokeColor = UIColor.whiteColor()
    var levelPath: UIBezierPath?
    var clipPath: UIBezierPath?

    override var frame: CGRect {
        didSet {
            refreshPath()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        opaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func realX(unitX: CGFloat) -> CGFloat {
        let rect = frame.rectByEdgeInsets(contentInsets)
        return rect.minX + unitX * rect.width
    }
    
    private func realY(unitY: CGFloat) -> CGFloat {
        let rect = frame.rectByEdgeInsets(contentInsets)
        return rect.minY + unitY * rect.height
    }
    
    private func realPoint(unitPoint: CGPoint) -> CGPoint {
        let x = realX(unitPoint.x)
        let y = realY(unitPoint.y)
        return CGPoint(x: x, y: y)
    }
    
    private func realLine(unitLine: DDLine) -> DDLine {
        let startPoint = realPoint(unitLine.startPoint)
        let endPoint = realPoint(unitLine.endPoint)
        return DDLine(startPoint: startPoint, endPoint: endPoint)
    }

    func refreshPath() {
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        if let levelPath = levelPath {
            let context = UIGraphicsGetCurrentContext()

            CGContextSetLineWidth(context, lineWidth)
            CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
            
            CGContextAddPath(context, levelPath.CGPath)
            CGContextStrokePath(context)
        }
        
        clipPath?.addClip()
    }
}

class DDLineLevelView: DDBaseLevelView {
    var unitLines = [DDLine]() {
        didSet {
            refreshPath()
        }
    }

    override func refreshPath() {
        guard currentLevels >= 1 && unitLines.count >= currentLevels else {
            return
        }
        
        super.refreshPath()
        
        let path = UIBezierPath()
        
        for unitLine in unitLines[0..<currentLevels] {
            let line = realLine(unitLine)
            path.moveToPoint(line.startPoint)
            path.addLineToPoint(line.endPoint)
        }
        
        levelPath = path
    }
    
    func generateLinesByInterpolation(firstLine firstLine: DDLine, lastLine: DDLine) {
        guard maxLevels >= 2 else {
            return
        }
        
        var x1 = firstLine.startPoint.x
        var y1 = firstLine.startPoint.y
        var x2 = firstLine.endPoint.x
        var y2 = firstLine.endPoint.y
        
        let segments = CGFloat(maxLevels - 1)
        let step1 = CGPoint(x: (lastLine.startPoint.x - firstLine.startPoint.x) / segments, y: (lastLine.startPoint.y - firstLine.startPoint.y) / segments)
        let step2 = CGPoint(x: (lastLine.endPoint.x - firstLine.endPoint.x) / segments, y: (lastLine.endPoint.y - firstLine.endPoint.y) / segments)

        var lines = [DDLine]()
        
        for _ in 0..<maxLevels {
            let line = DDLine(startPoint: CGPoint(x: x1, y: y1), endPoint: CGPoint(x: x2, y: y2))
            lines.append(line)
            
            x1 += step1.x
            y1 += step1.y
            x2 += step2.x
            y2 += step2.y
        }
        
        unitLines = lines
    }
}

class DDArcLevelView: DDBaseLevelView {
    var unitArcs = [DDArc]() {
        didSet {
            refreshPath()
        }
    }
    
    override func refreshPath() {
        guard currentLevels >= 1 && unitArcs.count >= currentLevels else {
            return
        }
        
        super.refreshPath()
        
        let path = UIBezierPath()
        
        for unitArc in unitArcs[0..<currentLevels] {
            var realArc = unitArc
            realArc.center = realPoint(unitArc.center)
            path.appendPath(realArc.bezierPath)
        }
        
        levelPath = path
    }
    
    func generateArcsByInterpolation(constraintArc: DDArc, firstArcRadius: CGFloat, lastArcRadius: CGFloat) {
        guard maxLevels >= 2 else {
            return
        }
        
        let segments = CGFloat(maxLevels - 1)
        let step = (lastArcRadius - firstArcRadius) / segments
        var radius = firstArcRadius

        var arcs = [DDArc]()

        for _ in 0..<maxLevels {
            var arc = constraintArc
            arc.radius = radius
            arcs.append(arc)
            radius += step
        }

        unitArcs = arcs
    }
}

