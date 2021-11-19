//
//  extension_thread.swift
//  Pods
//
//  Created by Cc on 2017/8/2.
//
//

import Foundation

extension Thread {
    
    public class func e_MainAsync(_ block: @escaping () -> Void) {
        
        if Thread.isMainThread {
            
            block()
        }
        else {
            
            DispatchQueue.main.async(execute: block)
        }
    }
}
