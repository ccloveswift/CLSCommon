//
//  class_lock.swift
//  Booom
//
//  Created by TT on 2017/1/8.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation

public class class_lock: NSRecursiveLock {
    
    public func lockBlock(_ context: ()->Void) {
        
        self.lock()
        context()
        self.unlock()
    }
}
