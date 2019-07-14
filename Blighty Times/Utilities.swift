//
//  Utilities.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 9/24/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit


//func Random(between min: Double, and max: Double) -> Double {
//    var TRUEMIN: Double = min > 0 ? min + 1.0 : min;
//    var TRUEMAX: Double = max > 0 ? max + 1.0 : max;
//    TRUEMIN *= 10;
//    TRUEMAX *= 10;
//
//    return TRUEMIN <= TRUEMAX
//        ? (Double(arc4random_uniform(UInt32(TRUEMAX - TRUEMIN))) + 10.0 * min) / 10.0
//        : (Double(arc4random_uniform(UInt32(TRUEMIN - TRUEMAX))) + 10.0 * max) / 10.0
//}

//func Random(between min: Int, and max: Int) -> Int {
//    return Int(Random(between: Double(min), and: Double(max)));
//}

//func RandomIndex(from elementCount: Int) -> Int {
//    return Int(arc4random_uniform(UInt32(elementCount)));
//}



func Random(double range: ClosedRange<Double>) -> Double {
    return Double.random(in: range);
}



extension NSPointerArray {
    func addObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
    
    func insertObject(_ object: AnyObject?, at index: Int) {
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        insertPointer(pointer, at: index)
    }
    
    func replaceObject(at index: Int, withObject object: AnyObject?) {
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        replacePointer(at: index, withPointer: pointer)
    }
    
    func object(at index: Int) -> ArticleTile? {
        guard index < count, let pointer = self.pointer(at: index) else { return nil; }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue() as? ArticleTile;
    }
    
    func removeObject(at index: Int) {
        guard index < count else { return }
        
        removePointer(at: index)
    }
}



extension UINavigationController {
    func fadeTo(_ viewController: UIViewController) {
        let transition: CATransition = CATransition();
        transition.duration = 0.3;
        transition.type = .fade;
        view.layer.add(transition, forKey: nil);
        pushViewController(viewController, animated: false);
    }
}
