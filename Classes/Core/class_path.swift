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
    class func sCreateDirectory(path: String) -> Bool {
        
        let url = URL.init(fileURLWithPath: path)
        return class_path.sCreateDirectory(url: url)
    }
    
    
    /// 创建文件夹
    ///
    /// - Parameter url: "/User/xxxxx"
    /// - Returns: true=成功
    class func sCreateDirectory(url: URL) -> Bool {
        
        var bRet = false
        if class_path.sIsDirectoryOrFileExists(url) == false {
            
            do {
                
                try FileManager.default.createDirectory(atPath: url.relativePath, withIntermediateDirectories: true, attributes: nil)
                print("创建文件夹 \(url) [成功!]")
                bRet = true
            }
            catch let err {
                
                print("创建文件夹 \(url) [失败!:\(err)]")
            }
        }
        
        return bRet
    }
    
    
    /// 判定是否有文件或文件夹
    ///
    /// - Parameter url: 路径 "file:///User/xxx"
    /// - Returns: true = 有
    class func sIsDirectoryOrFileExists(_ url: URL) -> Bool {
        
        let bRet = FileManager.default.fileExists(atPath: url.relativePath)
        if bRet {
            
            print("查找文件 \(url.relativePath) 【有这个东东】")
        }
        else {
            
            print("查找文件 \(url.relativePath) 【没有查到】")
        }
        
        return bRet
    }
    
    
    /// 删除一个文件或文件夹
    ///
    /// - Parameter url: 路径 “file:///User/xxx”
    /// - Returns: true = 成功
    class func sRemoveDirectoryOrFile(_ url: URL) -> Bool {
        
        var bRet = true
        if class_path.sIsDirectoryOrFileExists(url) {
            
            do {
                
                try FileManager.default.removeItem(at: url)
                
            } catch let err {
                
                printErr("删除文件失败 \(err)")
                bRet = false
            }
        }
        
        return bRet
    }
}
