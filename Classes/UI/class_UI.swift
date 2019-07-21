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
    
    public static func e_GotW750(_ w: CGFloat) -> CGFloat {
        
        let x = UIScreen.main.bounds.width * (w / 750.0);
        
        return x;
    }
    
    public static func e_GotH1334(_ h: CGFloat) -> CGFloat {
        
        let x = UIScreen.main.bounds.height * (h / 1334.0);
        
        return x;
    }
    
    public static func e_GotW1242(_ w: CGFloat) -> CGFloat {
        
        let x = UIScreen.main.bounds.width * (w / 1242.0);
        
        return x;
    }
    
    public static func e_GotH2208(_ h: CGFloat) -> CGFloat {
        
        let x = UIScreen.main.bounds.height * (h / 2208.0);
        
        return x;
    }
    
    public static func e_StringSize(text: String, font: UIFont) -> CGSize {
        
        let font = font
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        return size
    }
}
