//
//  class_log.swift
//  Pods
//
//  Created by Cc on 2017/7/23.
//
//

import Foundation

public func CLSLogError(_ format: String, file: String = #file, method: String = #function, line: Int = #line)
{
    class_log.instance.fCLSLog(class_log.logLevel.error, format, file, method, line, "")
}
public func CLSLogError(_ format: String, file: String = #file, method: String = #function, line: Int = #line, _ args: CVarArg...)
{
    class_log.instance.fCLSLog(class_log.logLevel.error, format, file, method, line, args)
}

public func CLSLogWarn(_ format: String, file: String = #file, method: String = #function, line: Int = #line)
{
    class_log.instance.fCLSLog(class_log.logLevel.warn, format, file, method, line, "")
}
public func CLSLogWarn(_ format: String, file: String = #file, method: String = #function, line: Int = #line, _ args: CVarArg...)
{
    class_log.instance.fCLSLog(class_log.logLevel.warn, format, file, method, line, args)
}

public func CLSLogInfo(_ format: String, file: String = #file, method: String = #function, line: Int = #line)
{
    class_log.instance.fCLSLog(class_log.logLevel.info, format, file, method, line, "")
}
public func CLSLogInfo(_ format: String, file: String = #file, method: String = #function, line: Int = #line, _ args: CVarArg...)
{
    class_log.instance.fCLSLog(class_log.logLevel.info, format, file, method, line, args)
}

public func CLSLogDebug(_ format: String, file: String = #file, method: String = #function, line: Int = #line)
{
    class_log.instance.fCLSLog(class_log.logLevel.debug, format, file, method, line, "")
}
public func CLSLogDebug(_ format: String, file: String = #file, method: String = #function, line: Int = #line, _ args: CVarArg...)
{
    class_log.instance.fCLSLog(class_log.logLevel.debug, format, file, method, line, args)
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
    
    public static let instance = class_log()
    
    public var mLogBlock: ((_ level: logLevel, _ format: String, _ file: String, _ method: String, _ line: Int, _ args: CVarArg...) ->Void)?
    
    public var mLogPrinter: class_log_print?
    
    private init()
    {}
    deinit
    {
        mLogBlock = nil
    }
    
    public func fCLSLog(_ level: logLevel, _ format: String, _ file: String, _ method: String, _ line: Int, _ args: CVarArg...)
    {
        if let block = mLogBlock {
            
            block(level, format, file, method, line, args)
        }
        
        if let printer = mLogPrinter {
            
            printer.fCLSLog(level, format, file, method, line, args)
            
        }
    }
}

open class class_log_print {
    
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
            return "[---S/N---]"
        }
    }
    
    public init() {
        
    }
    
    open func fCLSLog(_ level: class_log.logLevel, _ format: String, _ file: String, _ method: String, _ line: Int, _ args: CVarArg...)
    {
        let fn = "[\((file as NSString).lastPathComponent):\(line)]"
        Swift.print(self.sGotHead(),
                    fn,
                    self.sGot2Head(level),
                    String.init(format: format, args))
    }
}
