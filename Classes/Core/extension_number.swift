//
//  extension_Int.swift
//  demo-swift-common
//
//  Created by TT on 2017/1/2.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    
    static func e_Random() -> Int { return Int(arc4random()) }
    
    static func e_Random(min: Int, max: Int) -> Int {
        let range = Range(uncheckedBounds: (min, max))
        return Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))) + range.lowerBound
    }
    
    public func e_CGFloat() -> CGFloat {
        
        return CGFloat(self)
    }
}

extension CGFloat {
    
    public func e_Int() -> Int {
        
        return Int(self)
    }
}
