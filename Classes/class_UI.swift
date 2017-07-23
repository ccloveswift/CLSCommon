//
//  class_UI.swift
//  CameraC
//
//  Created by TT on 2017/5/13.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation
import UIKit

public class class_UI: NSObject {
    
    public static func e_gotW750(_ w: CGFloat) -> CGFloat {
        
        let x = UIScreen.main.bounds.width * (w / 750.0);
        
        return x;
    }
    
    public static func e_gotH1334(_ h: CGFloat) -> CGFloat {
        
        let x = UIScreen.main.bounds.width * (h / 1334.0);
        
        return x;
    }
}
