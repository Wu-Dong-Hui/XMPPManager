//
//  ArrayExtension.swift
//  Dong
//
//  Created by darkdong on 14/10/29.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import Foundation

enum ArrayMergeMode {
    case Preappend, Append, Replace, Update
}

extension Array {
    func sectionedArray(sections: [Int]) -> [[Element]] {
        var sectionedArray = [[Element]]()
        var modelGenerator = self.generate()
        var hasMoreModel = true
        while hasMoreModel {
            for numberOfItemsPerSection in sections {
                var models = [Element]()
                for _ in 0..<numberOfItemsPerSection {
                    if let model = modelGenerator.next() {
                        models.append(model)
                    }else {
                        hasMoreModel = false
                    }
                }
                if !models.isEmpty {
                    sectionedArray.append(models)
                }
            }
        }
        return sectionedArray
    }
    
    func groupedArray(isSameGroup: ((Element, Element) -> Bool)) -> [[Element]] {
        var groupedArray = [[Element]]()
        var lastElement: Element? = nil
        var currentGroup: [Element]!
        for e in self {
            if let lastE = lastElement where isSameGroup(lastE, e) {
                currentGroup.append(e)
            }else {
                //save currentGroup
                if let group = currentGroup {
                    groupedArray.append(group)
                }
                //new group and add first element
                currentGroup = [Element]()
                currentGroup.append(e)
            }
            lastElement = e
        }
        
        //save the last currentGroup
        if let group = currentGroup {
            groupedArray.append(group)
        }
        
        return groupedArray
    }
    
    func random() -> Element? {
        if count == 0 {
            return nil
        }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
    func randomElements(inout numberOfElements: Int ) -> [Element] {
        if self.count <= numberOfElements {
            return self
        }
        var results: [Element] = []
        var array = self
        while numberOfElements > 0 {
            let index = Int(arc4random_uniform(UInt32(array.count)))
            results.append(array[index])
            array.removeAtIndex(index)
            numberOfElements -= 1
        }
        
        return results
    }
    
    mutating func shuffle() {
        for i in 0..<(self.count - 1) {
            let j = Int(arc4random_uniform(UInt32(self.count - i))) + i
            swap(&self[i], &self[j])
        }
    }
    
    mutating func preextend(newElements: [Element]!) {
        if newElements != nil {
            let range = 0...0//Range(start: 0, end: 0)
            self.replaceRange(range, with: newElements)
        }
    }
    
    func arrayByMergingWithOtherArray(otherArray: [Element], mode: ArrayMergeMode, selfFilter: ((Element) -> Bool)?) -> [Element] {
        var filteredArray = selfFilter != nil ? self.filter(selfFilter!) : self
        var range: Range<Int>?
        switch mode {
        case .Preappend:
            range = 0...0//Range(start: 0, end: 0)
        case .Append:
            range = filteredArray.count..<filteredArray.count//Range(start: filteredArray.count, end: filteredArray.count)
        case .Replace:
            range = 0...filteredArray.count//Range(start: 0, end: filteredArray.count)
        default:
            break
        }
        if range != nil {
            filteredArray.replaceRange(range!, with: otherArray)
            return filteredArray
        }else {
            return self
        }
    }
    
    static func arrayFromJSON(jsonArray: AnyObject!, constructor: (AnyObject!) -> Element?) -> [Element]! {
        if let array = jsonArray as? [AnyObject] {
            var models: [Element] = []
            for obj in array {
                if let model = constructor(obj) {
                    models.append(model)
                }
            }
            return models
        }
        return nil
    }
}
