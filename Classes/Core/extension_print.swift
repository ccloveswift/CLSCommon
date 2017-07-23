//
//  extension_print.swift
//  Booom
//
//  Created by TT on 2017/1/7.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation


public func printInfo(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    #if DEBUG
        Swift.print(class_print.sGotHead(), items[0], separator:separator, terminator: terminator)
    #endif
}

public func printErr(_ items: Any..., separator: String = " ", terminator: String = "\n") {

    #if DEBUG
        Swift.print(class_print.sGotHead(), class_print.sGotErrHead(), items[0], separator:separator, terminator: terminator)
    #endif
}

public func printWarn(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    #if DEBUG
        Swift.print(class_print.sGotHead(), class_print.sGotWarnHead(), items[0], separator:separator, terminator: terminator)
    #endif
}

public func debugPrintInfo(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    Swift.debugPrint(class_print.sGotHead(), class_print.sGotDebugHead(), items[0], separator: separator, terminator: terminator)
}

public class class_print: NSObject {
   
    static var mDateFormatter: DateFormatter?
    
    class func sGotHead() -> String {
        
        if mDateFormatter == nil {
        
            let formatter = DateFormatter.init()
            formatter.dateFormat = "[MMMM dd,yyyy HH:mm:ss.SSS]"
            mDateFormatter = formatter
        }
        
        let date = Date.init()
        let str = mDateFormatter!.string(from: date)
        return str
    }
    
    public class func sGotErrHead() -> String {
        
        return "[---Error---]"
    }
    
    public class func sGotWarnHead() -> String {
        
        return "[---Warn---]"
    }
    
    public class func sGotDebugHead() -> String {
        
        return "[---Debug---]"
    }
}
