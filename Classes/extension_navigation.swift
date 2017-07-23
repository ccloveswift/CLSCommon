//
//  extension_navigation.swift
//  Booom
//
//  Created by TT on 2017/1/7.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation
import UIKit

public protocol UINavigationAnimationInterface: NSObjectProtocol {

    func iNavigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
}

extension UINavigationController {
    
    static var e_NavVC: UINavigationController? {
        
        get {
            
            return UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        }
    }
}

extension UINavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let aObjectWithAProtocol = fromVC as? UINavigationAnimationInterface {
            
            return aObjectWithAProtocol.iNavigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
        }
        
        return nil
    }
}

public  class BOMNavigationAnimation_BottomToTop: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        
        // 获取动画来自的那个控制器
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        // 获取转场到的那个控制器
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        // 转场动画是两个控制器视图时间的动画，需要一个containerView来作为一个“舞台”，让动画执行。
        let containerView  = transitionContext.containerView
        containerView.insertSubview((toVC?.view)!, belowSubview: (fromVC?.view)!)
        let duration = self.transitionDuration(using: transitionContext)
        
        
        let toBegin = CGRect.init(x: fromVC!.view.frame.origin.x
            , y: fromVC!.view.frame.origin.y + fromVC!.view.frame.size.height
            , width: toVC!.view.frame.size.width
            , height: toVC!.view.frame.size.height)
        let toEnd = fromVC!.view.frame
        
        let fromBegin = fromVC!.view.frame
        let fromEnd = CGRect.init(x: fromBegin.origin.x
            , y: fromBegin.origin.y - fromBegin.size.height
            , width: fromBegin.size.width
            , height: fromBegin.size.height)
        
        
        fromVC?.view.frame = fromBegin
        toVC?.view.frame = toBegin
        
        UIView.animate(withDuration: duration, animations: {() -> Void in
            
            fromVC?.view.frame = fromEnd
            toVC?.view.frame = toEnd
            
        }, completion: {(finis) -> Void in
            
            transitionContext.completeTransition(true)
        })
    }
}

public  class BOMNavigationAnimation_TopToBottom: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        
        // 获取动画来自的那个控制器
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        // 获取转场到的那个控制器
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        // 转场动画是两个控制器视图时间的动画，需要一个containerView来作为一个“舞台”，让动画执行。
        let containerView  = transitionContext.containerView
        containerView.insertSubview((toVC?.view)!, belowSubview: (fromVC?.view)!)
        let duration = self.transitionDuration(using: transitionContext)
        
        
        let fromBegin = fromVC!.view.frame
        let fromEnd = CGRect.init(x: fromVC!.view.frame.origin.x
            , y: fromVC!.view.frame.origin.y + fromVC!.view.frame.size.height
            , width: toVC!.view.frame.size.width
            , height: toVC!.view.frame.size.height)
        
        
        let toBegin = CGRect.init(x: fromBegin.origin.x
            , y: fromBegin.origin.y - fromBegin.size.height
            , width: fromBegin.size.width
            , height: fromBegin.size.height)
        let toEnd = fromVC!.view.frame
        
        
        fromVC?.view.frame = fromBegin
        toVC?.view.frame = toBegin
        
        UIView.animate(withDuration: duration, animations: {() -> Void in
            
            fromVC?.view.frame = fromEnd
            toVC?.view.frame = toEnd
            
        }, completion: {(finis) -> Void in
            
            transitionContext.completeTransition(true)
        })
    }
}
