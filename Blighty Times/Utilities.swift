//
//  Utilities.swift
//  Blighty Times
//
//  Created by Zachary Duncan on 9/24/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import Foundation


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


func Random(int range: Range<Int>) -> Int {
    return Int.random(in: range);
}

func Random(double range: Range<Double>) -> Double {
    return Double.random(in: range);
}

func Random(index arrayCount: Int) -> Int {
    return Int.random(in: 0 ..< arrayCount);
}
