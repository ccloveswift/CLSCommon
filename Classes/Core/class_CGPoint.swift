//
//  class_CGPoint.swift
//  Pods
//
//  Created by Cc on 2017/9/13.
//
//

import Foundation

public class class_CGPoint {
 
    public class func sPointsDistance(point1: CGPoint, point2: CGPoint) -> Float {
        
        let disX = point1.x - point2.x
        let disY = point1.y - point2.y
        let dis2 = (disX * disX) + (disY * disY)
        let dis = sqrtf(Float(dis2))
        return dis
    }
}
