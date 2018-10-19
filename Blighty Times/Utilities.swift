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


func Random(between left: Int, and right: Int) -> Int {
    if left < right {
        return Int.random(in: left ... right);
    } else {
        return Int.random(in: right ... left);
    }
    
}

func Random(int range: ClosedRange<Int>) -> Int {
    return Int.random(in: range);
}

func Random(double range: ClosedRange<Double>) -> Double {
    return Double.random(in: range);
}

func Random(index arrayCount: Int) -> Int {
    return Int.random(in: 0 ..< arrayCount);
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

extension UIView {
    
    func addShadow(radius: CGFloat, height: CGFloat, color: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)) {
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = CGSize(width: 0.0, height: height)
        self.layer.shadowColor = color.cgColor;
    }
    
    func addBorders(width: CGFloat, color: CGColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
    
    func roundCorners(withIntensity level: Roundness) {
        self.clipsToBounds = true;
        
        switch level {
        case .slight:
            self.layer.cornerRadius = 5.0
        case .heavy:
            self.layer.cornerRadius = 15.0
        case .full:
            self.layer.cornerRadius = self.frame.width > self.frame.height ? self.frame.height / 2 : self.frame.width / 2
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        })
    }
    
    enum Roundness {
        case slight
        case heavy
        case full
    }
}


extension Int {
    func commaFormat() -> String {
        let numberFormatter = NumberFormatter();
        numberFormatter.numberStyle = NumberFormatter.Style.decimal;
        
        return numberFormatter.string(from: NSNumber(value: self))!;
    }
}
