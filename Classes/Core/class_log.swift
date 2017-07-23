//
//  class_log.swift
//  Pods
//
//  Created by Cc on 2017/7/23.
//
//

import Foundation

public func CLSLogError(_ format: String, _ args: CVarArg...)
{
    class_log.instance.fCLSLog(class_log.logLevel.error, format, args)
}

public func CLSLogWarn(_ format: String, _ args: CVarArg...)
{
    class_log.instance.fCLSLog(class_log.logLevel.warn, format, args)
}

public func CLSLogInfo(_ format: String, _ args: CVarArg...)
{
    class_log.instance.fCLSLog(class_log.logLevel.info, format, args)
}

public func CLSLogDebug(_ format: String, _ args: CVarArg...)
{
    class_log.instance.fCLSLog(class_log.logLevel.debug, format, args)
}

public class class_log {
    
    public enum logLevel {
        case silent
        case error
        case warn
        case info
        case debug
        case verbose
    }
    
    public static let instance = class_log.init()
    
    public var mLogBlock: ((_ level: logLevel, _ format: String, _ args: CVarArg...) ->Void)?
    
    private init()
    {
        
    }
    
    deinit
    {
        mLogBlock = nil
    }
    
    public func fCLSLog(_ level: logLevel, _ format: String, _ args: CVarArg...)
    {
        if let block = mLogBlock {
            
            block(level, format, args)
        }
    }
}
