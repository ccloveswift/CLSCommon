//
//  extension_navigation.swift
//  Pods
//
//  Created by TT on 2017/1/7.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation
import UIKit

class class_NavigationController : UINavigationController, UINavigationBarDelegate
{
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        
        if let delegate = self.topViewController as? UINavigationBarDelegate {
            
            let ret = delegate.navigationBar?(navigationBar, shouldPop: item)
            return ret ?? true
        }
        return true
    }
}
