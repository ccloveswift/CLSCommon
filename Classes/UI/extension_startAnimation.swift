//
//  extension_startAnimation.swift
//  Booom
//
//  Created by TT on 2017/1/2.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    public func e_StartAnimation() -> Void {
        
        /// 需要在LaunchScreen.storyboard 中 设置Storyboard ID
        let viewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        let launchView = viewController.view
        let mainWindow = UIApplication.shared.keyWindow
        assert(mainWindow != nil, "需要有 UINavigationController")
        launchView?.frame = (mainWindow?.frame)!
        mainWindow?.addSubview(launchView!)
        UIView.animate(withDuration: 0.6, animations: {() -> Void in
            launchView?.alpha = 0.0;
            launchView?.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1.2);
        }, completion: {(finis) -> Void in
            launchView?.removeFromSuperview()
        })
    }
}
