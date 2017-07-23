//
//  extension_vc.swift
//  Pods
//
//  Created by TT on 2017/6/25.
//
//

import Foundation
import UIKit

extension UIViewController {
    
    public class func e_CreateVC(storyboard:String, id: String) -> UIViewController {
        
        let viewController = UIStoryboard.init(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: id)
        return viewController;
    }
}
