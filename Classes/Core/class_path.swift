//
//  class_path.swift
//  Booom
//
//  Created by TT on 2017/1/8.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation

public class class_path: NSObject {
    
    
    /// 创建文件夹
    ///
    /// - Parameter path: "/User/xxxx"
    /// - Returns: true = 成功
    public class func sCreateDirectory(path: String) -> Bool {
        
        let url = URL.init(fileURLWithPath: path)
        return class_path.sCreateDirectory(url: url)
    }

    /// 创建文件夹
    ///
    /// - Parameter url: "/User/xxxxx"
    /// - Returns: true=成功
    public class func sCreateDirectory(url: URL) -> Bool {
        
        var bRet = false
        if class_path.sIsDirectoryOrFileExists(url) == false {
            
            do {
                
                try FileManager.default.createDirectory(atPath: url.relativePath, withIntermediateDirectories: true, attributes: nil)
                CLSLogInfo("创建文件夹 \(url) [成功!]")
                bRet = true
            }
            catch let err {
                
                CLSLogError("创建文件夹 \(url) [失败!:\(err)]")
            }
        }
        
        return bRet
    }
    
    /// 删除文件夹
    ///
    /// - Parameter path: "/User/xxxxx"
    /// - Returns: true=成功
    public class func sDeleteDirectory(path: String) -> Bool {
    
        let url = URL.init(fileURLWithPath: path)
        return class_path.sDeleteDirectory(url: url)
    }
    /// 删除文件夹
    ///
    /// - Parameter url: "/User/xxxxx"
    /// - Returns: true=成功
    public class func sDeleteDirectory(url: URL) -> Bool {
        
        var bRet = false
        if class_path.sIsDirectoryOrFileExists(url) == true {
            
            do {
                
                try FileManager.default.removeItem(at: url)
                CLSLogInfo("删除文件夹 \(url) [成功!]")
                bRet = true
            }
            catch let err {
                
                CLSLogError("删除文件夹 \(url) [失败!:\(err)]")
            }
        }
        
        return bRet
    }
    
    /// 判定是否有文件或文件夹
    ///
    /// - Parameter url: 路径 "file:///User/xxx"
    /// - Returns: true = 有
    public class func sIsDirectoryOrFileExists(_ url: URL) -> Bool {

        return sIsDirectoryOrFilePathExists(url.relativePath)
    }
    
    /// 判定是否有文件或文件夹
    ///
    /// - Parameter url: 路径 "/User/xxx"
    /// - Returns: true = 有
    public class func sIsDirectoryOrFilePathExists(_ path: String) -> Bool {
        
        let bRet = FileManager.default.fileExists(atPath: path)
        if bRet {
            
            CLSLogInfo("查找文件 \(path) 【有这个东东】")
        }
        else {
            
            CLSLogInfo("查找文件 \(path) 【没有查到】")
        }
        
        return bRet
    }
    
    
    /// 删除一个文件或文件夹
    ///
    /// - Parameter url: 路径 “file:///User/xxx”
    /// - Returns: true = 成功
    public class func sRemoveDirectoryOrFile(_ url: URL) -> Bool {
        
        var bRet = true
        if class_path.sIsDirectoryOrFileExists(url) {
            
            do {
                
                try FileManager.default.removeItem(at: url)
                
            } catch let err {
                
                CLSLogError("删除文件失败 \(err)")
                bRet = false
            }
        }
        
        return bRet
    }
    
    /// 删除一个文件或文件夹
    ///
    /// - Parameter url: 路径 “/User/xxx”
    /// - Returns: true = 成功
    public class func sRemoveDirectoryOrFilePath(_ path: String) -> Bool {
        
        var bRet = true
        if class_path.sIsDirectoryOrFilePathExists(path) {
            
            do {
                
                try FileManager.default.removeItem(atPath: path)
                
            } catch let err {
                
                CLSLogError("删除文件失败 \(err)")
                bRet = false
            }
        }
        
        return bRet
    }
    
    /// 保存Data
    ///
    /// - Parameters:
    ///   - data: 数据
    ///   - atPath: 路径
    /// - Returns: 成功=true
    public class func sSaveData(_ data: Data, atPath: String) -> Bool {
        
        return FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
    }
}
