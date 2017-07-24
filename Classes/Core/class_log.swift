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
    
    public var mLogPrinter: class_log_print?
    
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
        
        if let printer = mLogPrinter {
            
            printer.fCLSLog(level, format, args)
        }
    }
}

public class class_log_print {
    
    private var mDateFormatter: DateFormatter?
    
    private func sGotHead() -> String {
        
        if mDateFormatter == nil {
            
            let formatter = DateFormatter.init()
            formatter.dateFormat = "[MMMM dd,yyyy HH:mm:ss.SSS]"
            mDateFormatter = formatter
        }
        
        let date = Date.init()
        let str = mDateFormatter!.string(from: date)
        return str
    }
    
    private func sGot2Head(_ level: class_log.logLevel) -> String {
        
        switch level {
        case .debug:
            return "[---Debug---]"
        case .error:
            return "[---Error---]"
        case .warn:
            return "[---Warn---]"
        case .info:
            return "[---Info---]"
        default:
            return ""
        }
    }
    
    public init() {
        
    }
    
    func fCLSLog(_ level: class_log.logLevel, _ format: String, _ args: CVarArg...)
    {
//        #if DEBUG
            Swift.print(self.sGotHead(), self.sGot2Head(level), String.init(format: format, args), separator:" ", terminator: "\n")
//        #endif
    }
}
